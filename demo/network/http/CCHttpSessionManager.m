//
//  CCHttpSessionManager.m
//  demo
//
//  Created by KudoCC on 16/5/23.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "CCHttpSessionManager.h"

@implementation CCHttpSessionManager {
    NSMutableDictionary *_mutableDictionaryHttpSessionManager;
}

+ (instancetype)sharedManager {
    static CCHttpSessionManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[CCHttpSessionManager alloc] init];
    });
    return manager;
}

- (id)init {
    self = [super init];
    if (self) {
        _mutableDictionaryHttpSessionManager = [NSMutableDictionary dictionary];
        
        NSURL *url = [NSURL URLWithString:@"http://www.baidu.com"];
        NSURL *url2 = [NSURL URLWithString:@"http://www.baidu.com"];
        _mutableDictionaryHttpSessionManager[url] = url2;
        _mutableDictionaryHttpSessionManager[url2] = url;
        NSLog(@"%@", @([_mutableDictionaryHttpSessionManager count]));
        [_mutableDictionaryHttpSessionManager removeAllObjects];
    }
    return self;
}

- (AFHTTPSessionManager *)sessionManagerForBaseURL:(NSURL *)baseURL {
    if (_mutableDictionaryHttpSessionManager[baseURL]) {
        return _mutableDictionaryHttpSessionManager[baseURL];
    } else {
        AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
        _mutableDictionaryHttpSessionManager[baseURL] = manager;
        return manager;
    }
}

@end
