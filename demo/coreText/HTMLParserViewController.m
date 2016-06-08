//
//  HTMLParserViewController.m
//  demo
//
//  Created by KudoCC on 16/6/8.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "HTMLParserViewController.h"
#import "CCHTMLParser.h"

@interface HTMLParserViewController ()

@end

@implementation HTMLParserViewController

- (void)initView {
    [super initView];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"html"];
    NSString *htmlString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    CCHTMLParser *parser = [CCHTMLParser parserWithHTMLString:htmlString];
    for (CCTagItem *item in parser.rootTags) {
        [item debugTagItem];
    }
}

@end
