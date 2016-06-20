//
//  NSDictionary+CCKit.h
//  demo
//
//  Created by KudoCC on 16/6/6.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (CCKit)

/// it calls `- (id)cc_objectForKeyPath:(NSString *)keyPath separator:(NSString *)separator` with separator '.'
- (id)cc_objectForKeyPath:(NSString *)keyPath;
- (id)cc_objectForKeyPath:(NSString *)keyPath separator:(NSString *)separator;

@end


@interface NSMutableDictionary (CCKit)

/// it calls `- (void)cc_setObject:(id)object forKeyPath:(NSString *)keyPath separator:(NSString *)separator` with separator '.'
- (void)cc_setObject:(id)object forKeyPath:(NSString *)keyPath;
- (void)cc_setObject:(id)object forKeyPath:(NSString *)keyPath separator:(NSString *)separator;

@end