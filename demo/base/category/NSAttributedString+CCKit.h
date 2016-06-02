//
//  NSAttributedString+CCKit.h
//  demo
//
//  Created by KudoCC on 16/6/1.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSAttributedString (CCKit)

@end

@interface NSMutableAttributedString (CCKit)

@property (nonatomic) UIFont *font;
- (void)cc_setFont:(UIFont *)font range:(NSRange)range;

@end
