//
//  CCHTMLParser.h
//  demo
//
//  Created by KudoCC on 16/6/8.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 placeholderBegin, placeholderEnd:
 有很多标签并不需要修改文本的内容，只是增加一些展示的属性，比如<font> <a>，但是有些标签需要增加一些文本来实现。
 比如<p>标签需要在其修饰内容之前和之后都增加一个换行符，<img>需要在其修饰内容之前增加CCAttachmentCharacter，为了使其在转换成AttributedString的时候effectRange
 属性不会失效。
 */
@interface CCTagItem : NSObject

@property (nonatomic, readonly) NSString *tagName;
@property (nonatomic, readonly) NSMutableDictionary *attributes;
@property (nonatomic, readonly) NSMutableArray<CCTagItem *> *subTagItems;
@property (nonatomic, readonly) NSRange effectRange;
/// 加在标签内容之前的placeholder
@property (nonatomic, readonly) NSString *placeholderBegin;
/// 加在标签内容之后的placeholder
@property (nonatomic, readonly) NSString *placeholderEnd;
/// 是否是空标签(在开始标签结束的标签 eg:<br />)
@property (nonatomic, readonly) BOOL emptyTag;

+ (CCTagItem *)tagItemWithTagName:(NSString *)tagName;

- (void)applyAttributeOnMutableAttributedString:(NSMutableAttributedString *)wholeString;

- (void)debugTagItem;

@end

/**
 解析html是一个非常复杂的事情，为了使解析过程稍微简单一些，我们设置了一些条件
 */
// 1.解析html，将标签表示成CCTagItem，最终形成根标签rootTag，其他标签都包含在根标签中
// 2.内容中的特殊字符要做替换，比如 &lt;&amp;
// 3.应用标签的属性，得到NSAttributedString.
@interface CCHTMLParser : NSObject

@property (nonatomic) NSMutableString *mutableString;
@property (nonatomic) CCTagItem *rootTag;

+ (CCHTMLParser *)parserWithHTMLString:(NSString *)htmlString;


- (NSAttributedString *)attributedStringWithDefaultFont:(UIFont *)font
                                       defaultTextColor:(UIColor *)defaultTextColor;

@end
