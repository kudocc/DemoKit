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

- (void)runUtilNoneSpaceFromLocation:(NSInteger)location
                   noneSpaceLocation:(NSInteger *)noneSpaceLocation
                            reachEnd:(BOOL *)end;

- (void)runUtilCharacter:(unichar)character
            fromLocation:(NSInteger)location
       noneSpaceLocation:(NSInteger *)noneSpaceLocation
                reachEnd:(BOOL *)end;

@end