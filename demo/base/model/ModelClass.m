//
//  ModelClass.m
//  demo
//
//  Created by KudoCC on 16/5/26.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "ModelClass.h"

CCEncodingType CCEncodingTypeFromChar(const char *ptype) {
    char type = ptype[0];
    CCEncodingType encodingType = CCEncodingTypeUnknown;
    switch (type) {
        case 'c':// A char
            encodingType = CCEncodingTypeChar;
            break;
        case 'i':// A int
            encodingType = CCEncodingTypeInt;
            break;
        case 's':// A short
            encodingType = CCEncodingTypeShort;
            break;
        case 'l':// A long, l is treated as a 32-bit quantity on 64-bit programs.
            encodingType = CCEncodingTypeLong;
            break;
        case 'q':// A long long
            encodingType = CCEncodingTypeLongLong;
            break;
        case 'C':// An unsigned char
            encodingType = CCEncodingTypeUnsignedChar;
            break;
        case 'I':// An unsigned int
            encodingType = CCEncodingTypeUnsignedInt;
            break;
        case 'S':// An unsigned short
            encodingType = CCEncodingTypeUnsignedShort;
            break;
        case 'L':// An unsigned long
            encodingType = CCEncodingTypeUnsignedLong;
            break;
        case 'Q':// An unsigned long long
            encodingType = CCEncodingTypeUnsignedLongLong;
            break;
        case 'f':// A float
            encodingType = CCEncodingTypeFloat;
            break;
        case 'd':// A double
            encodingType = CCEncodingTypeDouble;
            break;
        case 'B':// A C++ bool or a C99 _Bool, BOOL and bool are all B.
            encodingType = CCEncodingTypeBool;
            break;
        case 'v':// A void
            encodingType = CCEncodingTypeVoid;
            break;
        case '*':// A character string(char *)
            encodingType = CCEncodingTypeCharacterString;
            break;
        case '@':// An object
            encodingType = CCEncodingTypeObject;
            break;
        case '#':// A class object (Class)
            encodingType = CCEncodingTypeClassObject;
            break;
        case ':':// A method selector
            encodingType = CCEncodingTypeMethodSelector;
            break;
        case '[':// An array
            encodingType = CCEncodingTypeArray;
            break;
        case '{':// A structure
            encodingType = CCEncodingTypeStruct;
            break;
        case '(':// A union
            encodingType = CCEncodingTypeUnion;
            break;
        case 'b':// A bit field of num bits
            encodingType = CCEncodingTypebnum;
            break;
        case '^':// A pointer to type
            encodingType = CCEncodingTypePointer;
            break;
        default:
            encodingType = CCEncodingTypeUnknown;
            break;
    }
    return encodingType;
}

CCEncodingType CCEncodingPropertyType(CCEncodingType type) {
    return type & CCEncodingTypePropertyMask;
}

CCObjectType CCObjectTypeFromClass(Class classObj) {
    if (classObj == [NSDecimalNumber class]) {
        return CCObjectTypeNSDecimalNumber;
    } else if (classObj == [NSNumber class]) {
        return CCObjectTypeNSNumber;
    } else if (classObj == [NSMutableString class]) {
        return CCObjectTypeNSMutableString;
    } else if (classObj == [NSString class]) {
        return CCObjectTypeNSString;
    } else if (classObj == [NSDate class]) {
        return CCObjectTypeNSDate;
    } else if (classObj == [NSMutableArray class]) {
        return CCObjectTypeNSMutableArray;
    } else if (classObj == [NSArray class]) {
        return CCObjectTypeNSArray;
    } else if (classObj == [NSMutableDictionary class]) {
        return CCObjectTypeNSMutableDictionary;
    } else if (classObj == [NSDictionary class]) {
        return CCObjectTypeNSDictionary;
    }
    return CCObjectTypeNotSupport;
}

BOOL isNumberTypeOfEncodingType(CCEncodingType type) {
    type = CCEncodingTypeMask & type;
    if (type >= CCEncodingTypeChar && type <= CCEncodingTypeDouble) {
        return YES;
    }
    return NO;
}

BOOL isContainerTypeForObjectType(CCObjectType type) {
    type = CCEncodingTypeMask & type;
    if (type == CCObjectTypeNSArray ||
        type == CCObjectTypeNSMutableArray ||
        type == CCObjectTypeNSDictionary ||
        type == CCObjectTypeNSMutableDictionary) {
        return YES;
    }
    return NO;
}

@implementation ContainerTypeObject

+ (id)containerTypeObjectWithClass:(Class)classObj {
    ContainerTypeObject *o = [[self alloc] initWithClass:classObj];
    return o;
}

- (id)initWithClass:(Class)classObj {
    self = [super init];
    if (self) {
        _classObj = classObj;
    }
    return self;
}

@end

@interface CCClass ()

@property (nonatomic, readwrite) NSDictionary<NSString *, CCProperty *> *properties;

@property (nonatomic, readwrite) NSDictionary<NSString *, NSString *> *propertyNameToJsonKeyMap;
@property (nonatomic, readwrite) NSDictionary<NSString *, ContainerTypeObject *> *propertyNameToContainerTypeObjectMap;

