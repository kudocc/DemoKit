//
//  NSObject+CC_JSON.m
//  demo
//
//  Created by KudoCC on 16/5/26.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "NSObject+CC_JSON.h"
#import "NSObject+CCKit.h"

@interface NSObject (CC_JSON_Util)

/**
 serialize is from JSON object to model or other Objective-C object
 @param containerTypeObj if classObject indicates its a container, then containerTypeObj describes the container
 */
- (id)serializeJSONObj:(id)jsonObj toClass:(Class)classObject withContainerTypeObject:(ContainerTypeObject *)containerTypeObj;

/**
 deserialize is from model or other Objective-C object to JSON object
 @param containerTypeObj if classObject indicates its a container, then containerTypeObj describes the container
 */
- (id)deserializeFromObject:(id)obj fromClass:(Class)classObject withContainerTypeObject:(ContainerTypeObject *)containerTypeObj;

@end

@implementation NSObject (CC_JSON_Util)

- (id)serializeJSONObj:(id)jsonObj toClass:(Class)classObject withContainerTypeObject:(ContainerTypeObject *)containerTypeObj {
    CCObjectType type = CCObjectTypeFromClass(classObject);
    
    if (type == CCObjectTypeNSString ||
        type == CCObjectTypeNSMutableString) {
        // NSString/NSNumber
        if ([jsonObj isKindOfClass:[NSNumber class]]) {
            jsonObj = [jsonObj stringValue];
        }
        if ([jsonObj isKindOfClass:[NSString class]]) {
            if (type == CCObjectTypeNSMutableString) {
                return [jsonObj mutableCopy];
            } else {
                return jsonObj;
            }
        }
    } else if (type == CCObjectTypeNSNumber) {
        // support NSString / NSNumber
        if ([jsonObj isKindOfClass:[NSString class]]) {
            NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
            f.numberStyle = NSNumberFormatterDecimalStyle;
            jsonObj = [f numberFromString:jsonObj];
        }
        if ([jsonObj isKindOfClass:[NSNumber class]]) {
            return jsonObj;
        }
    } else if (type == CCObjectTypeNSDecimalNumber) {
        if ([jsonObj isKindOfClass:[NSNumber class]]) {
            jsonObj = [jsonObj stringValue];
        }
        if ([jsonObj isKindOfClass:[NSString class]]) {
            jsonObj = [NSDecimalNumber decimalNumberWithString:jsonObj];
        }
        if ([jsonObj isKindOfClass:[NSDecimalNumber class]]) {
            return jsonObj;
        }
    } else if (type == CCObjectTypeNSNull) {
        return [NSNull null];
    } else if (type == CCObjectTypeNSURL) {
        if ([jsonObj isKindOfClass:[NSString class]]) {
            return [NSURL URLWithString:jsonObj];
        }
    } else if (type == CCObjectTypeNSDate) {
        // NSNumber/NSString, it should be a timestamp
        if ([jsonObj isKindOfClass:[NSString class]] || [jsonObj isKindOfClass:[NSNumber class]]) {
            double timestamp = [jsonObj doubleValue];
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp];
            return date;
        }
    } else if (type == CCObjectTypeNSArray ||
               type == CCObjectTypeNSMutableArray) {
        NSParameterAssert(containerTypeObj.valueClassObj);
        NSArray *array = [NSArray ccjson_arrayWithJSON:jsonObj withValueType:containerTypeObj.valueClassObj];
        if (type == CCObjectTypeNSMutableArray) {
            return [array mutableCopy];
        }
        return array;
    } else if (type == CCObjectTypeNSDictionary ||
               type == CCObjectTypeNSMutableDictionary) {
        NSDictionary *dict = nil;
        if (containerTypeObj.keyToClass) {
            dict = [NSDictionary ccjson_dictionaryWithJSON:jsonObj withKeyToValueType:containerTypeObj.keyToClass];
        } else if (containerTypeObj.valueClassObj) {
            dict = [NSDictionary ccjson_dictionaryWithJSON:jsonObj withValueType:containerTypeObj.valueClassObj];
        }
        if (dict && type == CCObjectTypeNSMutableDictionary) {
            return [dict mutableCopy];
        }
        return dict;
    } else if ([jsonObj isKindOfClass:[NSDictionary class]]) {
        // try to convert to class
        return [classObject ccjson_modelWithJSON:jsonObj];
    }
    NSLog(@"%@, don't support the class:%@", NSStringFromSelector(_cmd), classObject);
    return nil;
}

