//
//  JsonObjectAndModelViewController.m
//  demo
//
//  Created by KudoCC on 16/5/28.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "JsonObjectAndModelViewController.h"

#import "NSObject+CC_JSON.h"
#import "NSObject+CCKit.h"

@interface ScalarNumberModel : NSObject <NSCopying>

@property char charTest;
@property unsigned char ucharTest;
@property int intTest;
@property unsigned int uintTest;
@property short shortTest;
@property unsigned short ushortTest;
@property long longTest;
@property unsigned long ulongTest;
@property long long llongTest;
@property unsigned long long ullongTest;
@property float floatTest;
@property double doubleTest;

@end

@implementation ScalarNumberModel

- (id)copyWithZone:(NSZone *)zone {
    return [self ccjson_copyWithZone:zone];
}

@end


@interface NSBaseObject : NSObject

@property NSString *name;

@end

@implementation NSBaseObject

@end

@interface NSObjectModel : NSBaseObject

@property NSString *stringCount;
@property NSNumber *numCount;
@property NSNumber *numCountFromString;

@end

@implementation NSObjectModel
@end


@interface NSObjectModelPropertyKey : NSObject <CCModel>

@property NSString *myName;
@property NSString *count;

@end

@implementation NSObjectModelPropertyKey

+ (NSDictionary<NSString *, NSString *> *)propertyNameToJsonKeyMap {
    return @{@"myName":@"name", @"count":@"numCountFromString"};
}

@end


@interface NSObjectModelContainer : NSObject <CCModel>

@property NSArray<NSObjectModelPropertyKey *> *arrayModel;
@property NSDictionary<NSString *, NSObjectModelPropertyKey *> *dictModel;

@end

@implementation NSObjectModelContainer
+ (NSDictionary<NSString *, ContainerTypeObject *> *)propertyNameToContainerTypeObjectMap {
    ContainerTypeObject *objArray = [ContainerTypeObject arrayContainerTypeObjectWithValueClass:[NSObjectModelPropertyKey class]];
    ContainerTypeObject *objDict = [ContainerTypeObject dictionaryContainerTypeObjectWithValueClass:[NSObjectModelPropertyKey class]];
    return @{@"arrayModel": objArray, @"dictModel": objDict};
}
@end

@implementation JsonObjectAndModelViewController

- (void)testScalarNumberModel {
    NSString *jsonString = @"{\"charTest\":1, \"ucharTest\":2, \"intTest\":3, \"uintTest\":4, \"shortTest\":5, \"ushortTest\":6, \"longTest\":7, \"ulongTest\":8, \"llongTest\":9, \"ullongTest\":10, \"floatTest\":122.222, \"doubleTest\":1333.333}";
    id model = [ScalarNumberModel ccjson_modelWithJSON:jsonString];
    NSLog(@"%@, %@", NSStringFromSelector(_cmd), [model ccjson_debugDescription]);
    NSDictionary *dictModel = [model ccjson_jsonObject];
    NSLog(@"%@, %@", NSStringFromSelector(_cmd), dictModel);
}

- (void)testSimpleObjectModel {
    NSString *jsonString = @"{\"name\":\"GoodName, 苑睿\", \"stringCount\":-10, \"numCount\":10, \"numCountFromString\":\"20\"}";
    id model = [NSObjectModel ccjson_modelWithJSON:jsonString];
    NSLog(@"%@, %@", NSStringFromSelector(_cmd), [model ccjson_debugDescription]);
    NSDictionary *dictModel = [model ccjson_jsonObject];
    NSLog(@"%@, %@", NSStringFromSelector(_cmd), dictModel);
}

- (void)testPropertyKeyObjectModel {
    NSString *jsonString = @"{\"name\":\"GoodName, 苑睿\", \"stringCount\":-10, \"numCount\":10, \"numCountFromString\":\"20\"}";
    id model = [NSObjectModelPropertyKey ccjson_modelWithJSON:jsonString];
    NSLog(@"%@, %@", NSStringFromSelector(_cmd), [model ccjson_debugDescription]);
    NSDictionary *dictModel = [model ccjson_jsonObject];
    NSLog(@"%@, %@", NSStringFromSelector(_cmd), dictModel);
}

- (void)testSimpleArray {
    NSString *jsonString = @"[1, 2, 3, 4, 5]";
    ContainerTypeObject *container = [ContainerTypeObject containerTypeObjectWithClass:[NSNumber class]];
    NSArray *array = [NSArray ccjson_arrayWithJSON:jsonString withValueType:container];
    NSLog(@"%@, %@", NSStringFromSelector(_cmd), array);
    NSArray *arrayModel = [array ccjson_jsonObjectArrayWithValueType:container];
    NSLog(@"%@, %@", NSStringFromSelector(_cmd), arrayModel);
}

- (void)testNestedArray {
    // nested array
    NSString *jsonString = @"[[1, 2, 3], [4, 5, 6]]";
    ContainerTypeObject *container = [ContainerTypeObject arrayContainerTypeObjectWithValueClass:[NSNumber class]];
    NSArray *array = [NSArray ccjson_arrayWithJSON:jsonString withValueType:container];
    NSLog(@"%@, %@", NSStringFromSelector(_cmd), array);
    NSArray *arrayModel = [array ccjson_jsonObjectArrayWithValueType:container];
    NSLog(@"%@, arrayModel:%@", NSStringFromSelector(_cmd), arrayModel);
}

