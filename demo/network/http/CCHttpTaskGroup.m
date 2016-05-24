//
//  CCHttpTaskGroup.m
//  demo
//
//  Created by KudoCC on 16/5/23.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "CCHttpTaskGroup.h"
#import <AFNetworking.h>
#import "CCHttpSessionManager.h"

@interface CCHttpTask () {
    NSString *_identifier;
}

// 是否正在执行
@property (nonatomic, assign) BOOL executing;
// 是否执行完成
@property (nonatomic, assign) BOOL finished;
// 是否所有依赖都已经满足
@property (nonatomic, readonly) BOOL ready;
// 是否已经被取消
@property (nonatomic, assign) BOOL cancelled;

@property (nonatomic, strong) NSMutableArray<CCHttpTask *> *dependencies;

@property (nonatomic, strong) NSMutableArray *mutableArrayNextTasks;

@property (nonatomic, strong) NSURLSessionDataTask *dataTask;

- (void)startTask;

@end

@implementation CCHttpTask

- (id)init {
    self = [super init];
    if (self) {
        _mutableArrayNextTasks = [NSMutableArray array];
        _dependencies = [NSMutableArray array];
        _post = YES;
    }
    return self;
}

- (NSString *)taskIdentifier {
    if (!_identifier) {
        _identifier = [NSString stringWithFormat:@"%p", self];
    }
    return _identifier;
}

- (void)addDependencyTask:(CCHttpTask *)task {
    // self依赖于task
    [_dependencies addObject:task];
    // task->self有一条边，表示task完成后要检查self是否可以执行
    [task.mutableArrayNextTasks addObject:self];
}

- (BOOL)ready {
    for (CCHttpTask *task in _dependencies) {
        if (!task.finished) {
            return NO;
        }
    }
    return YES;
}

- (void)startTask {
    if (_cancelled) {
        return;
    }
    
    _executing = YES;
    
    __weak typeof(self) wself = self;
    
    NSURL *baseURL = [_url baseURL];
    AFHTTPSessionManager *manager = [[CCHttpSessionManager sharedManager] sessionManagerForBaseURL:baseURL];
    
    if (_post) {
        _dataTask = [manager POST:[_url absoluteString] parameters:_params success:^(NSURLSessionDataTask *task, id responseObject) {
            [wself taskDidSuccess:responseObject];
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            [wself taskDidFailedWithError:error];
        }];
    } else {
        _dataTask = [manager GET:[_url absoluteString] parameters:_params success:^(NSURLSessionDataTask *task, id responseObject) {
            [wself taskDidSuccess:responseObject];
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            [wself taskDidFailedWithError:error];
        }];
    }
}

- (void)taskDidSuccess:(id)responseObject {
    self.executing = NO;
    self.finished = YES;
    
    NSHTTPURLResponse *response = (NSHTTPURLResponse *)self.dataTask.response;
    [self.delegate task:self didFinishWithResponseData:responseObject httpResponseStatus:(int)response.statusCode];
    
    // 移除边，防止retain cycle
    [self.mutableArrayNextTasks removeAllObjects];
}

- (void)taskDidFailedWithError:(NSError *)error {
    self.executing = NO;
    self.finished = YES;
    
    [self.delegate task:self didFailWithError:error];
    
    // 移除边，防止retain cycle
    [self.mutableArrayNextTasks removeAllObjects];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@", _taskName];
}

#pragma mark - CCHttpTaskOperation

- (void)cancel {
    if (_cancelled) {
        return;
    }
    _cancelled = YES;
    
    if (_executing && _dataTask) {
        [_dataTask cancel];
    } else if (!_finished) {
        _finished = YES;
        
        NSError *error = [[NSError alloc] initWithDomain:NSURLErrorDomain code:NSURLErrorCancelled userInfo:nil];
        [self taskDidFailedWithError:error];
    }
}

@end

