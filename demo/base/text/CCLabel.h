//
//  CCLabel.h
//  demo
//
//  Created by KudoCC on 16/6/1.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCTextContainer.h"
#import "CCTextLayout.h"
#import "CCAsyncLayer.h"
#import "CCTextDefine.h"

@interface CCLabel : UIView

@property (nonatomic) BOOL asyncDisplay;

@property (nonatomic) UIFont *font;

@property (nonatomic) UIColor *textColor;

@property (nonatomic) NSString *text;

@property (nonatomic) NSAttributedString *attributedText;

@property (nonatomic) UIEdgeInsets contentInsets;

@property (nonatomic) NSInteger numberOfLines;

@property (nonatomic) CCTextVerticalAlignment verticleAlignment;

@property (nonatomic) CCTextLayout *textLayout;

@property (nonatomic) NSArray<UIBezierPath *> *exclusionPaths;

@end
