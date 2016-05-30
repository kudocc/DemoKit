//
//  JsonObjectAndModelViewController.m
//  demo
//
//  Created by KudoCC on 16/5/28.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "JsonObjectAndModelViewController.h"
#import "NSObject+CCModel.h"

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
    return [self ccmodel_copyWithZone:zone];
}
@end


@interface People : NSObject
@property NSString *name;
@property int age;
@end
@implementation People
@end

@interface Student : People <CCModel>
@property int grade;
@end
@implementation Student
+ (NSDictionary<NSString *, NSString *> *)propertyNameToJsonKeyMap {
    return @{@"grade":@"g"};
}
@end

@interface Teacher : People
@property int subject;
@end
@implementation Teacher
@end

@interface School : NSObject <CCModel>
/// two keys, the first is @"student", value is array of Student
/// the second is @"teacher", value is array of Teacher
@property NSDictionary *people;
@end
@implementation School
+ (NSDictionary<NSString *, ContainerTypeObject *> *)propertyNameToContainerTypeObjectMap {
    ContainerTypeObject *countObj = [[ContainerTypeObject alloc] initWithClass:[NSNumber class]];
    
    ContainerTypeObject *arrayStudent = [ContainerTypeObject arrayContainerTypeObjectWithValueClass:[Student class]];
    ContainerTypeObject *arrayTeacher = [ContainerTypeObject arrayContainerTypeObjectWithValueClass:[Teacher class]];
    
    ContainerTypeObject *dictStudent = [ContainerTypeObject dictionaryContainerTypeObjectWithKeyToValueClass:@{@"count":countObj, @"value":arrayStudent}];
    ContainerTypeObject *dictTeacher = [ContainerTypeObject dictionaryContainerTypeObjectWithKeyToValueClass:@{@"count":countObj, @"value":arrayTeacher}];
    
    ContainerTypeObject *dictPeople = [ContainerTypeObject dictionaryContainerTypeObjectWithKeyToValueClass:@{@"student":dictStudent, @"teacher":dictTeacher}];
    
    return @{@"people": dictPeople};
}
@end

@implementation JsonObjectAndModelViewController

- (void)testScalarNumberModel {
    NSString *jsonString =
    @"{\
    \"charTest\":1,\
    \"ucharTest\":2,\
    \"intTest\":3,\
    \"uintTest\":4,\
    \"shortTest\":5,\
    \"ushortTest\":6,\
    \"longTest\":7,\
    \"ulongTest\":8,\
    \"llongTest\":9,\
    \"ullongTest\":10,\
    \"floatTest\":122.222,\
    \"doubleTest\":1333.333}";
    
    id model = [ScalarNumberModel ccmodel_modelWithJSON:jsonString];
    NSLog(@"%@, %@", NSStringFromSelector(_cmd), [model ccmodel_debugDescription]);
    NSDictionary *dictModel = [model ccmodel_jsonObjectDictionary];
    NSLog(@"%@, %@", NSStringFromSelector(_cmd), dictModel);
}

- (void)testSimpleObjectModel {
    NSString *jsonString = @"{\"name\":\"kudo\", \"age\":17, \"g\":3}";
    id model = [Student ccmodel_modelWithJSON:jsonString];
    NSLog(@"%@, %@", NSStringFromSelector(_cmd), [model ccmodel_debugDescription]);
    NSDictionary *dictModel = [model ccmodel_jsonObjectDictionary];
    NSLog(@"%@, %@", NSStringFromSelector(_cmd), dictModel);
}

- (void)testSimpleArray {
    NSString *jsonString = @"[1, 2, 3, 4, 5]";
    ContainerTypeObject *container = [ContainerTypeObject containerTypeObjectWithClass:[NSNumber class]];
    NSArray *array = [NSArray ccmodel_arrayWithJSON:jsonString withValueType:container];
    NSLog(@"%@, %@", NSStringFromSelector(_cmd), array);
    NSArray *arrayModel = [array ccmodel_jsonObjectArrayWithValueType:container];
    NSLog(@"%@, %@", NSStringFromSelector(_cmd), arrayModel);
}

- (void)testNestedArray {
    // nested array
    NSString *jsonString = @"[[1, 2, 3], [4, 5, 6]]";
    ContainerTypeObject *container = [ContainerTypeObject arrayContainerTypeObjectWithValueClass:[NSNumber class]];
    NSArray *array = [NSArray ccmodel_arrayWithJSON:jsonString withValueType:container];
    NSLog(@"%@, %@", NSStringFromSelector(_cmd), array);
    NSArray *arrayModel = [array ccmodel_jsonObjectArrayWithValueType:container];
    NSLog(@"%@, arrayModel:%@", NSStringFromSelector(_cmd), arrayModel);
}

