//
//  CCTextContainer.h
//  demo
//
//  Created by KudoCC on 16/6/3.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CCTextContainer : NSObject <NSCopying>

+ (CCTextContainer *)textContainerWithContentSize:(CGSize)contentSize contentInsets:(UIEdgeInsets)contentInsets;

@property (nonatomic) CGSize contentSize;
@property (nonatomic) UIEdgeInsets contentInsets;

/// default is 0, no limit
@property (nonatomic) NSInteger maxNumberOfLines;

@end