- (id)deserializeFromObject:(id)obj fromClass:(Class)classObject withContainerTypeObject:(ContainerTypeObject *)containerTypeObj {
    CCObjectType type = CCObjectTypeFromClass(classObject);
    if (type == CCObjectTypeNSString ||
        type == CCObjectTypeNSMutableString ||
        type == CCObjectTypeNSDecimalNumber ||
        type == CCObjectTypeNSNumber ||
        type == CCObjectTypeNSNull) {
        return obj;
    } else if (type == CCObjectTypeNSURL) {
        return [((NSURL *)obj) absoluteString];
    } else if (type == CCObjectTypeNSDate) {
        NSDate *date = obj;
        return @([date timeIntervalSince1970]);
    } else if (type == CCObjectTypeNSArray ||
               type == CCObjectTypeNSMutableArray) {
        NSParameterAssert(containerTypeObj.valueClassObj);
        return [obj ccjson_jsonObjectArrayWithValueType:containerTypeObj.valueClassObj];
    } else if (type == CCObjectTypeNSDictionary ||
               type == CCObjectTypeNSMutableDictionary) {
        if (containerTypeObj.keyToClass) {
            return [obj ccjson_jsonObjectDictionaryWithKeyToValueType:containerTypeObj.keyToClass];
        } else if (containerTypeObj.valueClassObj) {
            return [obj ccjson_jsonObjectDictionaryWithValueType:containerTypeObj.valueClassObj];
        }
    } else {
        // TODO: obj may be a model, may be not, if not, how to deal with??????
        return [obj ccjson_jsonObject];
    }
    return nil;
}

@end

@implementation NSObject (CC_JSON)

- (NSString *)ccjson_debugDescription {
    NSMutableString *mutableString = [@"class begin\n" mutableCopy];
    [mutableString appendFormat:@"class name:%@\n", self.class];
    CCClass *classInfo = [CCClass classWithClassObject:self.class];
    for (CCProperty *property in [classInfo.properties allValues]) {
        [mutableString appendFormat:@"%@ ", property.propertyName];
    }
    return mutableString;
}

#pragma mark - NSCopying

- (id)ccjson_copyWithZone:(NSZone *)zone {
    id target = [[self.class alloc] init];
    
    CCClass *classInfo = [CCClass classWithClassObject:self.class];
    while (classInfo) {
        for (CCProperty *property in classInfo.properties) {
            if (!property.setter || !property.getterName) {
                continue;
            }
            
            if (isNumberTypeOfEncodingType(property.encodingType)) {
                NSNumber *number = [self getNumberProperty:property];
                if (number) {
                    [target setNumberProperty:property withJsonObj:number];
                }
            } else if (isObjectTypeOfEncodingType(property.encodingType)) {
                id obj = ((id (*)(id, SEL))objc_msgSend)(self, property.getter);
                id copyObj = nil;
                if (property.objectType == CCObjectTypeNSMutableString ||
                    property.objectType == CCObjectTypeNSMutableArray ||
                    property.objectType == CCObjectTypeNSMutableDictionary) {
                    copyObj = [obj mutableCopy];
                } else {
                    copyObj = [obj copy];
                }
                if (copyObj) {
                    ((void (*)(id, SEL, id))objc_msgSend)(target, property.setter, copyObj);
                }
            }
        }
        
        classInfo = classInfo.superClass;
    }
    return target;
}

#pragma mar - NSCoding

- (id)ccjson_initWithCoder:(NSCoder *)coder {
    CCClass *classInfo = [CCClass classWithClassObject:self.class];
    while (classInfo) {
        for (CCProperty *property in [classInfo.properties allValues]) {
            if (!property.getter || !property.setter) continue;
            
            if (isNumberTypeOfEncodingType(property.encodingType)) {
                id number = [coder decodeObjectForKey:property.propertyName];
                if (number) {
                    [self setNumberProperty:property withJsonObj:number];
                }
            } else if (isObjectTypeOfEncodingType(property.encodingType)) {
                id obj = [coder decodeObjectForKey:property.propertyName];
                ((void (*)(id, SEL, id))objc_msgSend)(self, property.setter, obj);
            }
        }
        
        classInfo = classInfo.superClass;
    }
    return self;
}

