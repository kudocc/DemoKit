//
//  CCHTMLParser.m
//  demo
//
//  Created by KudoCC on 16/6/8.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "CCHTMLParser.h"
#import "CCStack.h"
#import "NSString+CCKit.h"
#import "NSAttributedString+CCKit.h"
#import "UIColor+CCKit.h"

//https://en.wikipedia.org/wiki/HTML_attribute

#define RangeLength(startPos, endPos) (endPos-startPos+1)

NSString *const CCHTMLParseErrorDomain = @"CCHTMLParseErrorDomain";

/// tag <html></html>
NSString *const CCHTMLTagNameHTML = @"html";
/// tag <body></body>
NSString *const CCHTMLTagNameBody = @"body";
/// tag <a></a> 超链接
NSString *const CCHTMLTagNameA = @"a";
/// tag <font></font> 字体
NSString *const CCHTMLTagNameFont = @"font";
/// tag <p></p> 段落
NSString *const CCHTMLTagNameP = @"p";
/// tag <img href='xxx' width='100' height='100'>abc</img> 图片(标签中可以有文字)
NSString *const CCHTMLTagNameImg = @"img";
/// tag <br /> 强制换行
NSString *const CCHTMLTagNameBr = @"br";

// TOOD:
/// tag <b></b> 粗体
NSString *const CCHTMLTagNameB = @"b";
/// tag <i></b> 斜体
NSString *const CCHTMLTagNameI = @"i";
/// tag <u></u> 下划线
NSString *const CCHTMLTagU = @"u";
/// tag <s></s> 删除线
NSString *const CCHTMLTagS = @"s";
/// tag <sup></sup> 上标
NSString *const CCHTMLTagSup = @"sup";
/// tag <sub></sub> 下标
NSString *const CCHTMLTagSub = @"sub";

NSString *const CCHTMLTagAttributeNameHref = @"href";
NSString *const CCHTMLTagAttributeNameSource = @"src";
NSString *const CCHTMLTagAttributeNameColor = @"color";
NSString *const CCHTMLTagAttributeNameBgColor = @"bgcolor";
NSString *const CCHTMLTagAttributeNameSize = @"size";
NSString *const CCHTMLTagAttributeNameWidth = @"width";
NSString *const CCHTMLTagAttributeNameHeight = @"height";

static NSDictionary *htmlSpecialCharacterMap;

@interface CCTagItem ()

@property (nonatomic) NSString *tagName;
@property (nonatomic) NSMutableDictionary *attributes;
@property (nonatomic) NSMutableArray<CCTagItem *> *subTagItems;
@property (nonatomic) NSRange effectRange;
@property (nonatomic) NSString *placeholderBegin;
@property (nonatomic) NSString *placeholderEnd;
@property (nonatomic) BOOL emptyTag;

- (void)addAttribute:(NSString *)attribute value:(NSString *)value;

@end

@implementation CCTagItem

+ (CCTagItem *)tagItemWithTagName:(NSString *)tagName {
    static NSDictionary *tagNameToPlaceholder = nil;
    static NSArray *availableTagNames = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tagNameToPlaceholder = @{CCHTMLTagNameP:@[@"\n", @"\n"],
                                 CCHTMLTagNameImg:@[CCAttachmentCharacter, @""],
                                 CCHTMLTagNameBr:@[@"\n", @""]};
        availableTagNames = @[CCHTMLTagNameHTML,
                              CCHTMLTagNameBody,
                              CCHTMLTagNameA,
                              CCHTMLTagNameFont,
                              CCHTMLTagNameP,
                              CCHTMLTagNameImg,
                              CCHTMLTagNameBr];
        
        // TODO:
        htmlSpecialCharacterMap = @{@"&quot;":@"\"",
                                    @"&nbsp;":@" ",
                                    @"&lt;":@"<",
                                    @"&gt;":@">",
                                    @"&amp;":@"&"};
    });
    
    if ([availableTagNames containsObject:tagName]) {
        CCTagItem *item = [[CCTagItem alloc] init];
        item.tagName = tagName;
        NSArray *placeholders = tagNameToPlaceholder[tagName];
        if (placeholders) {
            item.placeholderBegin = placeholders[0];
            item.placeholderEnd = placeholders[1];
        }
        return item;
    }
    return nil;
}

- (id)init {
    self = [super init];
    if (self) {
        _attributes = [NSMutableDictionary dictionary];
        _subTagItems = [NSMutableArray array];
    }
    return self;
}

