//
//  NSDictionary+CCKit.m
//  demo
//
//  Created by KudoCC on 16/6/6.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "NSDictionary+CCKit.h"

@implementation NSDictionary (CCKit)

+ (id)cc_objectForKeyPath:(NSString *)keyPath {
    return [self cc_objectForKeyPath:keyPath separator:@"."];
}

+ (id)cc_objectForKeyPath:(NSString *)keyPath separator:(NSString *)separator {
    NSArray *array = [keyPath componentsSeparatedByString:separator];
    if ([array count] > 0) {
        id value = self;
        for (NSString *key in array) {
            value = value[key];
            if (!value) {
                break;
            }
        }
        return value;
    }
    return nil;
}

@end
