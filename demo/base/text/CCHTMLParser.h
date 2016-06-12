//
//  CCHTMLParser.h
//  demo
//
//  Created by KudoCC on 16/6/8.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CCTagItem : NSObject

@property (nonatomic, readonly) NSString *tagName;
@property (nonatomic, readonly) NSMutableDictionary *attributes;
@property (nonatomic, readonly) NSMutableArray<CCTagItem *> *subTagItems;
@property (nonatomic, readonly) NSRange effectRange;
@property (nonatomic, readonly) NSString *tagPlaceholder;
/// 是否是空标签(在开始标签结束的标签 eg:<br />)
@property (nonatomic, readonly) BOOL emptyTag;

+ (CCTagItem *)tagItemWithTagName:(NSString *)tagName;

- (void)applyAttributeOnMutableAttributedString:(NSMutableAttributedString *)wholeString;

- (void)debugTagItem;

@end

/**
 解析html是一个非常复杂的事情，为了使解析过程稍微简单一些，我们设置了一些条件
 */
// 1.解析html，将标签表示成CCTagItem，组合成一个嵌套的数组，存入rootTags；解析过程中将内容写入NSMutableString
// 2.内容中的特殊字符要做替换，比如 &lt;&amp;等等
@interface CCHTMLParser : NSObject

@property (nonatomic) NSMutableString *mutableString;
@property (nonatomic) CCTagItem *rootTag;

+ (CCHTMLParser *)parserWithHTMLString:(NSString *)htmlString;


- (NSAttributedString *)attributedStringWithDefaultFont:(UIFont *)font
                                       defaultTextColor:(UIColor *)defaultTextColor;

@end