- (void)ccjson_encodeWithCoder:(NSCoder *)coder {
    CCClass *classInfo = [CCClass classWithClassObject:self.class];
    while (classInfo) {
        for (CCProperty *property in [classInfo.properties allValues]) {
            if (!property.getter || !property.setter) continue;
            
            if (isNumberTypeOfEncodingType(property.encodingType)) {
                NSNumber *number = [self getNumberProperty:property];
                if (number) {
                    [coder encodeObject:number forKey:property.propertyName];
                }
            } else if (isObjectTypeOfEncodingType(property.encodingType)) {
                id obj = ((id (*)(id, SEL))objc_msgSend)(self, property.getter);
                if (obj) {
                    [coder encodeObject:obj forKey:property.propertyName];
                }
            }
        }
        
        classInfo = classInfo.superClass;
    }
}

#pragma mark - init

+ (id)ccjson_modelWithJSON:(id)json {
    NSDictionary *dict = nil;
    NSData *data = nil;
    if ([json isKindOfClass:[NSDictionary class]]) {
        dict = json;
    } else if ([json isKindOfClass:[NSString class]]) {
        data = [json dataUsingEncoding:NSUTF8StringEncoding];
    } else if ([json isKindOfClass:[NSData class]]) {
        data = json;
    }
    if (data && !dict) {
        dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    }
    if (dict && [dict isKindOfClass:[NSDictionary class]]) {
        id obj = [[self class] ccjson_modelWithJSONDictionary:dict];
        return obj;
    }
    return nil;
}

+ (id)ccjson_modelWithJSONDictionary:(NSDictionary *)json {
    id obj = [[[self class] alloc] initWithJSONDictionary:json];
    return obj;
}

- (id)initWithJSONDictionary:(NSDictionary *)jsonDictionary {
    self = [self init];
    if (!self) return nil;
    
    CCClass *classInfo = [CCClass classWithClassObject:self.class];
    while (classInfo) {
        for (CCProperty *property in [classInfo.properties allValues]) {
            if (!property.setter || !property.getter) {
                continue;
            }
            id jsonObj = jsonDictionary[property.jsonKey];
            if (!jsonObj) continue;
            
            CCEncodingType encodingType = property.encodingType;
            if (isNumberTypeOfEncodingType(encodingType)) {
                [self setNumberProperty:property withJsonObj:jsonObj];
            } else if (isObjectTypeOfEncodingType(encodingType)) {
                if (isContainerTypeForObjectType(property.objectType)) {
                    ContainerTypeObject *containerTypeObject = classInfo.propertyNameToContainerTypeObjectMap[property.propertyName];
                    NSAssert(containerTypeObject, @"container need description");
                    if (!containerTypeObject) continue;
                    [self setContainerProperty:property withJsonObj:jsonObj containerTypeObject:containerTypeObject];
                } else {
                    [self setObjectProperty:property withJsonObj:jsonObj];
                }
            }
        }
        
        classInfo = classInfo.superClass;
    }
    return self;
}

- (NSDictionary *)ccjson_jsonObject {
    CCClass *classInfo = [CCClass classWithClassObject:self.class];
    NSMutableDictionary *mutableDictionary = [NSMutableDictionary dictionary];
    while (classInfo) {
        for (CCProperty *property in [classInfo.properties allValues]) {
            if (!property.getter || !property.setter) {
                continue;
            }
            CCEncodingType encodingType = property.encodingType;
            if (isNumberTypeOfEncodingType(encodingType)) {
                NSNumber *number = [self getNumberProperty:property];
                if (number) {
                    mutableDictionary[property.jsonKey] = number;
                }
            } else if (isObjectTypeOfEncodingType(encodingType)) {
                if (isContainerTypeForObjectType(property.objectType)) {
                    CCClass *classInfo = [CCClass classWithClassObject:self.class];
                    ContainerTypeObject *containerTypeObject = classInfo.propertyNameToContainerTypeObjectMap[property.propertyName];
                    NSAssert(containerTypeObject, @"container need description");
                    if (!containerTypeObject) continue;
                    id jsonObj = [self getContainerProperty:property withContainerTypeObject:containerTypeObject];
                    if (jsonObj) {
                        mutableDictionary[property.jsonKey] = jsonObj;
                    }
                } else {
                    id jsonObj = [self getObjectProperty:property];
                    if (jsonObj) {
                        mutableDictionary[property.jsonKey] = jsonObj;
                    }
                }
            }
        }
        
        classInfo = classInfo.superClass;
    }
    return [mutableDictionary copy];
}

