//
//  NSException+QQExtension.h
//  QQKitDemo
//
//  Created by Mac on 2021/4/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSException (QQExtension)

@end

@interface NSThread (QQKVCException)

/**
 是否忽略通过 KVC 访问属性异常标志
 */
@property (nonatomic, assign) BOOL qq_shouldIgnoreAccessKVCException;

@end

NS_ASSUME_NONNULL_END
