//
//  NSString+QQExtension.m
//  NNKit
//
//  Created by xuze on 2021/2/27.
//

#import "NSString+QQExtension.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (QQExtension)

- (NSRange)floorEmojiWithRange:(NSRange)range {
    if (range.length == 0) {
        return range;
    }
    NSRange resultRange = [self rangeOfComposedCharacterSequencesForRange:range];
    if (NSMaxRange(resultRange) > NSMaxRange(range)) {
        return [self floorEmojiWithRange:NSMakeRange(range.location, range.length - 1)];
    }
    return resultRange;
}

- (NSString *)qq_substringAvoidBreakingEmojiWithRange:(NSRange)range {
    NSRange floorRange = [self floorEmojiWithRange:range];
    NSString *resultString = [self substringWithRange:floorRange];
    return resultString;
}

- (NSString *)qq_trim {
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (NSString *)qq_trimAllWhiteSpace {
    return [self stringByReplacingOccurrencesOfString:@"\\s" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, self.length)];
}

- (NSString *)qq_md5 {
    unsigned char digest[16];
    CC_MD5([self UTF8String], (int)[self lengthOfBytesUsingEncoding:NSUTF8StringEncoding], digest);
    NSMutableString *result = [NSMutableString string];
    for (int i = 0; i < 16; i++) {
        [result appendFormat:@"%02x", (int)(digest[i])];
    }
    return [result copy];
}

- (CGSize)qq_sizeForFont:(UIFont *)font size:(CGSize)size {
    return [self qq_sizeForFont:font size:size mode:NSLineBreakByWordWrapping];
}

- (CGSize)qq_sizeForFont:(UIFont *)font size:(CGSize)size mode:(NSLineBreakMode)lineBreakMode {
    if (!font) return CGSizeZero;
    NSMutableDictionary *attr = [NSMutableDictionary dictionary];
    attr[NSFontAttributeName] = font;
    if (lineBreakMode != NSLineBreakByWordWrapping) {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineBreakMode = lineBreakMode;
        attr[NSParagraphStyleAttributeName] = paragraphStyle;
    }
    CGRect rect = [self boundingRectWithSize:size
                                     options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                  attributes:attr context:nil];
    return CGSizeMake(ceil(rect.size.width), ceil(rect.size.height));
}

@end
