//
//  CCTextRunDelegate.h
//  demo
//
//  Created by KudoCC on 16/6/3.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>
#import "CCTextDefine.h"

@interface CCTextRunDelegate : NSObject

+ (CCTextRunDelegate *)textRunDelegateWithContent:(id)content position:(CCTextAttachmentPosition)position;

- (CTRunDelegateRef)createCTRunDelegateRef;

@property (nonatomic) id content;
@property (nonatomic) CCTextAttachmentPosition position;
@property (nonatomic, readonly) CGFloat width;
@property (nonatomic, readonly) CGFloat ascent;
@property (nonatomic, readonly) CGFloat descent;

@end
