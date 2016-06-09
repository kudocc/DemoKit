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

//https://en.wikipedia.org/wiki/HTML_attribute

#define RangeLength(startPos, endPos) (endPos-startPos+1)

NSString *const CCHTMLParseErrorDomain = @"CCHTMLParseErrorDomain";

/// tag <a></a> 超链接
NSString *const CCHTMLTagNameA = @"a";
/// tag <font></font> 字体
NSString *const CCHTMLTagNameFont = @"font";
/// tag <p></p> 段落
NSString *const CCHTMLTagNameP = @"p";
/// tag <img></img> 图片
NSString *const CCHTMLTagNameImg = @"img";
/// tag <br /> 强制换行
NSString *const CCHTMLTagBr = @"br";
/// tag <b></b> 粗体
NSString *const CCHTMLTagB = @"b";
/// tag <i></b> 斜体
NSString *const CCHTMLTagI = @"i";

// TOOD:
/// tag <u></u> 下划线
NSString *const CCHTMLTagU = @"u";
/// tag <s></s> 删除线
NSString *const CCHTMLTagS = @"s";
/// tag <sup></sup> 上标
NSString *const CCHTMLTagSup = @"sup";
/// tag <sub></sub> 下标
NSString *const CCHTMLTagSub = @"sub";

NSString *const CCHTMLTagAttributeNameHref = @"href";
NSString *const CCHTMLTagAttributeNameColor = @"color";
NSString *const CCHTMLTagAttributeNameBgColor = @"bgcolor";
NSString *const CCHTMLTagAttributeNameSize = @"size";
NSString *const CCHTMLTagAttributeNameWidth = @"width";
NSString *const CCHTMLTagAttributeNameHeight = @"height";

@implementation CCTagItem

- (id)init {
    self = [super init];
    if (self) {
        _tagPlaceholder = @"";
        _attributes = [NSMutableDictionary dictionary];
        _subTagItems = [NSMutableArray array];
    }
    return self;
}

- (void)debugTagItem {
    NSLog(@"tag name:%@", _tagName);
    NSLog(@"attribute:%@", _attributes);
    NSLog(@"effect range:%@", NSStringFromRange(_effectRange));
    for (CCTagItem *item in _subTagItems) {
        [item debugTagItem];
    }
}

@end

@implementation CCHTMLParser {
    CCStack *_stack;
    NSMutableArray *_mutableRootArray;
}

+ (CCHTMLParser *)parserWithHTMLString:(NSString *)htmlString {
    CCHTMLParser *parser = [[CCHTMLParser alloc] initWithHTMLString:htmlString];
    return parser;
}

- (id)initWithHTMLString:(NSString *)htmlString {
    self = [super init];
    if (self) {
        [self startParseHTMLString:htmlString];
    }
    return self;
}

- (NSArray *)rootTags {
    return [_mutableRootArray copy];
}

- (void)startParseHTMLString:(NSString *)htmlString {
    _stack = [[CCStack alloc] init];
    _mutableRootArray = [NSMutableArray array];
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
            NSRange rangeText = NSMakeRange(searchPosition, RangeLength(searchPosition, tagRange.location-1));
            NSString *text = [htmlString substringWithRange:rangeText];
            [_mutableString appendString:text];
            searchPosition = tagRange.location + tagRange.length;
            
            CCTagItem *tagItem = [self constructTagWithTagStartString:tag];
            if (!tagItem) {
                // error
                return;
            }
            tagItem.effectRange = NSMakeRange([_mutableString length], 0);
            [_mutableString appendString:tagItem.tagPlaceholder];
            CCTagItem *parentItem = [_stack top];
            if (parentItem) {
                [parentItem.subTagItems addObject:tagItem];
            } else {
                [_mutableRootArray addObject:tagItem];
            }
            
            if (!tagItem.emptyTag) {
                [_stack push:tagItem];
            }
        } else {
            NSString *tagName = [self extractEndTagName:tag];
            if ([tagName length] == 0) {
                // error
                return;
            }
            
            CCTagItem *top = [_stack top];
            if (!top || ![top.tagName isEqualToString:tagName]) {
                // error
                return;
            }
            [_stack pop];
            
            NSRange rangeText = NSMakeRange(searchPosition, RangeLength(searchPosition, tagRange.location-1));
            NSString *text = [htmlString substringWithRange:rangeText];
            [_mutableString appendString:text];
            top.effectRange = NSMakeRange(top.effectRange.location, RangeLength(top.effectRange.location, [_mutableString length]-1));
            searchPosition = tagRange.location + tagRange.length;
        }
    }
    
    NSAssert([_stack isEmpty], @"html string not valid");
}

// 1.judge if it is a empty tag
// 2.find tag name
// 3.find attibutes
- (CCTagItem *)constructTagWithTagStartString:(NSString *)tagString {
    CCTagItem *tagItem = [[CCTagItem alloc] init];
    // trim '<' and '>'
    tagString = [tagString substringWithRange:NSMakeRange(1, [tagString length]-2)];
    
    // assume: 如果是empty tag，/ 符号紧挨着尖括号 <br />，这样是非法的<br / >
    unichar lastChar = [tagString characterAtIndex:[tagString length]-1];
    if (lastChar == '/') {
        tagItem.emptyTag = YES;
        tagString = [tagString substringToIndex:[tagString length]-1];
    }
    
    NSInteger i = 0;
    [tagString runUtilNoneSpaceFromLocation:0 noneSpaceLocation:&i reachEnd:NULL];
    // 找到tag名称
    for (i = 0; i < [tagString length]; ++i) {
        unichar c = [tagString characterAtIndex:i];
        if (c == ' ' || i == [tagString length]-1) {
            NSString *tagName = nil;
            if (i == [tagString length]-1) {
                tagName = [tagString copy];
            } else {
                tagName = [tagString substringToIndex:i];
            }
            tagItem.tagName = tagName;
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
    if ([tagItem.tagName length] == 0) {
        // we didn't find a tag name
        return nil;
    }
    
    if (tagItem.emptyTag) {
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
                tagItem.attributes[attributeName] = attributeValue;
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