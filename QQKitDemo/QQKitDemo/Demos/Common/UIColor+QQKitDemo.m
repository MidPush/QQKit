//
//  UIColor+QQKitDemo.m
//  QQKitDemo
//
//  Created by Mac on 2021/4/15.
//

#import "UIColor+QQKitDemo.h"
#import "UIColor+QQExtension.h"

@implementation UIColor (QQKitDemo)

+ (UIColor *)dm_whiteColor {
    return [UIColor qq_colorWithHexString:@"ffffff"];
}

+ (UIColor *)dm_blackColor {
    return [UIColor qq_colorWithHexString:@"000000"];
}

+ (UIColor *)dm_backgroundColor {
    return [UIColor qq_colorWithHexString:@"ededed"];
}

+ (UIColor *)dm_tintColor {
    return [UIColor qq_colorWithHexString:@"00cc68"];
}

+ (UIColor *)dm_mainTextColor {
    return [UIColor qq_colorWithHexString:@"222222"];
}

+ (UIColor *)dm_whiteTextColor {
    return [UIColor qq_colorWithHexString:@"ffffff"];
}

+ (UIColor *)dm_mainGrayColor {
    return [UIColor qq_colorWithHexString:@"666666"];
}

+ (UIColor *)dm_lightGrayColor {
    return [UIColor qq_colorWithHexString:@"999999"];
}

+ (UIColor *)dm_separatorColor {
    return [UIColor qq_colorWithHexString:@"e9e9e9"];
}

+ (UIColor *)dm_placeholderColor {
    return [UIColor qq_colorWithHexString:@"999999"];
}

+ (UIColor *)dm_highlightedColor {
    return [UIColor qq_colorWithHexString:@"eeeff1"];
}

+ (UIColor *)dm_disabledColor {
    return self.dm_lightGrayColor;
}

@end
