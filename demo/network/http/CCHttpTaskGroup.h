//
//  CCHttpTaskGroup.h
//  demo
//
//  Created by KudoCC on 16/5/23.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CCHttpTaskOperation <NSObject>
- (void)cancel;
@end


@class CCHttpTask;
@protocol CCHttpTaskDelegate <NSObject>

@required
- (void)task:(CCHttpTask *)task didFinishWithResponseData:(NSDictionary *)response httpResponseStatus:(int)statusCode;
- (void)task:(CCHttpTask *)task didFailWithError:(NSError *)error;

@end


/**
 可以把task加到CCHttpTaskGroup里，也可以直接使用。
 
 如果直接使用CCHttpTask，`addDependencyTask:`将无效，并且要自己实现`CCHttpTaskDelegate`；
 */
@interface CCHttpTask : NSObject <CCHttpTaskOperation>

@property (nonatomic, copy) NSString *taskName;
@property (nonatomic, readonly) NSString *taskIdentifier;

@property (nonatomic, copy) NSURL *url;

@property (nonatomic, copy) NSDictionary *params;

// default is YES
@property (nonatomic, assign) BOOL post;

@property (nonatomic, weak) id<CCHttpTaskDelegate> delegate;

@property (nonatomic, readonly) NSArray<CCHttpTask*> *dependencies;

- (void)addDependencyTask:(CCHttpTask *)task;

- (void)startTask;

@end


@protocol CCHttpTaskGroupDelegate;
@interface CCHttpTaskGroup : NSObject <CCHttpTaskOperation>

@property (nonatomic, weak) id<CCHttpTaskGroupDelegate> delegate;

- (void)addTask:(CCHttpTask *)task;

- (void)startTaskGroup;

@end


@protocol CCHttpTaskGroupDelegate <NSObject>

@required
- (void)groupTask:(CCHttpTaskGroup *)groupTask
    taskDidFinish:(CCHttpTask *)task
     responseData:(NSDictionary *)response httpResponseStatus:(int)statusCode;

- (void)groupTask:(CCHttpTaskGroup *)groupTask taskDidFail:(CCHttpTask *)task error:(NSError *)error;

@optional
- (void)groupTaskWillStart:(CCHttpTaskGroup *)groupTask;
- (void)groupTaskDidEnd:(CCHttpTaskGroup *)groupTask;

// invoke just before the task starts, this is the last chance for you to modify its properties
- (void)taskWillStart:(CCHttpTask *)task inGroup:(CCHttpTaskGroup *)groupTask;

@end