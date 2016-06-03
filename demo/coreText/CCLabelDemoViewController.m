//
//  CCLabelDemoViewController.m
//  demo
//
//  Created by KudoCC on 16/6/3.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "CCLabelDemoViewController.h"
#import "CCLabel.h"

@interface CCLabelDemoViewController ()
@end

@implementation CCLabelDemoViewController {
    CCLabel *label;
    
    UIView *viewDrag;
}

- (void)initView {
    label = [[CCLabel alloc] initWithFrame:CGRectMake(10, 100, 200, 200)];
    label.text = @"Good to see you again, but I'd like to know how you come here. Well 你奶奶的顿的，怎么搞的跟你有什么关系，马上就要周末了，我就想玩一会还要你管么，哼哼，呵呵o(￣ヘ￣o#)";
    [self.view addSubview:label];
    label.asyncDisplay = NO;
    
    viewDrag = [[UIView alloc] initWithFrame:CGRectMake(label.right-22, label.bottom-22, 44, 44)];
    viewDrag.backgroundColor = [UIColor greenColor];
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragGesture:)];
    pan.maximumNumberOfTouches = 1;
    [viewDrag addGestureRecognizer:pan];
    [self.view addSubview:viewDrag];
}

- (void)dragGesture:(UIPanGestureRecognizer *)pan {
    if (pan.state == UIGestureRecognizerStateChanged) {
        CGPoint pos = [pan locationInView:self.view];
        if (pos.x-label.left > 10 && pos.y-label.top > 10) {
            label.frame = CGRectMake(label.left, label.top, pos.x-label.left, pos.y-label.top);
            viewDrag.center = pos;
        }
        
    }
}

#pragma mark - UIGestureRecognizerDelegate

@end
