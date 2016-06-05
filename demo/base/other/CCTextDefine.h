//
//  CCTextDefine.h
//  demo
//
//  Created by KudoCC on 16/6/3.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const CCAttachmentCharacter;

#define CCMainThreadBlock(block) \
    if ([NSThread isMainThread]) {\
        block();\
    } else {\
        dispatch_async(dispatch_get_main_queue(), ^() {\
            block();\
        });\
    }

typedef NS_ENUM(NSUInteger, CCTextAttachmentPosition) {
    CCTextAttachmentPositionTop,
    CCTextAttachmentPositionCenter,
    CCTextAttachmentPositionBottom
};

extern NSString *const CCAttachmentAttributeName;


@interface CCTextAttachment : NSObject

+ (id)textAttachmentWithContent:(id)content;

@property (nonatomic) id content;
@property (nonatomic, readonly) CGSize contentSize;

@property (nonatomic) UIViewContentMode contentMode;
@property (nonatomic) UIEdgeInsets contentInsets;

@end
