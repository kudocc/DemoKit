//
//  CoreTextChatViewController.m
//  demo
//
//  Created by KudoCC on 16/5/31.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "CoreTextChatViewController.h"
#import <CoreText/CoreText.h>

@interface CCLine : NSObject

@property (nonatomic) CTLineRef line;
@property (nonatomic) CGPoint position;

@end

@implementation CCLine

@end

@interface CoreTextView : UIView
@property (nonatomic) CTFrameRef ctFrame;
@property (nonatomic) NSArray<CCLine *> *lines;
@end

@implementation CoreTextView

- (void)setLines:(NSArray<CCLine *> *)lines {
    _lines = lines;
    
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
//    for (CCLine *line in _lines) {
//        CGContextSetTextPosition(context, line.position.x, line.position.y);
//        CTLineDraw(line.line, context);
//    }
    
    CTFrameDraw(_ctFrame, context);
}
@end

@interface CoreTextMsg : NSObject

+ (CGFloat)constraintWidth;
+ (CGFloat)paddingY;

- (id)initWithContent:(NSString *)strContent left:(BOOL)left;

@property (nonatomic, readonly) NSAttributedString *content;
@property (nonatomic, readonly) CGFloat cellHeight;
@property (nonatomic, readonly) CGFloat contentWidth;
@property (nonatomic, readonly) CGFloat contentHeight;
@property (nonatomic) BOOL left;

@property (nonatomic, readonly) CTFramesetterRef framesetter;
@property (nonatomic, readonly) CTFrameRef frame;
@property (nonatomic, readonly) CFArrayRef lines;
@property (nonatomic, readonly) NSArray<CCLine *> *ccLines;

@end

@implementation CoreTextMsg

+ (CGFloat)constraintWidth {
    static CGFloat width = 0;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        width = ScreenWidth * 2 / 3;
        width = ceill(width);
    });
    return width;
}

+ (CGFloat)paddingY {
    return 20.0;
}

+ (CGSize)measureFrame:(CTFrameRef)frame {
    CGPathRef framePath = CTFrameGetPath(frame);
    CGRect frameRect = CGPathGetBoundingBox(framePath);
    CFArrayRef lines = CTFrameGetLines(frame);
    CFIndex numLines = CFArrayGetCount(lines);
    CGFloat maxWidth = 0;
    CGFloat textHeight = 0;
    CFIndex lastLineIndex = numLines - 1;
    
    for(CFIndex index = 0; index < numLines; index++)
    {
        CGFloat ascent, descent, leading, width;
        CTLineRef line = (CTLineRef) CFArrayGetValueAtIndex(lines, index);
        width = CTLineGetTypographicBounds(line, &ascent,  &descent, &leading);
        if (width > maxWidth) { maxWidth = width; }
        if (index == lastLineIndex) {
            CGPoint lastLineOrigin;
            CTFrameGetLineOrigins(frame, CFRangeMake(lastLineIndex, 1), &lastLineOrigin);
            textHeight =  CGRectGetMaxY(frameRect) - lastLineOrigin.y + descent;
        }
    }
    return CGSizeMake(ceil(maxWidth), ceil(textHeight));
}

