//
//  NSException+QQExtension.m
//  QQKitDemo
//
//  Created by Mac on 2021/4/20.
//

#import "NSException+QQExtension.h"
#import "QQRuntime.h"

@implementation NSException (QQExtension)

+ (void)load {
    // 忽略 iOS 13 KVC 访问属性异常
    if (@available(iOS 13.0, *)) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            OverrideImplementation(object_getClass([NSException class]), @selector(raise:format:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                return ^(NSObject *selfObject, NSExceptionName raise, NSString *format, ...) {

                    if (raise == NSGenericException && [format isEqualToString:@"Access to %@'s %@ ivar is prohibited. This is an application bug"]) {
                        if ([NSThread currentThread].qq_shouldIgnoreAccessKVCException) {
                            return;
                        }
                    }

                    id (*originSelectorIMP)(id, SEL, NSExceptionName name, NSString *, ...);
                    originSelectorIMP = (id (*)(id, SEL, NSExceptionName name, NSString *, ...))originalIMPProvider();
                    va_list args;
                    va_start(args, format);
                    NSString *reason =  [[NSString alloc] initWithFormat:format arguments:args];
                    originSelectorIMP(selfObject, originCMD, raise, reason);
                    va_end(args);
                };
            });
        });
    }
}

@end

@implementation NSThread (QQKVCException)

static const void * const kQQShouldIgnoreAccessKVCException = &kQQShouldIgnoreAccessKVCException;
- (BOOL)qq_shouldIgnoreAccessKVCException {
    return [((NSNumber *)objc_getAssociatedObject(self, kQQShouldIgnoreAccessKVCException)) boolValue];
}

- (void)setQq_shouldIgnoreAccessKVCException:(BOOL)qq_shouldIgnoreAccessKVCException {
    objc_setAssociatedObject(self, kQQShouldIgnoreAccessKVCException, @(qq_shouldIgnoreAccessKVCException), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
