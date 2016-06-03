//
//  ChatViewController.m
//  demo
//
//  Created by KudoCC on 16/6/1.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "ChatViewController.h"
#import "CCTextLayout.h"
#import "CCLabel.h"

@interface ChatMessage : NSObject

+ (CGFloat)constraintWidth;
+ (CGFloat)paddingY;

- (id)initWithContent:(NSString *)strContent left:(BOOL)left;

@property (nonatomic, readonly) NSAttributedString *content;
@property (nonatomic, readonly) CGFloat cellHeight;
@property (nonatomic, readonly) CGFloat contentWidth;
@property (nonatomic, readonly) CGFloat contentHeight;
@property (nonatomic) BOOL left;

@property (nonatomic) CCTextLayout *textLayout;

@end

@implementation ChatMessage

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

- (id)initWithContent:(NSString *)strContent left:(BOOL)left {
    self = [super init];
    if (self) {
        NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        paragraphStyle.lineSpacing = 0.0;
        _content = [[NSAttributedString alloc] initWithString:strContent attributes:@{NSForegroundColorAttributeName:[UIColor blackColor], NSFontAttributeName:[UIFont systemFontOfSize:14], NSParagraphStyleAttributeName:paragraphStyle}];
        _left = left;
        
        CGSize constraint = CGSizeMake([self.class constraintWidth], CGFLOAT_MAX);
        _textLayout = [CCTextLayout textLayoutWithSize:constraint attributedText:_content];
        
        _contentWidth = _textLayout.textBounds.width;
        _contentHeight = _textLayout.textBounds.height;
        _cellHeight = _contentHeight + [self.class paddingY];
    }
    return self;
}

@end


@interface ChatTableViewCell : UITableViewCell

@property (nonatomic) ChatMessage *chatMessage;
@property (nonatomic) CCLabel *label;

@end

@implementation ChatTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _label = [[CCLabel alloc] init];
        [self.contentView addSubview:_label];
    }
    return self;
}

- (void)setChatMessage:(ChatMessage *)chatMessage {
    if (_chatMessage == chatMessage) return;
    
    _chatMessage = chatMessage;
    if (_chatMessage.left) {
        _label.backgroundColor = [UIColor whiteColor];
    } else {
        _label.backgroundColor = [UIColor greenColor];
    }
    _label.textLayout = chatMessage.textLayout;
    
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect frame = CGRectMake(0, [ChatMessage paddingY], _chatMessage.contentWidth, _chatMessage.contentHeight);
    if (!_chatMessage.left) {
        frame = CGRectOffset(frame, self.contentView.width-frame.size.width, 0);
    }
    _label.frame = frame;
}

@end


@implementation ChatViewController {
    UITableView *_tableView;
    NSArray<ChatMessage *> *_chatMsgs;
}

- (void)initView {
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, ScreenWidth, ScreenHeight-64) style:UITableViewStylePlain];
    [self.view addSubview:_tableView];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableFooterView = [UIView new];
    [_tableView registerClass:[ChatTableViewCell class] forCellReuseIdentifier:@"cell"];
    
    [self showLoadingMessage:@"Loading"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *path = [[NSBundle mainBundle] pathForResource:@"chat" ofType:@"plist"];
        NSArray *dataSource = [[NSArray alloc] initWithContentsOfFile:path];
        
        NSMutableArray *mutableArray = [NSMutableArray array];
        for (NSDictionary *dict in dataSource) {
            ChatMessage *data = [[ChatMessage alloc] initWithContent:dict[@"content"] left:[dict[@"left"] boolValue]];
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
    ChatMessage *chatCell = [_chatMsgs objectAtIndex:indexPath.row];
    return chatCell.cellHeight;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_chatMsgs count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ChatTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.chatMessage = [_chatMsgs objectAtIndex:indexPath.row];
    return cell;
}

@end