- (id)initWithContent:(NSString *)strContent left:(BOOL)left {
    self = [super init];
    if (self) {
        NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        _content = [[NSAttributedString alloc] initWithString:strContent attributes:@{NSForegroundColorAttributeName:[UIColor blackColor], NSFontAttributeName:[UIFont systemFontOfSize:14], NSParagraphStyleAttributeName:paragraphStyle}];
        _left = left;
        
        _framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)_content);
        CGRect constraint = CGRectMake(0, 0, [self.class constraintWidth], 1024);
        CGPathRef path = CGPathCreateWithRect(constraint, NULL);
        _frame = CTFramesetterCreateFrame(_framesetter, CFRangeMake(0, [_content length]), path, NULL);
        CGPathRelease(path);
        
        {
            // debug
            CGSize size = [self.class measureFrame:_frame];
            CGRect newConstraint = CGRectMake(0, 0, size.width, size.height);
            CGPathRef path = CGPathCreateWithRect(newConstraint, NULL);
            _frame = CTFramesetterCreateFrame(_framesetter, CFRangeMake(0, [_content length]), path, NULL);
            CGPathRelease(path);
        }
        
        _lines = CTFrameGetLines(_frame);
        
        {
            // debug first line
            CTLineRef line = CFArrayGetValueAtIndex(_lines, 0);
            CGFloat ascent, descent, leading;
            CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
            NSLog(@"first line ascent:%@, descent:%@, leading:%@", @(ascent), @(descent), @(leading));
            
            // debug second line
            if (CFArrayGetCount(_lines) > 1) {
                CTLineRef line = CFArrayGetValueAtIndex(_lines, 1);
                CGFloat ascent, descent, leading;
                CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
                NSLog(@"second line ascent:%@, descent:%@, leading:%@", @(ascent), @(descent), @(leading));
            }
        }
        
        CFIndex count = CFArrayGetCount(_lines);
        CGPoint positions[count];
        CTFrameGetLineOrigins(_frame, CFRangeMake(0, 0), positions);
        CGPoint bottomPosition = positions[count-1];
        NSMutableArray *mArray = [NSMutableArray array];
        for (CFIndex i = count-1; i >= 0; --i) {
            CTLineRef line = CFArrayGetValueAtIndex(_lines, i);
            CGFloat ascent, descent, leading;
            CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
            CGPoint po = positions[i];
            CCLine *ccLine = [[CCLine alloc] init];
            ccLine.position = CGPointMake(po.x, ceil(po.y-bottomPosition.y + descent + leading));
            ccLine.line = line;
            [mArray addObject:ccLine];
        }
        _ccLines = [mArray copy];
        
        CGSize size = [self.class measureFrame:_frame];
        _contentWidth = ceil(size.width);
        _contentHeight = ceil(size.height);
        _cellHeight = _contentHeight + [self.class paddingY];
    }
    return self;
}

@end


@interface CoreTextChatCell : UITableViewCell

@property (nonatomic) CoreTextMsg *chatCell;
@property (nonatomic) CoreTextView *viewChatMsg;

@end

@implementation CoreTextChatCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _viewChatMsg = [[CoreTextView alloc] init];
        [self.contentView addSubview:_viewChatMsg];
        _viewChatMsg.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)setChatCell:(CoreTextMsg *)chatCell {
    if (_chatCell == chatCell) return;
    
    _chatCell = chatCell;
    _viewChatMsg.ctFrame = chatCell.frame;
    _viewChatMsg.lines = chatCell.ccLines;
    if (_chatCell.left) {
        _viewChatMsg.backgroundColor = [UIColor whiteColor];
    } else {
        _viewChatMsg.backgroundColor = [UIColor greenColor];
    }
    
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect frame = CGRectMake(0, [CoreTextMsg paddingY], _chatCell.contentWidth, _chatCell.contentHeight);
    if (!_chatCell.left) {
        frame = CGRectOffset(frame, self.contentView.width-frame.size.width, 0);
    }
    _viewChatMsg.frame = frame;
}

@end


@implementation CoreTextChatViewController {
    UITableView *_tableView;
    NSArray<CoreTextMsg *> *_chatMsgs;
}

- (void)initView {
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, ScreenWidth, ScreenHeight-64) style:UITableViewStylePlain];
    [self.view addSubview:_tableView];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableFooterView = [UIView new];
    [_tableView registerClass:[CoreTextChatCell class] forCellReuseIdentifier:@"cell"];
    
    [self showLoadingMessage:@"Loading"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *path = [[NSBundle mainBundle] pathForResource:@"chat" ofType:@"plist"];
        NSArray *dataSource = [[NSArray alloc] initWithContentsOfFile:path];
        
        NSMutableArray *mutableArray = [NSMutableArray array];
        for (NSDictionary *dict in dataSource) {
            CoreTextMsg *data = [[CoreTextMsg alloc] initWithContent:dict[@"content"] left:[dict[@"left"] boolValue]];
            [mutableArray addObject:data];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideLoadingMessage];
            
            _chatMsgs = [mutableArray copy];
            [_tableView reloadData];
        });
    });
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CoreTextMsg *chatCell = [_chatMsgs objectAtIndex:indexPath.row];
    return chatCell.cellHeight;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_chatMsgs count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CoreTextChatCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.chatCell = [_chatMsgs objectAtIndex:indexPath.row];
    return cell;
}

@end
