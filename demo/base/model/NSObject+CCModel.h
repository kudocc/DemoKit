//
//  NSObject+CCModel.h
//  demo
//
//  Created by KudoCC on 16/5/26.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <objc/message.h>
#import "ModelClass.h"

/*
 Apple says in NSJSONSerialization,
 An object that may be converted to JSON must have the following properties:
 1. The top level object is an NSArray or NSDictionary.
 2. All objects are instances of NSString, NSNumber, NSArray, NSDictionary, or NSNull.
 3. All dictionary keys are instances of NSString.
 4. Numbers are not NaN or infinity.
 
 So the model property type is limited, but I will try to support as many as I could
 ______________________________________________________________________________________
 property                   JSON object
 ______________________________________________________________________________________
 NSString               NSString/NSNumber,
 NSMutableString
 NSNumber               NSString/NSNumber,
 NSDecimalNumber        NSString/NSNumber,
 NSNull                 NSNull,
 NSURL                  NSString with `URLWithString:`
 NSDate                 NSNumber/NSString it's a timestamp value
 NSArray
 NSMutableArray
 NSDictionary
 NSMutableDictionary
 ______________________________________________________________________________________
 */

@interface NSObject (CCModel)

/// json must be NSDictionary or NSString or NSData
+ (id)ccmodel_modelWithJSON:(id)json;

/// model to json object
- (NSDictionary *)ccmodel_jsonObject;

/// debug information
- (NSString *)ccmodel_debugDescription;

/// NSCopying
- (id)ccmodel_copyWithZone:(NSZone *)zone;

/// NSCoding
- (id)ccmodel_initWithCoder:(NSCoder *)coder;
- (void)ccmodel_encodeWithCoder:(NSCoder *)coder;

@end


@interface NSArray (CCModel)

/**
 Create a NSArray with json object
 @param json it must be NSArray or NSString or NSData
 @param typeObject describe the value type
 */
+ (id)ccmodel_arrayWithJSON:(id)json withValueType:(ContainerTypeObject *)typeObject;

- (NSArray *)ccmodel_jsonObjectArrayWithValueType:(ContainerTypeObject *)typeObject;

@end


@interface NSDictionary (CCModel)

/// json must be NSDictionary or NSString or NSData
+ (id)ccmodel_dictionaryWithJSON:(id)json withValueType:(ContainerTypeObject *)typeObject;
+ (id)ccmodel_dictionaryWithJSON:(id)json withKeyToValueType:(NSDictionary<NSString *, ContainerTypeObject *> *)keyToValueType;


- (NSDictionary *)ccmodel_jsonObjectDictionaryWithValueType:(ContainerTypeObject *)typeObject;
- (NSDictionary *)ccmodel_jsonObjectDictionaryWithKeyToValueType:(NSDictionary<NSString *, ContainerTypeObject *> *)keyToValueType;

@end
