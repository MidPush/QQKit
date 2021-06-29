//
//  NSString+QQExtension.h
//  NNKit
//
//  Created by xuze on 2021/2/27.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (QQExtension)

/// 防止 emoji 截取出现乱码
- (NSString *)qq_substringAvoidBreakingEmojiWithRange:(NSRange)range;

/// 去掉头尾的空白字符
@property (nonatomic, copy, readonly) NSString *qq_trim;

/// 去掉整段文字内的所有空白字符（包括换行符）
@property (nonatomic, copy, readonly) NSString *qq_trimAllWhiteSpace;

/// 把该字符串转换为对应的 md5
- (NSString *)qq_md5;

/**
 计算字符串 size，lineBreakMode 默认为 UILabel 的 NSLineBreakByTruncatingTail
 若是计算 UILabel 的 lineBreakMode 设置了 mode 不为 NSLineBreakByTruncatingTail，请用
 - (CGSize)qq_sizeForFont:(UIFont *)font size:(CGSize)size mode:(NSLineBreakMode)lineBreakMode
 指定 lineBreakMode 去计算
 */
- (CGSize)qq_sizeForFont:(UIFont *)font size:(CGSize)size;

/// 计算字符串 size
- (CGSize)qq_sizeForFont:(UIFont *)font size:(CGSize)size mode:(NSLineBreakMode)lineBreakMode;

@end

NS_ASSUME_NONNULL_END
