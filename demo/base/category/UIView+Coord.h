//
//  UIView+Coord.h
//  SdAccountKeyM
//
//  Created by Dev on 2/20/14.
//  Copyright (c) 2014 snda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Coord)

// Frame
@property (nonatomic) CGPoint origin;
@property (nonatomic) CGSize size;

// Frame Origin
@property (nonatomic) CGFloat x;
@property (nonatomic) CGFloat y;

// Frame Size
@property (nonatomic) CGFloat width;
@property (nonatomic) CGFloat height;

// Frame Borders
@property (nonatomic) CGFloat top;
@property (nonatomic) CGFloat left;
@property (nonatomic) CGFloat bottom;
@property (nonatomic) CGFloat right;

// Center Point
//#if !IS_IOS_DEVICE
//@property (nonatomic) CGPoint center;
//#endif
@property (nonatomic) CGFloat centerX;
@property (nonatomic) CGFloat centerY;

// Middle Point
@property (nonatomic, readonly) CGPoint middlePoint;
@property (nonatomic, readonly) CGFloat middleX;
@property (nonatomic, readonly) CGFloat middleY;

@property (nonatomic, readonly) CGFloat maxX;      ///< 最大X值
@property (nonatomic, readonly) CGFloat maxY;      ///< 最大Y值

- (void)logViewHierarchy;

@end