- (NSNumber *)getNumberProperty:(CCProperty *)property {
    switch (property.encodingType & CCEncodingTypeMask) {
        case CCEncodingTypeChar:
            return @(((char (*)(id, SEL))objc_msgSend)(self, property.getter));
        case CCEncodingTypeUnsignedChar:
            return @(((unsigned char (*)(id, SEL))objc_msgSend)(self, property.getter));
        case CCEncodingTypeInt:
            return @(((int (*)(id, SEL))objc_msgSend)(self, property.getter));
        case CCEncodingTypeUnsignedInt:
            return @(((unsigned int (*)(id, SEL))objc_msgSend)(self, property.getter));
        case CCEncodingTypeShort:
            return @(((short (*)(id, SEL))objc_msgSend)(self, property.getter));
        case CCEncodingTypeUnsignedShort:
            return @(((unsigned short (*)(id, SEL))objc_msgSend)(self, property.getter));
        case CCEncodingTypeLong:
            return @(((long (*)(id, SEL))objc_msgSend)(self, property.getter));
        case CCEncodingTypeUnsignedLong:
            return @(((unsigned long (*)(id, SEL))objc_msgSend)(self, property.getter));
        case CCEncodingTypeLongLong:
            return @(((long long (*)(id, SEL))objc_msgSend)(self, property.getter));
        case CCEncodingTypeUnsignedLongLong:
            return @(((unsigned long long (*)(id, SEL))objc_msgSend)(self, property.getter));
        case CCEncodingTypeFloat:
            return @(((float (*)(id, SEL))objc_msgSend)(self, property.getter));
        case CCEncodingTypeDouble:
            return @(((double (*)(id, SEL))objc_msgSend)(self, property.getter));
        case CCEncodingTypeBool:
            return @(((BOOL (*)(id, SEL))objc_msgSend)(self, property.getter));
        default:
            break;
    }
    return nil;
}

- (id)getObjectProperty:(CCProperty *)property {
    id obj = ((id (*)(id, SEL))objc_msgSend)(self, property.getter);
    return [self deserializeFromObject:obj fromClass:property.propertyClass withContainerTypeObject:nil];
}

- (id)getContainerProperty:(CCProperty *)property withContainerTypeObject:(ContainerTypeObject *)containerTypeObj {
    id obj = ((id (*)(id, SEL))objc_msgSend)(self, property.getter);
    return [self deserializeFromObject:obj fromClass:property.propertyClass withContainerTypeObject:containerTypeObj];
}