@end

@implementation CCClass

+ (CCClass *)classWithRuntime:(Class)classObject
     propertyNameToJsonKeyMap:(NSDictionary<NSString *, NSString *> *)propertyNameToJsonKeyMap
propertyNameToContainerTypeObjectMap:(NSDictionary<NSString *, ContainerTypeObject *> *)propertyNameToContainerTypeObjectMap {
    CCClass *c = [[CCClass alloc] init];
    c.propertyNameToJsonKeyMap = [propertyNameToJsonKeyMap copy];
    c.propertyNameToContainerTypeObjectMap = [propertyNameToContainerTypeObjectMap copy];
    
    NSMutableDictionary *mutableDictionary = [NSMutableDictionary dictionary];
    unsigned int propertyCount = 0;
    objc_property_t *propertyList = class_copyPropertyList(classObject, &propertyCount);
    if (propertyList) {
        for (unsigned int i = 0; i < propertyCount; ++i) {
            objc_property_t property = *(propertyList + i);
            CCProperty *propertyObj = [CCProperty propertyWithRuntime:property];
            NSString *jsonKey = propertyNameToJsonKeyMap[propertyObj.propertyName];
            if (jsonKey) {
                propertyObj.jsonKey = jsonKey;
            } else {
                propertyObj.jsonKey = propertyObj.propertyName;
            }
            mutableDictionary[propertyObj.jsonKey] = propertyObj;
        }
        free(propertyList);
    }
    c.properties = [mutableDictionary copy];
    return c;
}

@end


@interface CCProperty ()

@end

@implementation CCProperty

+ (CCProperty *)propertyWithRuntime:(objc_property_t)objc_property {
    CCProperty *property = [[CCProperty alloc] init];
    const char *propertyName = property_getName(objc_property);
    property.propertyName = [NSString stringWithUTF8String:propertyName];
    
    unsigned int attributeCount = 0;
    objc_property_attribute_t *attributeList = property_copyAttributeList(objc_property, &attributeCount);
    for (unsigned int j = 0; j < attributeCount; ++j) {
        objc_property_attribute_t attribute = *(attributeList + j);
        NSString *attributeName = [NSString stringWithUTF8String:attribute.name];
        if ([attributeName isEqualToString:@"T"]) {
            CCEncodingType encodingType = CCEncodingTypeFromChar(attribute.value);
            property.encodingType = encodingType;
            if (encodingType == CCEncodingTypeObject) {
                NSString *typeName = [NSString stringWithUTF8String:attribute.value];
                NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:@"@\""];
                NSString *objectType = [typeName stringByTrimmingCharactersInSet:set];
                Class propertyClass = NSClassFromString(objectType);
                if (propertyClass) {
                    property.propertyClass = propertyClass;
                }
                property.objectType = CCObjectTypeFromClass(propertyClass);
            }
        } else if ([attributeName isEqualToString:@"R"]) {
            // readonly
            property.encodingType |= CCEncodingTypePropertyReadonly;
        } else if ([attributeName isEqualToString:@"C"]) {
            // copy
            property.encodingType |= CCEncodingTypePropertyCopy;
        } else if ([attributeName isEqualToString:@"&"]) {
            // retain
            property.encodingType |= CCEncodingTypePropertyRetain;
        } else if ([attributeName isEqualToString:@"N"]) {
            // nonatomic
            property.encodingType |= CCEncodingTypePropertyNonatomic;
        } else if ([attributeName isEqualToString:@"G"]) {
            // custom getter
            property.encodingType |= CCEncodingTypePropertyCustomGetter;
            NSString *value = [NSString stringWithUTF8String:attribute.value];
            property.getterName = value;
        } else if ([attributeName isEqualToString:@"S"]) {
            // custom setter
            property.encodingType |= CCEncodingTypePropertyCustomSetter;
            NSString *value = [NSString stringWithUTF8String:attribute.value];
            property.setterName = value;
        } else if ([attributeName isEqualToString:@"D"]) {
            // dynamic
            property.encodingType |= CCEncodingTypePropertyDynamic;
        } else if ([attributeName isEqualToString:@"W"]) {
            // weak
            property.encodingType |= CCEncodingTypePropertyWeak;
        }
    }
    if (attributeList) {
        free(attributeList);
    }
    
    if (!property.getterName && [property.propertyName length] > 0) {
        NSString *getterName = property.propertyName;
        property.getterName = getterName;
    }
    
    if (!property.setterName &&
        [property.propertyName length] > 0 &&
        (property.encodingType & CCEncodingTypePropertyReadonly) != CCEncodingTypePropertyReadonly) {
        NSString *first = [[property.propertyName substringToIndex:1] uppercaseString];
        NSString *left = [property.propertyName substringFromIndex:1];
        NSString *setterName = [NSString stringWithFormat:@"set%@%@:", first, left];
        property.setterName = setterName;
    }
    
    return property;
}

- (SEL)getter {
    if (!_getterName) {
        return nil;
    }
    return NSSelectorFromString(_getterName);
}

- (SEL)setter {
    if (!_setterName) {
        return nil;
    }
    return NSSelectorFromString(_setterName);
}

@end
