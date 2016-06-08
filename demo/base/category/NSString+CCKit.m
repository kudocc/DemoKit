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

- (void)runUtilNoneSpaceFromLocation:(NSInteger)location
                   noneSpaceLocation:(NSInteger *)noneSpaceLocation
                            reachEnd:(BOOL *)end {
    [self runUtilCharacter:' ' fromLocation:location noneSpaceLocation:noneSpaceLocation reachEnd:end];
}

- (void)runUtilCharacter:(unichar)character
            fromLocation:(NSInteger)location
       noneSpaceLocation:(NSInteger *)noneSpaceLocation
                reachEnd:(BOOL *)end {
    while (location < [self length]) {
        unichar c = [self characterAtIndex:location];
        if (c != character) {
            if (noneSpaceLocation) *noneSpaceLocation = location;
            if (end) *end = NO;
            return;
        }
        ++location;
    }
    if (noneSpaceLocation) *noneSpaceLocation = location;
    if (end) *end = YES;
}


@end