@interface CCHttpTaskGroup () <CCHttpTaskDelegate> {
    NSMutableDictionary<NSString *, NSNumber *> *_color;
}

@property (nonatomic, strong) NSMutableArray *mutableArrayTasks;

// 保存task依赖图的邻接表
@property (nonatomic, strong) NSMutableDictionary<NSString *, CCHttpTask *> *identifierTask;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSMutableArray<CCHttpTask *> *> *adjacencyTable;

// 保存互相不依赖的task图，每一个item为一个NSArray<CCHttpTask *>，保存有依赖关系的图
@property (nonatomic, strong) NSArray<NSArray<CCHttpTask *> *> *arrayTaskCategory;

@end

@implementation CCHttpTaskGroup

- (id)init {
    self = [super init];
    if (self) {
        _mutableArrayTasks = [NSMutableArray array];
    }
    return self;
}

- (void)addTask:(CCHttpTask *)task {
    task.delegate = self;
    [_mutableArrayTasks addObject:task];
    
    if (!_identifierTask) {
        _identifierTask = [NSMutableDictionary dictionary];
    }
    if (!_adjacencyTable) {
        _adjacencyTable = [NSMutableDictionary dictionary];
    }
    NSString *taskIdentifier = [task taskIdentifier];
    _identifierTask[taskIdentifier] = task;
    _adjacencyTable[taskIdentifier] = [@[] mutableCopy];
}

- (void)startTaskGroup {
    // 检查有没有环
    BOOL hasCycle = [self dfs];
    if (hasCycle) {
        NSLog(@"依赖设置错误，有环存在");
        return;
    }
    
    // 创建邻接表
    [self constructAdjacencyTable];
    
    // 取没有依赖的task作为起点
    NSMutableArray *mutableArrayStartTasks = [NSMutableArray array];
    for (CCHttpTask *task in _mutableArrayTasks) {
        if ([task.dependencies count] == 0) {
            [mutableArrayStartTasks addObject:task];
        }
    }
    
    // 开启任务
    if ([_delegate respondsToSelector:@selector(groupTaskWillStart:)]) {
        [_delegate groupTaskWillStart:self];
    }
    
    for (CCHttpTask *task in mutableArrayStartTasks) {
        if ([_delegate respondsToSelector:@selector(taskWillStart:inGroup:)]) {
            [_delegate taskWillStart:task inGroup:self];
        }
        [task startTask];
    }
}

- (void)constructAdjacencyTable {
    for (CCHttpTask *task in _mutableArrayTasks) {
        for (CCHttpTask *taskDependency in task.dependencies) {
            NSString *taskIdentifier = [taskDependency taskIdentifier];
            NSMutableArray *tasks = _adjacencyTable[taskIdentifier];
            [tasks addObject:task];
        }
    }
}

- (void)debugAdjacencyTable {
    [_adjacencyTable enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSMutableArray<CCHttpTask *> * _Nonnull obj, BOOL * _Nonnull stop) {
        CCHttpTask *task = _identifierTask[key];
        NSString *taskDesc = [NSString stringWithFormat:@"%@", task];
        printf("task %s: edge:", [taskDesc UTF8String]);
        for (CCHttpTask *task in obj) {
            printf("%s ", [[NSString stringWithFormat:@"%@", task] UTF8String]);
        }
        printf("\n");
    }];
}

#pragma mark - CCHttpTaskOperation

- (void)cancel {
    for (CCHttpTask *task in _mutableArrayTasks) {
        if (!task.finished) {
            [task cancel];
        }
    }
}

#pragma mark - CCHttpTaskDelegate