- (void)addAttribute:(NSString *)attribute value:(NSString *)value {
    _attributes[attribute] = value;
}

- (void)debugTagItem {
    NSLog(@"tag name:%@", _tagName);
    NSLog(@"attribute:%@", _attributes);
    NSLog(@"effect range:%@", NSStringFromRange(_effectRange));
    for (CCTagItem *item in _subTagItems) {
        [item debugTagItem];
    }
}

- (void)applyAttributeOnMutableAttributedString:(NSMutableAttributedString *)wholeString {
    // apply item attribute
    if ([_tagName isEqualToString:CCHTMLTagNameA]) {
        // href
        NSString *href = _attributes[CCHTMLTagAttributeNameHref];
        [wholeString cc_setHighlightedColor:[UIColor grayColor] bgColor:[UIColor blueColor] range:self.effectRange tapAction:^(NSRange range) {
            NSLog(@"%@, href=%@", NSStringFromRange(range), href);
            NSURL *url = [NSURL URLWithString:href];
            if (url && [[UIApplication sharedApplication] canOpenURL:url]) {
                [[UIApplication sharedApplication] openURL:url];
            }
        }];
    } else if ([_tagName isEqualToString:CCHTMLTagNameFont]) {
        // attribute:color #XXXXXX
        NSString *strColor = _attributes[CCHTMLTagAttributeNameColor];
        if (strColor) {
            UIColor *color = [UIColor cc_opaqueColorWithHexString:strColor];
            if (color) {
                [wholeString cc_setColor:color range:self.effectRange];
            }
        }
        // TODO:attribute:font name, height
    } else if ([_tagName isEqualToString:@"img"]) {
        // src
        NSString *src = _attributes[CCHTMLTagAttributeNameSource];
        UIImage *image = [UIImage imageNamed:src];
        // width
        NSString *strWidth = _attributes[CCHTMLTagAttributeNameWidth];
        // height
        NSString *strHeight = _attributes[CCHTMLTagAttributeNameHeight];
        if (image && strWidth && strHeight) {
            NSAttributedString *attach = [NSAttributedString attachmentStringWithContent:image contentMode:UIViewContentModeScaleToFill contentSize:CGSizeMake([strWidth integerValue], [strHeight integerValue]) alignToFont:[UIFont systemFontOfSize:14] attachmentPosition:CCTextAttachmentPositionTop];
            NSRange range = self.effectRange;
            if (self.effectRange.length > CCAttachmentCharacter.length) {
                range = NSMakeRange(self.effectRange.location + self.effectRange.length - CCAttachmentCharacter.length, CCAttachmentCharacter.length);
            }
            [wholeString replaceCharactersInRange:range withAttributedString:attach];
        }
    }
    
    for (CCTagItem *item in _subTagItems) {
        [item applyAttributeOnMutableAttributedString:wholeString];
    }
}

@end

@implementation CCHTMLParser {
    CCStack *_stack;
}

+ (CCHTMLParser *)parserWithHTMLString:(NSString *)htmlString {
    CCHTMLParser *parser = [[CCHTMLParser alloc] initWithHTMLString:htmlString];
    return parser;
}

- (NSAttributedString *)attributedStringWithDefaultFont:(UIFont *)font
                                       defaultTextColor:(UIColor *)defaultTextColor {
    NSMutableAttributedString *mutableAttrString = [[NSMutableAttributedString alloc] initWithString:self.mutableString];
    [mutableAttrString cc_setFont:font];
    [mutableAttrString cc_setColor:defaultTextColor];
    [_rootTag applyAttributeOnMutableAttributedString:mutableAttrString];
    return mutableAttrString;
}

- (id)initWithHTMLString:(NSString *)htmlString {
    self = [super init];
    if (self) {
        [self parseHTMLString:htmlString];
    }
    return self;
}

