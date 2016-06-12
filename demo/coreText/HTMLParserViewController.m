//
//  HTMLParserViewController.m
//  demo
//
//  Created by KudoCC on 16/6/8.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "HTMLParserViewController.h"
#import "CCHTMLParser.h"
#import "CCLabel.h"

@interface HTMLParserViewController ()

@end

@implementation HTMLParserViewController {
    CCLabel *label;
    UIView *viewDrag;
}

- (void)initView {
    [super initView];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"html"];
    NSString *htmlString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    CCHTMLParser *parser = [CCHTMLParser parserWithHTMLString:htmlString];
    NSAttributedString *attr = [parser attributedStringWithDefaultFont:[UIFont systemFontOfSize:16.0] defaultTextColor:[UIColor blackColor]];
    
    label = [[CCLabel alloc] initWithFrame:CGRectMake(10, 100, 300, 200)];
    label.layer.borderColor = [UIColor greenColor].CGColor;
    label.layer.borderWidth = Pixel(1);
    label.attributedText = attr;
    label.asyncDisplay = NO;
    [self.view addSubview:label];
    
    viewDrag = [[UIView alloc] initWithFrame:CGRectMake(label.right-10, label.bottom-10, 20, 20)];
    viewDrag.backgroundColor = [UIColor greenColor];
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragGesture:)];
    pan.maximumNumberOfTouches = 1;
    [viewDrag addGestureRecognizer:pan];
    [self.view addSubview:viewDrag];
}

- (void)dragGesture:(UIPanGestureRecognizer *)pan {
    if (pan.state == UIGestureRecognizerStateChanged) {
        CGPoint pos = [pan locationInView:self.view];
        if (pos.x-label.left > 100 && pos.y-label.top > 100) {
            label.frame = CGRectMake(label.left, label.top, pos.x-label.left, pos.y-label.top);
            viewDrag.center = pos;
        }
    }
}

@end
