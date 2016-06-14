//
//  NSString+CCKit.h
//  demo
//
//  Created by KudoCC on 16/6/8.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (FilePath)

+ (NSString *)cc_documentPath;

@end

@interface NSString (Other)


- (void)runUntilNoneSpaceFromLocation:(NSInteger)location
                    noneSpaceLocation:(NSInteger *)noneSpaceLocation
                             reachEnd:(BOOL *)end;

/**
 @param walk the string until we meet a character in characterSet
 @param location walk from the location
 @param reachLocation if we find a character in characterSet, the location points to that character, else the location points to the last character + 1
 */
- (void)runUntilCharacterSet:(NSCharacterSet *)characterSet
                fromLocation:(NSInteger)location
               reachLocation:(NSInteger *)reachLocation
                    reachEnd:(BOOL *)end;

@end