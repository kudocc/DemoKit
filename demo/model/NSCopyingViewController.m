//
//  NSCopyingViewController.m
//  demo
//
//  Created by KudoCC on 16/5/28.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "NSCopyingViewController.h"
#import "NSObject+CC_JSON.h"

@interface BaseModelObject : NSObject <NSCopying>

@property (nonatomic, copy) NSString *name;

@end

@implementation BaseModelObject

- (id)copyWithZone:(NSZone *)zone {
    return [self ccjson_copyWithZone:zone];
}

@end


@interface SubModeObject : BaseModelObject <NSCopying>

@property (nonatomic, assign) int value;

@end

@implementation SubModeObject

- (id)copyWithZone:(NSZone *)zone {
    return [self ccjson_copyWithZone:zone];
}

@end

@interface NSCopyingViewController ()

@end

@implementation NSCopyingViewController

- (void)initView {
    SubModeObject *sub = [[SubModeObject alloc] init];
    sub.name = @"KudoCC";
    sub.value = 10;
    SubModeObject *subCopy = [sub copy];
    NSLog(@"%@, %@", sub, subCopy);
}

@end
