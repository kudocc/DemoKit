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

- (void)cc_runUntilNoneSpaceFromLocation:(NSInteger)location noneSpaceLocation:(NSInteger *)noneSpaceLocation reachEnd:(BOOL *)end {
    [self cc_runUntilCharacterSet:[[NSCharacterSet characterSetWithCharactersInString:@" "] invertedSet]
                  fromLocation:location
                 reachLocation:noneSpaceLocation
                      reachEnd:end];
}

- (void)cc_runUntilCharacterSet:(NSCharacterSet *)characterSet fromLocation:(NSInteger)location reachLocation:(NSInteger *)reachLocation reachEnd:(BOOL *)end {
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

- (NSString *)cc_stringByRemovingCharactersInCharacterSet:(NSCharacterSet *)characterSet {
    NSArray *array = [self componentsSeparatedByCharactersInSet:characterSet];
    return [array componentsJoinedByString:@""];
}

@end


@implementation NSMutableString (CCKit)

- (void)cc_deleteCharacterInCharacterSet:(NSCharacterSet *)characterSet {
    NSRange range = NSMakeRange(NSNotFound, 0);
    NSInteger i = 0;
    while (i < self.length) {
        for (; i < self.length; ++i) {
            unichar c = [self characterAtIndex:i];
            if ([characterSet characterIsMember:c]) {
                if (range.location == NSNotFound) {
                    range.location = i;
                    range.length = 1;
                } else {
                    ++range.length;
                }
            } else if (range.location != NSNotFound) {
                [self deleteCharactersInRange:range];
                
                // begin next walk from i
                i = range.location;
                
                // reset range
                range.location = NSNotFound;
                range.length = 0;
                
                break;
            }
        }
    }
    if (range.location != NSNotFound) {
        [self deleteCharactersInRange:range];
    }
}

@end