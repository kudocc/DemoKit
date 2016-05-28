//
//  NSObject+CC_JSON.m
//  demo
//
//  Created by KudoCC on 16/5/26.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "NSObject+CC_JSON.h"

static char kClassInfo;

@implementation NSObject (CC_JSON)

- (NSString *)ccjson_debugDescription {
    NSMutableString *mutableString = [@"class begin\n" mutableCopy];
    [mutableString appendFormat:@"class name:%@\n", self.class];
    CCClass *classInfo = [self getClassInfo];
    for (CCProperty *property in [classInfo.properties allValues]) {
        [mutableString appendFormat:@"%@ ", property.propertyName];
    }
    return mutableString;
}

#pragma mark - NSCopying

//- (id)ccjson_copyWithZone:(NSZone *)zone {
//    self.class obj = [[self.class alloc] init];
//    
//}

#pragma mark - Class info

- (void)setClassInfo:(CCClass *)class {
    objc_setAssociatedObject(self, &kClassInfo, class, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CCClass *)getClassInfo {
    CCClass *obj = objc_getAssociatedObject(self, &kClassInfo);
    return obj;
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
    if (self) {
        static dispatch_once_t onceToken;
        static NSMutableDictionary *mutableDictionary = nil;
        static dispatch_semaphore_t semaphore;
        dispatch_once(&onceToken, ^{
            mutableDictionary = [NSMutableDictionary dictionary];
            semaphore = dispatch_semaphore_create(1);
        });
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        NSString *className = NSStringFromClass(self.class);
        CCClass *classInfo = mutableDictionary[className];
        dispatch_semaphore_signal(semaphore);
        
        if (classInfo) {
            [self setClassInfo:classInfo];
        } else {
            NSDictionary *mapPropertyNameToJsonKey = nil;
            NSDictionary *mapPropertyNameToContainerTypeObject = nil;
            if ([self conformsToProtocol:@protocol(CCModel)]) {
                id<CCModel> ccmodel = (id<CCModel>)self;
                if ([ccmodel respondsToSelector:@selector(propertyNameToJsonKeyMap)]) {
                    mapPropertyNameToJsonKey = [ccmodel propertyNameToJsonKeyMap];
                }
                if ([ccmodel respondsToSelector:@selector(propertyNameToContainerTypeObjectMap)]) {
                    mapPropertyNameToContainerTypeObject = [ccmodel propertyNameToContainerTypeObjectMap];
                }
            }
            
            classInfo = [CCClass classWithRuntime:self.class
                         propertyNameToJsonKeyMap:mapPropertyNameToJsonKey
             propertyNameToContainerTypeObjectMap:mapPropertyNameToContainerTypeObject];
            
            [self setClassInfo:classInfo];
            
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            mutableDictionary[className] = classInfo;
            dispatch_semaphore_signal(semaphore);
        }
        
        [self setPropertyWithJsonDictionary:jsonDictionary];
    }
    return self;
}

- (void)setPropertyWithJsonDictionary:(NSDictionary *)jsonDictionary {
    CCClass *classInfo = [self getClassInfo];
    for (CCProperty *property in [classInfo.properties allValues]) {
        if (!property.setter || ![self respondsToSelector:property.setter]) {
            continue;
        }
        id jsonObj = jsonDictionary[property.jsonKey];
        if (!jsonObj) continue;
        
        CCEncodingType encodingType = property.encodingType;
        if (isNumberTypeOfEncodingType(encodingType)) {
            [self setNumberProperty:property withJsonObj:jsonObj];
        } else if ((encodingType & CCEncodingTypeMask) == CCEncodingTypeObject) {
            [self setObjectProperty:property withJsonObj:jsonObj];
        }
    }
}

- (NSDictionary *)ccjson_jsonObject {
    CCClass *classInfo = [self getClassInfo];
    NSMutableDictionary *mutableDictionary = [NSMutableDictionary dictionary];
    for (CCProperty *property in [classInfo.properties allValues]) {
        if (!property.getter || ![self respondsToSelector:property.getter]) {
            continue;
        }
        CCEncodingType encodingType = property.encodingType;
        if (isNumberTypeOfEncodingType(encodingType)) {
            NSNumber *number = [self getNumberProperty:property];
            if (number) {
                mutableDictionary[property.jsonKey] = number;
            }
        } else if ((encodingType & CCEncodingTypeMask) == CCEncodingTypeObject) {
            id jsonObj = [self getObjectProperty:property];
            if (jsonObj) {
                mutableDictionary[property.jsonKey] = jsonObj;
            }
        }
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
    CCClass *classInfo = [self getClassInfo];
    ContainerTypeObject *containerTypeObject = nil;
    if (isContainerTypeForObjectType(property.objectType)) {
        containerTypeObject = classInfo.propertyNameToContainerTypeObjectMap[property.propertyName];
        NSAssert(containerTypeObject, @"container need description");
        if (!containerTypeObject) return nil;
    }
    id obj = ((id (*)(id, SEL))objc_msgSend)(self, property.getter);
    return [self jsonObjectFromProperty:obj fromClass:property.propertyClass withContainerTypeObject:containerTypeObject];
}

- (void)setNumberProperty:(CCProperty *)property withJsonObj:(id)jsonObj {
    // jsonObj can be NSString/NSNumber
    if ([jsonObj isKindOfClass:[NSString class]]) {
        NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
        f.numberStyle = NSNumberFormatterDecimalStyle;
        jsonObj = [f numberFromString:jsonObj];
    }
    if ([jsonObj isKindOfClass:[NSNumber class]]) {
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
}

- (void)setObjectProperty:(CCProperty *)property withJsonObj:(id)jsonObj {
    CCClass *classInfo = [self getClassInfo];
    ContainerTypeObject *containerTypeObject = nil;
    if (isContainerTypeForObjectType(property.objectType)) {
        containerTypeObject = classInfo.propertyNameToContainerTypeObjectMap[property.propertyName];
        NSAssert(containerTypeObject, @"container need description");
        if (!containerTypeObject) return;
    }
    
    jsonObj = [self convertJsonObj:jsonObj toClass:property.propertyClass withContainerTypeObject:containerTypeObject];
    if (jsonObj) {
        ((void (*)(id, SEL, id))objc_msgSend)(self, property.setter, jsonObj);
    }
}

#pragma mark - utility

// NOTE:if type indicates its a container, then containerTypeObj describes the container, this is very important!!!!!
- (id)convertJsonObj:(id)jsonObj toClass:(Class)classObject withContainerTypeObject:(ContainerTypeObject *)containerTypeObj {
    CCObjectType type = CCObjectTypeFromClass(classObject);
    if (type == CCObjectTypeNSDate) {
        // NSNumber/NSString, it should be a timestamp
        if ([jsonObj isKindOfClass:[NSString class]] || [jsonObj isKindOfClass:[NSNumber class]]) {
            double timestamp = [jsonObj doubleValue];
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp];
            return date;
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
    } else if (type == CCObjectTypeNSString) {
        // NSString / NSNumber
        if ([jsonObj isKindOfClass:[NSNumber class]]) {
            jsonObj = [jsonObj stringValue];
        }
        if ([jsonObj isKindOfClass:[NSString class]]) {
            return jsonObj;
        }
    } else if (type == CCObjectTypeNSArray) {
        NSParameterAssert(containerTypeObj.valueClassObj);
        NSArray *array = [NSArray ccjson_arrayWithJSON:jsonObj withValueType:containerTypeObj.valueClassObj];
        return array;
    } else if (type == CCObjectTypeNSDictionary) {
        if (containerTypeObj.keyToClass) {
            NSDictionary *dict = [NSDictionary ccjson_dictionaryWithJSON:jsonObj withKeyToValueType:containerTypeObj.keyToClass];
            return dict;
        } else if (containerTypeObj.valueClassObj) {
            NSDictionary *dict = [NSDictionary ccjson_dictionaryWithJSON:jsonObj withValueType:containerTypeObj.valueClassObj];
            return dict;
        }
    } else if ([jsonObj isKindOfClass:[NSDictionary class]]) {
        // try to convert to class
        return [classObject ccjson_modelWithJSON:jsonObj];
    }
    return nil;
}

- (id)jsonObjectFromProperty:(id)obj fromClass:(Class)classObject withContainerTypeObject:(ContainerTypeObject *)containerTypeObj {
    CCObjectType type = CCObjectTypeFromClass(classObject);
    if (type == CCObjectTypeNSDate) {
        // from NSDate to NSNumber
        NSDate *date = obj;
        return @([date timeIntervalSince1970]);
    } else if (type == CCObjectTypeNSDecimalNumber ||
               type == CCObjectTypeNSNumber) {
        return obj;
    } else if (type == CCObjectTypeNSString) {
        return obj;
    } else if (type == CCObjectTypeNSArray) {
        NSParameterAssert(containerTypeObj.valueClassObj);
        return [obj ccjson_jsonObjectArrayWithValueType:containerTypeObj.valueClassObj];
    } else if (type == CCObjectTypeNSDictionary) {
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
        id obj = [self convertJsonObj:json toClass:typeObject.classObj withContainerTypeObject:typeObject];
        [mutableArray addObject:obj];
    }
    return [mutableArray copy];
}

- (NSArray *)ccjson_jsonObjectArrayWithValueType:(ContainerTypeObject *)typeObject {
    NSMutableArray *mutableArray = [NSMutableArray array];
    for (id obj in self) {
        id jsonObj = [self jsonObjectFromProperty:obj fromClass:typeObject.classObj withContainerTypeObject:typeObject];
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
        id obj = [self convertJsonObj:jsonObj toClass:typeObject.classObj withContainerTypeObject:typeObject];
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
        id obj = [self convertJsonObj:jsonObj toClass:typeObject.classObj withContainerTypeObject:typeObject];
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
        id jsonObj = [self jsonObjectFromProperty:obj fromClass:typeObject.classObj withContainerTypeObject:typeObject];
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
        id jsonObj = [self jsonObjectFromProperty:obj fromClass:typeObject.classObj withContainerTypeObject:typeObject];
        if (jsonObj) {
            mutableDictionary[key] = jsonObj;
        }
    }];
    return [mutableDictionary copy];
}

@end
