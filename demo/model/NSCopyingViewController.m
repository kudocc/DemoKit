//
//  NSCopyingViewController.m
//  demo
//
//  Created by KudoCC on 16/5/28.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "NSCopyingViewController.h"
#import "NSObject+CCModel.h"

@interface BaseModelObject : NSObject <NSCopying, NSCoding>

@property (nonatomic, copy) NSString *name;

@end

@implementation BaseModelObject

- (id)copyWithZone:(NSZone *)zone {
    return [self ccmodel_copyWithZone:zone];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    return [self ccmodel_initWithCoder:aDecoder];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [self ccmodel_encodeWithCoder:aCoder];
}

@end


@interface SubModeObject : BaseModelObject <NSCopying>

@property (nonatomic, assign) int value;

@end

@implementation SubModeObject

- (id)copyWithZone:(NSZone *)zone {
    return [self ccmodel_copyWithZone:zone];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    return [self ccmodel_initWithCoder:aDecoder];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [self ccmodel_encodeWithCoder:aCoder];
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
    
    {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:sub];
        if (data) {
            SubModeObject *obj = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            NSLog(@"%@", obj);
        }
    }
}

@end
