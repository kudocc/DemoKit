//
//  NSString+CCKit.m
//  demo
//
//  Created by KudoCC on 16/6/8.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "NSString+CCKit.h"

@implementation NSString (FilePath)

+ (NSString *)cc_documentPath {
    NSArray *array = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [array firstObject];
}

@end


@implementation NSString (Other)

- (void)runUntilNoneSpaceFromLocation:(NSInteger)location noneSpaceLocation:(NSInteger *)noneSpaceLocation reachEnd:(BOOL *)end {
    [self runUntilCharacterSet:[[NSCharacterSet characterSetWithCharactersInString:@" "] invertedSet]
                  fromLocation:location
                 reachLocation:noneSpaceLocation
                      reachEnd:end];
}

- (void)runUntilCharacterSet:(NSCharacterSet *)characterSet
                fromLocation:(NSInteger)location
               reachLocation:(NSInteger *)reachLocation
                    reachEnd:(BOOL *)end {
    while (location < [self length]) {
        unichar c = [self characterAtIndex:location];
        if ([characterSet characterIsMember:c]) {
            if (reachLocation) *reachLocation = location;
            if (end) *end = NO;
            return;
        }
        ++location;
    }
    if (reachLocation) *reachLocation = location;
    if (end) *end = YES;
}

@end