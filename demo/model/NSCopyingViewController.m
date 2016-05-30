//
//  NSCopyingViewController.m
//  demo
//
//  Created by KudoCC on 16/5/28.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "NSCopyingViewController.h"
#import "NSObject+CCModel.h"

@interface BaseModelObject : NSObject <NSCopying, NSCoding, CCModel>

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

#pragma mark - CCModel

- (void)modelFinishConstructFromJSONObject:(NSDictionary *)jsonObject {
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

+ (NSSet<NSString *> *)propertyNameCalculateHash {
    return [NSSet setWithObject:@"name"];
}

@end


@interface SubModeObject : BaseModelObject <NSCopying, CCModel>

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

- (BOOL)isEqual:(id)object {
    return [self ccmodel_isEqual:object];
}

- (NSUInteger)hash {
    return [self ccmodel_hash];
}

#pragma mark - CCModel use base

@end

@interface NSCopyingViewController ()

@end

@implementation NSCopyingViewController

- (void)initView {
    SubModeObject *sub = [[SubModeObject alloc] init];
    sub.name = @"KudoCC";
    sub.value = 10;
    
    // Test copy
    SubModeObject *subCopy = [sub copy];
    NSLog(@"%@, %@", sub, subCopy);
    NSAssert([sub isEqual:subCopy], @"error");
    NSAssert(subCopy.name && [sub.name isEqualToString:subCopy.name], @"error");
    NSAssert(subCopy.value == sub.value, @"error");
    
    // Test NSCoding
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:sub];
    if (data) {
        SubModeObject *obj = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        NSLog(@"%@", obj);
        NSAssert([obj isEqual:sub], @"error");
    }
}

@end
