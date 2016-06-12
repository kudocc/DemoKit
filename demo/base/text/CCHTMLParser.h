//
//  CCHTMLParser.h
//  demo
//
//  Created by KudoCC on 16/6/8.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CCHTMLConfig : NSObject

/// 指定一个fontName，全文都使用此font
@property (nonatomic) NSString *fontName;
@property (nonatomic) NSString *boldFontName;
@property (nonatomic) NSString *italicFontName;

/// TODO:超链接的属性，未选中时的文本颜色和背景颜色；选中时的文本颜色和背景颜色
/// 超链接点击的回调

- (CCHTMLConfig *)sharedConfig;

@end

/// tag <html></html>
extern NSString *const CCHTMLTagNameHTML;
/// tag <body></body>
extern NSString *const CCHTMLTagNameBody;
/// tag <a href="xxx"></a>
extern NSString *const CCHTMLTagNameA;
/// tag <font color="#ff000000"></font> 字体
extern NSString *const CCHTMLTagNameFont;
/// tag <p></p>
extern NSString *const CCHTMLTagNameP;
/// tag <img href='xxx' width='100' height='100'>abc</img> 图片(标签中可以有文字)
extern NSString *const CCHTMLTagNameImg;
/// tag <br />
extern NSString *const CCHTMLTagNameBr;

@interface CCHTMLTag : NSObject

@property (nonatomic, readonly) NSString *tagName;
@property (nonatomic, readonly) NSMutableDictionary<NSString *, id> *attributes;
@property (nonatomic, readonly) NSMutableArray<CCHTMLTag *> *subTagItems;
@property (nonatomic, readonly) NSRange effectRange;
/**
 placeholderBegin, placeholderEnd:
 有很多标签并不需要修改文本的内容，只是增加一些展示的属性，比如<font> <a>;
 但是有些标签需要增加一些文本来实现，比如<p>标签需要在其修饰内容之前和之后都增加一个换行符，再如<img>需要在其修饰内容之前增加CCAttachmentCharacter，为了使其在转换成AttributedString的时候effectRange属性不会失效。
 */
@property (nonatomic, readonly) NSString *placeholderBegin;
@property (nonatomic, readonly) NSString *placeholderEnd;
/// 是否是空标签(在开始标签结束的标签 eg:<br />)
@property (nonatomic, readonly) BOOL emptyTag;
/// 此tag支持的属性数组
@property (nonatomic, readonly) NSArray<NSString *> *supportedAttributes;

+ (CCHTMLTag *)tagItemWithTagName:(NSString *)tagName;

- (void)applyAttributeOnMutableAttributedString:(NSMutableAttributedString *)wholeString;

- (void)debugTagItem;

@end

/**
 解析html是一个非常复杂的事情，为了使解析过程稍微简单一些，我们设置了一些条件
 1.不支持CSS和style属性
 2.如果是empty tag，/ 符号紧挨着尖括号 <br />，这样是非法的<br / >
 3.关于font标签：不支持face属性，size属性是以point为单位的，并不是浏览器中的值.
 4.你可以指定一个font，全文中我们都用此font，我们支持<b><i>，需要你提供粗体和斜体的font name
 5.img标签的width和height不支持百分比，都是以point为单位
 */
@interface CCHTMLParser : NSObject

@property (nonatomic) NSMutableString *mutableString;
@property (nonatomic) CCHTMLTag *rootTag;

+ (CCHTMLParser *)parserWithHTMLString:(NSString *)htmlString;


- (NSAttributedString *)attributedStringWithDefaultFont:(UIFont *)font
                                       defaultTextColor:(UIColor *)defaultTextColor;

@end