- (void)setNumberProperty:(CCProperty *)property withJsonObj:(id)jsonObj {
    // support NSString/NSNumber/NSNull
    if (jsonObj == [NSNull null]) {
        jsonObj = @0;
    } else if ([jsonObj isKindOfClass:[NSString class]]) {
        NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
        f.numberStyle = NSNumberFormatterDecimalStyle;
        jsonObj = [f numberFromString:jsonObj];
    }
    
    if (![jsonObj isKindOfClass:[NSNumber class]]) return;
    
    switch (property.encodingType & CCEncodingTypeMask) {
        case CCEncodingTypeChar:
            ((void (*)(id, SEL, char))objc_msgSend)(self, property.setter, [jsonObj charValue]);
            break;
        case CCEncodingTypeUnsignedChar:
            ((void (*)(id, SEL, unsigned char))objc_msgSend)(self, property.setter, [jsonObj unsignedCharValue]);
            break;
        case CCEncodingTypeInt:
            ((void (*)(id, SEL, int))objc_msgSend)(self, property.setter, [jsonObj intValue]);
            break;
        case CCEncodingTypeUnsignedInt:
            ((void (*)(id, SEL, unsigned int))objc_msgSend)(self, property.setter, [jsonObj unsignedIntValue]);
            break;
        case CCEncodingTypeShort:
            ((void (*)(id, SEL, short))objc_msgSend)(self, property.setter, [jsonObj shortValue]);
            break;
        case CCEncodingTypeUnsignedShort:
            ((void (*)(id, SEL, unsigned short))objc_msgSend)(self, property.setter, [jsonObj unsignedShortValue]);
            break;
        case CCEncodingTypeLong:
            ((void (*)(id, SEL, long))objc_msgSend)(self, property.setter, [jsonObj longValue]);
            break;
        case CCEncodingTypeUnsignedLong:
            ((void (*)(id, SEL, unsigned long))objc_msgSend)(self, property.setter, [jsonObj unsignedLongValue]);
            break;
        case CCEncodingTypeLongLong:
            ((void (*)(id, SEL, long long))objc_msgSend)(self, property.setter, [jsonObj longLongValue]);
            break;
        case CCEncodingTypeUnsignedLongLong:
            ((void (*)(id, SEL, unsigned long long))objc_msgSend)(self, property.setter, [jsonObj unsignedLongLongValue]);
            break;
        case CCEncodingTypeFloat:
            ((void (*)(id, SEL, float))objc_msgSend)(self, property.setter, [jsonObj floatValue]);
            break;
        case CCEncodingTypeDouble:
            ((void (*)(id, SEL, double))objc_msgSend)(self, property.setter, [jsonObj doubleValue]);
            break;
        case CCEncodingTypeBool:
            ((void (*)(id, SEL, bool))objc_msgSend)(self, property.setter, [jsonObj boolValue]);
            break;
        default:
            break;
    }
}

- (void)setObjectProperty:(CCProperty *)property withJsonObj:(id)jsonObj {
    id obj = [self serializeJSONObj:jsonObj toClass:property.propertyClass withContainerTypeObject:nil];
    if (obj) {
        ((void (*)(id, SEL, id))objc_msgSend)(self, property.setter, obj);
    }
}

- (void)setContainerProperty:(CCProperty *)property withJsonObj:(id)jsonObj containerTypeObject:(ContainerTypeObject *)containerTypeObj {
    id obj = [self serializeJSONObj:jsonObj toClass:property.propertyClass withContainerTypeObject:containerTypeObj];
    if (obj) {
        ((void (*)(id, SEL, id))objc_msgSend)(self, property.setter, obj);
    }
}

@end


@implementation NSArray (CC_JSON)

+ (id)ccjson_arrayWithJSON:(id)json withValueType:(ContainerTypeObject *)typeObject {
    NSArray *array = nil;
    NSData *data = nil;
    if ([json isKindOfClass:[NSArray class]]) {
        array = json;
    } else if ([json isKindOfClass:[NSString class]]) {
        data = [json dataUsingEncoding:NSUTF8StringEncoding];
    } else if ([json isKindOfClass:[NSData class]]) {
        data = json;
    }
    if (data && !array) {
        array = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    }
    if (array && [array isKindOfClass:[NSArray class]]) {
        id obj = [self ccjson_arrayWithJSONArray:array withValueType:typeObject];
        return obj;
    }
    return nil;
}

+ (id)ccjson_arrayWithJSONArray:(NSArray *)jsonArray withValueType:(ContainerTypeObject *)typeObject {
    NSMutableArray *mutableArray = [NSMutableArray array];
    for (id json in jsonArray) {
        id obj = [self serializeJSONObj:json toClass:typeObject.classObj withContainerTypeObject:typeObject];
        [mutableArray addObject:obj];
    }
    return [mutableArray copy];
}

- (NSArray *)ccjson_jsonObjectArrayWithValueType:(ContainerTypeObject *)typeObject {
    NSMutableArray *mutableArray = [NSMutableArray array];
    for (id obj in self) {
        id jsonObj = [self deserializeFromObject:obj fromClass:typeObject.classObj withContainerTypeObject:typeObject];
        [mutableArray addObject:jsonObj];
    }
    return [mutableArray copy];
}

@end


@implementation NSDictionary (CC_JSON)

