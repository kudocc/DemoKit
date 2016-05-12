//
//  UILinearGradientView.h
//  VOV
//
//  Created by KudoCC on 15/8/19.
//  Copyright (c) 2015年 KudoCC. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, UILinerGradientViewAxis) {
    UILinerGradientViewAxisX,   // 沿着X轴
    UILinerGradientViewAxisY    // 沿着Y轴
};

@interface UILinearGradientView : UIView

- (id)initWithFrame:(CGRect)frame colors:(NSArray *)colors axis:(UILinerGradientViewAxis)axis;

@end