- (void)task:(CCHttpTask *)task didFinishWithResponseData:(NSDictionary *)response httpResponseStatus:(int)statusCode {
    [_delegate groupTask:self taskDidFinish:task responseData:response httpResponseStatus:statusCode];
    
    // 检查是否全部的task都已经完成
    BOOL allTaskFinished = YES;
    for (CCHttpTask *task in _mutableArrayTasks) {
        if (!task.finished) {
            allTaskFinished = NO;
            break;
        }
    }
    if (allTaskFinished) {
        if ([_delegate respondsToSelector:@selector(groupTaskDidEnd:)]) {
            [_delegate groupTaskDidEnd:self];
        }
    } else {
        // 继续下一个任务
        NSString *taskIdentifier = [task taskIdentifier];
        NSArray *tasks = _adjacencyTable[taskIdentifier];
        for (CCHttpTask *nextTask in tasks) {
            // nextTask准备就绪 & 不是正在进行 & 不是已经完成的
            if ([nextTask ready] && !nextTask.executing && !nextTask.finished) {
                if ([_delegate respondsToSelector:@selector(taskWillStart:inGroup:)]) {
                    [_delegate taskWillStart:nextTask inGroup:self];
                }
                [nextTask startTask];
            }
        }
    }
    
    // 将task从图中删除
    [_adjacencyTable removeObjectForKey:[task taskIdentifier]];
    
    [self debugAdjacencyTable];
}

- (void)task:(CCHttpTask *)task didFailWithError:(NSError *)error {
    [_delegate groupTask:self taskDidFail:task error:error];
    
    // 以这个task为起始位置深度优先搜索，拿到的搜索结果数组全部cancel
    NSMutableArray *mutableArray = [NSMutableArray array];
    [self cleanAndInitDFS];
    [self dfs_visit:[task taskIdentifier] insertIntoArray:mutableArray];
    
    NSMutableArray *removeTaskIdentifiers = [NSMutableArray array];
    for (CCHttpTask *task in mutableArray) {
        [removeTaskIdentifiers addObject:[task taskIdentifier]];
        if (!task.cancelled && !task.finished) {
            [task cancel];
        }
    }
    [_adjacencyTable removeObjectsForKeys:removeTaskIdentifiers];
    
    // 如果task还没有开始运行就被cancel了，那么其dependency的task也在图中
    // 此时要将task从其dependency的邻接表中删掉
    // 如果task已经运行了，那么其dependency已经不在图中了
    for (CCHttpTask *taskDependency in task.dependencies) {
        NSMutableArray *tasks = _adjacencyTable[[taskDependency taskIdentifier]];
        if (tasks) {
            [tasks removeObject:task];
        }
    }
}

#pragma mark - DFS & DAG

// 0 is white, 1 is gray, 2 is black

- (void)cleanAndInitDFS {
    _color = [NSMutableDictionary dictionary];
    for (NSString *identifier in _adjacencyTable.allKeys) {
        _color[identifier] = @0;
    }
}

// 检查是否存在环
- (BOOL)dfs {
    [self cleanAndInitDFS];
    
    BOOL hasCycle = NO;
    for (NSString *identifier in _adjacencyTable.allKeys) {
        if ([_color[identifier] isEqualToNumber:@0]) {
            hasCycle = [self dfs_visit:identifier insertIntoArray:nil];
            if (hasCycle) {
                break;
            }
        }
    }
    return hasCycle;
}

// YES:有环
- (BOOL)dfs_visit:(NSString *)taskIdentifier insertIntoArray:(NSMutableArray *)mutableArray {
    // gray
    _color[taskIdentifier] = @1;
    
    CCHttpTask *task = _identifierTask[taskIdentifier];
    if (mutableArray) {
        [mutableArray addObject:task];
    }
    for (CCHttpTask *nextTask in task.mutableArrayNextTasks) {
        NSString *nextIdentifier = [nextTask taskIdentifier];
        // if it is white
        if ([_color[nextIdentifier] isEqualToNumber:@0]) {
            if ([self dfs_visit:nextIdentifier insertIntoArray:mutableArray]) {
                return YES;
            }
        } else if ([_color[nextIdentifier] isEqualToNumber:@1]) {
            // point to a gray, cycle exists
            return YES;
        }
    }
    _color[taskIdentifier] = @2;
    
    return NO;
}

@end