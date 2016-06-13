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
    
    // font point size
    // test UIFont+CCKit
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"html"];
    NSString *htmlString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    CCHTMLConfig *config = [CCHTMLConfig defaultConfig];
    config.colorHyperlinkHighlighted = [UIColor blueColor];
    config.hyperlinkBlock = ^(NSString *href) {
        NSURL *url = [NSURL URLWithString:href];
        if (url && [[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url];
        }
    };
    CCHTMLParser *parser = [CCHTMLParser parserWithConfig:config];
    [parser parseHTMLString:htmlString];
    NSAttributedString *attr = [parser attributedStringWithDefaultFont:[UIFont systemFontOfSize:16.0] defaultTextColor:[UIColor blackColor]];
    
    label = [[CCLabel alloc] initWithFrame:CGRectMake(0, 64, ScreenWidth, ScreenHeight-64)];
    label.layer.borderColor = [UIColor greenColor].CGColor;
    label.layer.borderWidth = Pixel(1);
    label.attributedText = attr;
    label.asyncDisplay = NO;
    label.verticleAlignment = CCTextVerticalAlignmentTop;
    [self.view addSubview:label];
}

@end
