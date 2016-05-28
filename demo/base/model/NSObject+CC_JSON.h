//
//  NSObject+CC_JSON.h
//  demo
//
//  Created by KudoCC on 16/5/26.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <objc/message.h>
#import "ModelClass.h"

@interface NSObject (CCKit_JSON)

/// json must be NSDictionary or NSString or NSData
+ (id)ccjson_modelWithJSON:(id)json;

/// model to json object
- (NSDictionary *)ccjson_jsonObject;

/// debug information
- (NSString *)ccjson_debugDescription;

//- (id)ccjson_copyWithZone:(NSZone *)zone;

@end


@interface NSArray (CCKit_JSON)

/**
 Create a NSArray with json object
 @param json it must be NSArray or NSString or NSData
 @param typeObject describe the value type
 */
+ (id)ccjson_arrayWithJSON:(id)json withValueType:(ContainerTypeObject *)typeObject;

- (NSArray *)ccjson_jsonObjectArrayWithValueType:(ContainerTypeObject *)typeObject;

@end


@interface NSDictionary (CCKit_JSON)

/// json must be NSDictionary or NSString or NSData
+ (id)ccjson_dictionaryWithJSON:(id)json withValueType:(ContainerTypeObject *)typeObject;
+ (id)ccjson_dictionaryWithJSON:(id)json withKeyToValueType:(NSDictionary<NSString *, ContainerTypeObject *> *)keyToValueType;


- (NSDictionary *)ccjson_jsonObjectDictionaryWithValueType:(ContainerTypeObject *)typeObject;
- (NSDictionary *)ccjson_jsonObjectDictionaryWithKeyToValueType:(NSDictionary<NSString *, ContainerTypeObject *> *)keyToValueType;

@end


@protocol CCModel <NSObject>

@optional
// the key is property name
- (NSDictionary<NSString *, ContainerTypeObject *> *)propertyNameToContainerTypeObjectMap;

- (NSDictionary<NSString *, NSString *> *)propertyNameToJsonKeyMap;

@end