- (void)testNestedArrayWithModel {
    // nested array with Model
    NSString *jsonString = @"[[{\"name\":\"GoodName, 苑睿\", \"stringCount\":-10, \"numCount\":10, \"numCountFromString\":\"20\"}, {\"name\":\"GoodName, 苑睿\", \"stringCount\":-10, \"numCount\":10, \"numCountFromString\":\"20\"}], [{\"name\":\"GoodName, 苑睿\", \"stringCount\":-10, \"numCount\":10, \"numCountFromString\":\"20\"}, {\"name\":\"GoodName, 苑睿\", \"stringCount\":-10, \"numCount\":10, \"numCountFromString\":\"20\"}]]";
    ContainerTypeObject *container = [ContainerTypeObject arrayContainerTypeObjectWithValueClass:[NSObjectModelPropertyKey class]];
    NSArray *array = [NSArray ccjson_arrayWithJSON:jsonString withValueType:container];
    NSLog(@"%@, %@", NSStringFromSelector(_cmd), array);
}

- (void)testSimpleDictionary {
    // simple dictionary
    NSString *jsonString = @"{\"name\":\"KudoCC\", \"count\":2}";
    ContainerTypeObject *objectForName = [ContainerTypeObject containerTypeObjectWithClass:[NSString class]];
    ContainerTypeObject *objectForCount = [ContainerTypeObject containerTypeObjectWithClass:[NSNumber class]];
    NSDictionary *dictionary = [NSDictionary ccjson_dictionaryWithJSON:jsonString withKeyToValueType:@{@"name":objectForName, @"count":objectForCount}];
    NSLog(@"%@, %@", NSStringFromSelector(_cmd), dictionary);
    NSDictionary *dictModel = [dictionary ccjson_jsonObjectDictionaryWithKeyToValueType:@{@"name":objectForName, @"count":objectForCount}];
    NSLog(@"%@, %@", NSStringFromSelector(_cmd), dictModel);
}

- (void)testNestedDictionary {
    /* nested dictionary
     habbit =     {
     count = 10;
     value = (
     basketball,
     reading,
     football
     );
     };
     name = KudoCC;
     */
    NSString *jsonString = @"{\"name\":\"KudoCC\", \"habbit\":{\"count\":10, \"value\":[\"basketball\", \"reading\", \"football\"]}}";
    ContainerTypeObject *objectForName = [ContainerTypeObject containerTypeObjectWithClass:[NSString class]];
    ContainerTypeObject *objectForHabbit = [ContainerTypeObject containerTypeObjectWithClass:[NSDictionary class]];
    ContainerTypeObject *objectForHabbitCount = [ContainerTypeObject containerTypeObjectWithClass:[NSNumber class]];
    ContainerTypeObject *objectForHabbitValue = [ContainerTypeObject arrayContainerTypeObjectWithValueClass:[NSString class]];
    objectForHabbit.keyToClass = @{@"count":objectForHabbitCount, @"value":objectForHabbitValue};
    NSDictionary *dictionary = [NSDictionary ccjson_dictionaryWithJSON:jsonString withKeyToValueType:@{@"name":objectForName, @"habbit":objectForHabbit}];
    NSLog(@"%@, %@", NSStringFromSelector(_cmd), dictionary);
    NSDictionary *dictModel = [dictionary ccjson_jsonObjectDictionaryWithKeyToValueType:@{@"name":objectForName, @"habbit":objectForHabbit}];
    NSLog(@"%@, %@", NSStringFromSelector(_cmd), dictModel);
}

- (void)testObjectWithArrayDictionary {
    // object with array and dictionary
    NSString *jsonString = @"{\"arrayModel\":[{\"name\":\"GoodName, 苑睿\", \"numCountFromString\":\"20\"}, {\"name\":\"GoodName, 苑睿\", \"numCountFromString\":\"20\"}], \"dictModel\":{\"goodboy\":{\"name\":\"GoodName, 苑睿\", \"numCountFromString\":\"20\"}, \"bad boy\":{\"name\":\"GoodName, 苑睿\", \"numCountFromString\":\"20\"}}}";
    id model = [NSObjectModelContainer ccjson_modelWithJSON:jsonString];
    NSLog(@"%@, %@", NSStringFromSelector(_cmd), [model ccjson_debugDescription]);
    NSDictionary *dictModel = [model ccjson_jsonObject];
    NSLog(@"%@, %@", NSStringFromSelector(_cmd), dictModel);
}

- (void)initView {
    [self testScalarNumberModel];
    
    [self testSimpleObjectModel];
    
    [self testPropertyKeyObjectModel];
    
    [self testSimpleArray];
    
    [self testNestedArray];
    
    [self testNestedArrayWithModel];
    
    [self testSimpleDictionary];
    
    [self testNestedDictionary];
    
    [self testObjectWithArrayDictionary];
}

@end