- (void)parseHTMLString:(NSString *)htmlString {
    _stack = [[CCStack alloc] init];
    NSMutableArray *mutableRootArray = [NSMutableArray array];
    _mutableString = [[NSMutableString alloc] init];
    
    NSInteger searchPosition = 0;
    while (searchPosition < [htmlString length]) {
        BOOL isStartTag = NO;
        NSRange tagRange;
        NSError *error = nil;
        BOOL find = [self findTag:htmlString
                            range:NSMakeRange(searchPosition, [htmlString length]-1)
                findTagIsStartTag:&isStartTag
                            range:&tagRange
                            error:&error];
        if (error) {
            NSLog(@"parsed error:%@", [error localizedDescription]);
            return;
        }
        if (!find) {
            return;
        }
        NSString *tag = [htmlString substringWithRange:tagRange];
        if (isStartTag) {
            // 将开始标签之前的文本全部加入
            NSRange rangeText = NSMakeRange(searchPosition, RangeLength(searchPosition, tagRange.location-1));
            NSString *text = [htmlString substringWithRange:rangeText];
            text = [self replaceHtmlSpecialCharacter:text];
            [_mutableString appendString:text];
            searchPosition = tagRange.location + tagRange.length;
            
            CCTagItem *tagItem = [self constructTagWithTagStartString:tag];
            if (!tagItem) {
                break;
            }
            tagItem.effectRange = NSMakeRange([_mutableString length], 0);
            if (tagItem.placeholderBegin) {
                [_mutableString appendString:tagItem.placeholderBegin];
            }
            CCTagItem *parentItem = [_stack top];
            if (parentItem) {
                [parentItem.subTagItems addObject:tagItem];
            } else {
                [mutableRootArray addObject:tagItem];
            }
            
            if (!tagItem.emptyTag) {
                [_stack push:tagItem];
            }
        } else {
            NSString *tagName = [self extractEndTagName:tag];
            if ([tagName length] == 0) {
                break;
            }
            
            CCTagItem *top = [_stack top];
            if (!top || ![top.tagName isEqualToString:tagName]) {
                break;
            }
            [_stack pop];
            
            NSRange rangeText = NSMakeRange(searchPosition, RangeLength(searchPosition, tagRange.location-1));
            NSString *text = [htmlString substringWithRange:rangeText];
            text = [self replaceHtmlSpecialCharacter:text];
            [_mutableString appendString:text];
            if (top.placeholderEnd) {
                [_mutableString appendString:top.placeholderEnd];
            }
            top.effectRange = NSMakeRange(top.effectRange.location, RangeLength(top.effectRange.location, [_mutableString length]-1));
            searchPosition = tagRange.location + tagRange.length;
        }
    }
    
    NSAssert([_stack isEmpty], @"html string not valid");
    if (![_stack isEmpty]) {
        _mutableString = nil;
        [_stack popAll];
    } else {
        if (mutableRootArray.count > 1) {
            _rootTag = [[CCTagItem alloc] init];
            _rootTag.subTagItems = [mutableRootArray copy];
            _rootTag.tagName = @"root";
            _rootTag.effectRange = NSMakeRange(0, _mutableString.length);
        } else {
            _rootTag = mutableRootArray.firstObject;
        }
    }
}

- (NSString *)replaceHtmlSpecialCharacter:(NSString *)string {
    __block NSString *str = string;
    [htmlSpecialCharacterMap enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL *stop) {
        if ([str containsString:key]) {
            str = [str stringByReplacingOccurrencesOfString:key withString:value];
        }
    }];
    return str;
}