+ (id)ccjson_dictionaryWithJSON:(id)json withValueType:(ContainerTypeObject *)typeObject {
    NSDictionary *dict = nil;
    NSData *data = nil;
    if ([json isKindOfClass:[NSDictionary class]]) {
        dict = json;
    } else if ([json isKindOfClass:[NSString class]]) {
        data = [json dataUsingEncoding:NSUTF8StringEncoding];
    } else if ([json isKindOfClass:[NSData class]]) {
        data = json;
    }
    if (data && !dict) {
        dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    }
    if (dict && [dict isKindOfClass:[NSDictionary class]]) {
        id obj = [self ccjson_dictionaryWithJSONDictionary:dict withValueType:typeObject];
        return obj;
    }
    return nil;
}

+ (id)ccjson_dictionaryWithJSONDictionary:(NSDictionary *)jsonDictionary withValueType:(ContainerTypeObject *)typeObject {
    NSParameterAssert(typeObject);
    if (!typeObject) {
        return nil;
    }
    NSMutableDictionary *mutableDictionary = [NSMutableDictionary dictionary];
    [jsonDictionary enumerateKeysAndObjectsUsingBlock:^(NSString *  _Nonnull key, id  _Nonnull jsonObj, BOOL * _Nonnull stop) {
        id obj = [self serializeJSONObj:jsonObj toClass:typeObject.classObj withContainerTypeObject:typeObject];
        if (obj) {
            mutableDictionary[key] = obj;
        }
    }];
    return [mutableDictionary copy];
}

+ (id)ccjson_dictionaryWithJSON:(id)json withKeyToValueType:(NSDictionary<NSString *, ContainerTypeObject *> *)keyToValueType {
    NSDictionary *dict = nil;
    NSData *data = nil;
    if ([json isKindOfClass:[NSDictionary class]]) {
        dict = json;
    } else if ([json isKindOfClass:[NSString class]]) {
        data = [json dataUsingEncoding:NSUTF8StringEncoding];
    } else if ([json isKindOfClass:[NSData class]]) {
        data = json;
    }
    if (data && !dict) {
        dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    }
    if (dict && [dict isKindOfClass:[NSDictionary class]]) {
        id obj = [self ccjson_dictionaryWithJSONDictionary:dict withKeyToValueType:keyToValueType];
        return obj;
    }
    return nil;
}

+ (id)ccjson_dictionaryWithJSONDictionary:(NSDictionary *)jsonDictionary withKeyToValueType:(NSDictionary<NSString *, ContainerTypeObject *> *)keyToValueType {
    NSParameterAssert(keyToValueType);
    if (!keyToValueType) {
        return nil;
    }
    NSMutableDictionary *mutableDictionary = [NSMutableDictionary dictionary];
    [jsonDictionary enumerateKeysAndObjectsUsingBlock:^(NSString *  _Nonnull key, id  _Nonnull jsonObj, BOOL * _Nonnull stop) {
        ContainerTypeObject *typeObject = keyToValueType[key];
        id obj = [self serializeJSONObj:jsonObj toClass:typeObject.classObj withContainerTypeObject:typeObject];
        if (obj) {
            mutableDictionary[key] = obj;
        }
    }];
    return [mutableDictionary copy];
}



- (NSDictionary *)ccjson_jsonObjectDictionaryWithValueType:(ContainerTypeObject *)typeObject {
    NSParameterAssert(typeObject);
    if (!typeObject) {
        return nil;
    }
    NSMutableDictionary *mutableDictionary = [NSMutableDictionary dictionary];
    [self enumerateKeysAndObjectsUsingBlock:^(NSString *  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        id jsonObj = [self deserializeFromObject:obj fromClass:typeObject.classObj withContainerTypeObject:typeObject];
        if (jsonObj) {
            mutableDictionary[key] = jsonObj;
        }
    }];
    return [mutableDictionary copy];
}

- (NSDictionary *)ccjson_jsonObjectDictionaryWithKeyToValueType:(NSDictionary<NSString *, ContainerTypeObject *> *)keyToValueType {
    NSParameterAssert(keyToValueType);
    if (!keyToValueType) {
        return nil;
    }
    NSMutableDictionary *mutableDictionary = [NSMutableDictionary dictionary];
    [self enumerateKeysAndObjectsUsingBlock:^(NSString *  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        ContainerTypeObject *typeObject = keyToValueType[key];
        id jsonObj = [self deserializeFromObject:obj fromClass:typeObject.classObj withContainerTypeObject:typeObject];
        if (jsonObj) {
            mutableDictionary[key] = jsonObj;
        }
    }];
    return [mutableDictionary copy];
}

@end
