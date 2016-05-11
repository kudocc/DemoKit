//
//  NSString+File.m
//  audio
//
//  Created by KudoCC on 15/9/24.
//  Copyright © 2015年 KudoCC. All rights reserved.
//

#import "NSString+File.h"

@implementation NSString (File)

+ (NSString *)documentPath {
    NSArray *array = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [array firstObject];
}

@end