// 1.judge if it is a empty tag
// 2.find tag name
// 3.find attibutes
- (CCTagItem *)constructTagWithTagStartString:(NSString *)tagString {
    BOOL emptyTag = NO;
    NSString *tagName = nil;
    
    // trim '<' and '>'
    tagString = [tagString substringWithRange:NSMakeRange(1, [tagString length]-2)];
    
    // assume: 如果是empty tag，/ 符号紧挨着尖括号 <br />，这样是非法的<br / >
    unichar lastChar = [tagString characterAtIndex:[tagString length]-1];
    if (lastChar == '/') {
        emptyTag = YES;
        tagString = [tagString substringToIndex:[tagString length]-1];
    }
    
    NSInteger i = 0;
    [tagString runUtilNoneSpaceFromLocation:0 noneSpaceLocation:&i reachEnd:NULL];
    // 找到tag名称
    for (i = 0; i < [tagString length]; ++i) {
        unichar c = [tagString characterAtIndex:i];
        if (c == ' ' || i == [tagString length]-1) {
            if (c == ' ') {
                tagName = [tagString substringToIndex:i];
            } else {
                tagName = [tagString copy];
            }
            // 再向后找到第一个不为' '的字符停止
            NSInteger pos = i+1;
            BOOL end = NO;
            [tagString runUtilNoneSpaceFromLocation:i+1 noneSpaceLocation:&pos reachEnd:&end];
            if (!end) {
                tagString = [tagString substringFromIndex:pos];
            } else {
                tagString = @"";
            }
            break;
        }
    }
    if ([tagName length] == 0) {
        // we didn't find a tag name
        return nil;
    }
    
    CCTagItem *tagItem = [CCTagItem tagItemWithTagName:tagName];
    if (!tagItem) {
        return nil;
    }
    tagItem.emptyTag = emptyTag;
    if (emptyTag) {
        return tagItem;
    }
    
    // 找到属性，属性可以使用双引号或者单引号来引用，如果使用单引号引用，其内部可以使用双引号；反之亦然
    while ([tagString length] > 0) {
        unichar attributeValueQuotationMark = '=';
        NSString *attributeName = nil;
        NSInteger attributeValueLocation = 0;
        NSString *attributeValue = nil;
        NSInteger i = 0;
        while (i < [tagString length]) {
            unichar c = [tagString characterAtIndex:i];
            if (c == '=') {
                // we find a attributeName
                attributeName = [tagString substringToIndex:i];
                attributeName = [attributeName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                if ([attributeName length] == 0) {
                    // error, attribute name can't be a empty string
                    return nil;
                }
                // 再向后找到第一个不为' '的字符停止
                NSInteger pos = i+1;
                BOOL end = NO;
                [tagString runUtilNoneSpaceFromLocation:i+1 noneSpaceLocation:&pos reachEnd:&end];
                if (end) {
                    // error，'=' is the end char, no attribute value
                    return nil;
                }
                attributeValueQuotationMark = [tagString characterAtIndex:pos];
                if (attributeValueQuotationMark != '\'' &&
                    attributeValueQuotationMark != '\"') {
                    // error, quotation mark must be ' or "
                    return nil;
                }
                i = pos + 1;
                attributeValueLocation = pos + 1;
            } else if (c == attributeValueQuotationMark) {
                // we can get the attribute value here
                NSRange range = NSMakeRange(attributeValueLocation, RangeLength(attributeValueLocation, i-1));
                attributeValue = [tagString substringWithRange:range];
                if ([attributeValue length] == 0) {
                    // error, attribute value should be empty
                    return nil;
                }
                // add attribute
                [tagItem addAttribute:attributeName value:attributeValue];
                break;
            } else {
                ++i;
            }
        }
        
        [tagString runUtilNoneSpaceFromLocation:i+1 noneSpaceLocation:&i reachEnd:NULL];
        if (i < [tagString length]) {
            tagString = [tagString substringFromIndex:i];
        } else {
            break;
        }
        // let's find the next attribute
    }
    
    return tagItem;
}

/// tagString is formatted as </tagName>
- (NSString *)extractEndTagName:(NSString *)tagString {
    NSRange range = NSMakeRange(2, [tagString length] - 3);
    if (range.length > 0) {
        NSString *tagName = [tagString substringWithRange:range];
        tagName = [tagName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        return tagName;
    }
    return nil;
}

// if find a tag, return YES
- (BOOL)findTag:(NSString *)htmlString range:(NSRange)range findTagIsStartTag:(BOOL *)startTag range:(NSRange *)tagRange error:(NSError **)error {
    BOOL findLeft = NO;
    BOOL findRight = NO;
    NSInteger tagStart = 0;
    for (NSInteger i = range.location; i < range.location + range.length; ++i) {
        unichar c = [htmlString characterAtIndex:i];
        if (c == '<') {
            if (findLeft) {
                *error = [NSError errorWithDomain:CCHTMLParseErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey:@"two '<' found before find a '>'"}];
                return NO;
            }
            findLeft = YES;
            
            // assume: 标签的结束符号'/'就在'<'之后
            if (i+1 < range.location + range.length) {
                unichar after = [htmlString characterAtIndex:i+1];
                if (after == '/') {
                    *startTag = NO;
                } else {
                    *startTag = YES;
                }
            }
            
            tagStart = i;
        } else if (c == '>') {
            findRight = YES;
            if (!findLeft) {
                *error = [NSError errorWithDomain:CCHTMLParseErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey:@"no '<' found before find a '>'"}];
                return NO;
            }
            NSInteger length = RangeLength(tagStart, i);
            if (length <= 2) {
                *error = [NSError errorWithDomain:CCHTMLParseErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey:@"just find a <>"}];
                return NO;
            }
            *tagRange = NSMakeRange(tagStart, length);
            return YES;
        }
    }
    return NO;
}

@end
