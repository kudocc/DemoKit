//
//  ModelViewController.m
//  demo
//
//  Created by KudoCC on 16/5/27.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "ModelViewController.h"
#import "JsonObjectAndModelViewController.h"
#import "NSCopyingViewController.h"

@interface ModelObject : NSObject <NSCoding>

@property (nonatomic, copy) NSString *name;

@end

@implementation ModelObject

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_name forKey:@"name"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        _name = [aDecoder decodeObjectForKey:@"name"];
    }
    return self;
}

@end

@interface Model1Object : NSObject <NSCoding>

@property (nonatomic, strong) NSArray *array;

@end

@implementation Model1Object

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_array forKey:@"array"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        _array = [aDecoder decodeObjectForKey:@"array"];
    }
    return self;
}

@end


@implementation ModelViewController

- (void)initView {
//    ModelObject *base = [[ModelObject alloc] init];
//    base.name = @"caonima";
//    NSArray *arr = @[base];
//    
//    Model1Object *obj1 = [[Model1Object alloc] init];
//    obj1.array = arr;
//    
//    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:obj1];
//    if (data) {
//        id o = [NSKeyedUnarchiver unarchiveObjectWithData:data];
//        NSLog(@"%@", o);
//    }
    
    self.arrayTitle = @[@"Json Object and Model", @"NSCopying"];
    self.arrayClass = @[[JsonObjectAndModelViewController class], [NSCopyingViewController class]];

    NSString *jsonString = @"{\"key\":null, \"num\":10, \"string\":\"abc\"}";
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *obj = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    NSAssert(obj[@"key"] == [NSNull null], @"error");
    NSAssert([obj[@"key"] class] == [NSNull class], @"error");
    NSLog(@"%@", obj);
}

@end

