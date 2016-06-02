//
//  CCLabel.h
//  demo
//
//  Created by KudoCC on 16/6/1.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCTextLayout.h"
#import "CCAsyncLayer.h"

@interface CCLabel : UIView

@property (nonatomic) NSAttributedString *attributedText;

@property (nonatomic) CCTextLayout *textLayout;

@end