- (void)testNestedArrayWithModel {
    // nested array with Model
    NSString *jsonString =
    @"[\
        [\
            {\"name\":\"kudo\", \"age\":17, \"g\":3},\
            {\"name\":\"lan\", \"age\":17, \"g\":3}\
        ],\
        [\
            {\"name\":\"conan\", \"age\":7, \"g\":1},\
            {\"name\":\"bumei\", \"age\":7, \"g\":1}\
        ]\
    ]";
    ContainerTypeObject *container = [ContainerTypeObject arrayContainerTypeObjectWithValueClass:[Student class]];
    NSArray *array = [NSArray ccmodel_arrayWithJSON:jsonString withValueType:container];
    NSLog(@"%@, %@", NSStringFromSelector(_cmd), array);
}

- (void)testSimpleDictionary {
    // simple dictionary
    NSString *jsonString = @"{\"name\":\"KudoCC\", \"count\":2}";
    ContainerTypeObject *objectForName = [ContainerTypeObject containerTypeObjectWithClass:[NSString class]];
    ContainerTypeObject *objectForCount = [ContainerTypeObject containerTypeObjectWithClass:[NSNumber class]];
    NSDictionary *dictionary = [NSDictionary ccmodel_dictionaryWithJSON:jsonString withKeyToValueType:@{@"name":objectForName, @"count":objectForCount}];
    NSLog(@"%@, %@", NSStringFromSelector(_cmd), dictionary);
    NSDictionary *dictModel = [dictionary ccmodel_jsonObjectDictionaryWithKeyToValueType:@{@"name":objectForName, @"count":objectForCount}];
    NSLog(@"%@, %@", NSStringFromSelector(_cmd), dictModel);
}

- (void)testNestedDictionary {
    NSString *jsonString =
    @"{\
        \"name\":\"KudoCC\",\
        \"habbit\":\
            {\
                \"count\":10,\
                \"value\":\
                    [\"basketball\",\"reading\", \"football\"]\
            }\
    }";
    ContainerTypeObject *objectForName = [ContainerTypeObject containerTypeObjectWithClass:[NSString class]];
    ContainerTypeObject *objectForHabbit = [ContainerTypeObject containerTypeObjectWithClass:[NSDictionary class]];
    ContainerTypeObject *objectForHabbitCount = [ContainerTypeObject containerTypeObjectWithClass:[NSNumber class]];
    ContainerTypeObject *objectForHabbitValue = [ContainerTypeObject arrayContainerTypeObjectWithValueClass:[NSString class]];
    objectForHabbit.keyToClass = @{@"count":objectForHabbitCount, @"value":objectForHabbitValue};
    NSDictionary *dictionary = [NSDictionary ccmodel_dictionaryWithJSON:jsonString withKeyToValueType:@{@"name":objectForName, @"habbit":objectForHabbit}];
    NSLog(@"%@, %@", NSStringFromSelector(_cmd), dictionary);
    NSDictionary *dictModel = [dictionary ccmodel_jsonObjectDictionaryWithKeyToValueType:@{@"name":objectForName, @"habbit":objectForHabbit}];
    NSLog(@"%@, %@", NSStringFromSelector(_cmd), dictModel);
}

- (void)testPeople {
    NSString *jsonString =
    @"{\
    \"people\":\
        {\
            \"student\":\
                {\
                    \"count\":2,\
                    \"value\":\
                        [\
                            {\"name\":\"kudo\", \"age\":17, \"g\":3},\
                            {\"name\":\"lan\", \"age\":17, \"g\":3}\
                        ]\
                },\
            \"teacher\":\
                {\
                    \"count\":2, \
                    \"value\":\
                        [\
                            {\"name\":\"zhidi\", \"age\":27, \"subject\":4},\
                            {\"name\":\"maoli\", \"age\":28, \"subject\":5}\
                        ]\
                }\
        }\
    }";
    id model = [School ccmodel_modelWithJSON:jsonString];
    NSLog(@"%@, %@", NSStringFromSelector(_cmd), [model ccmodel_debugDescription]);
    NSDictionary *dictModel = [model ccmodel_jsonObjectDictionary];
    NSLog(@"%@, %@", NSStringFromSelector(_cmd), dictModel);
}

- (void)initView {
    [self testScalarNumberModel];
    
    [self testSimpleObjectModel];
    
    [self testSimpleArray];
    
    [self testNestedArray];
    
    [self testNestedArrayWithModel];
    
    [self testSimpleDictionary];
    
    [self testNestedDictionary];
    
    [self testPeople];
}

@end
