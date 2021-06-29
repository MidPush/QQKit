//
//  QQRuntime.h
//  QQKitDemo
//
//  Created by Mac on 2021/3/1.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

CG_INLINE BOOL HasOverrideSuperclassMethod(Class targetClass, SEL targetSelector) {
    Method method = class_getInstanceMethod(targetClass, targetSelector);
    if (!method) return NO;
    
    Method methodOfSuperclass = class_getInstanceMethod(class_getSuperclass(targetClass), targetSelector);
    if (!methodOfSuperclass) return YES;
    
    return method != methodOfSuperclass;
}

CG_INLINE BOOL OverrideImplementation(Class targetClass, SEL targetSelector, id (^implementationBlock)(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void))) {
    Method originMethod = class_getInstanceMethod(targetClass, targetSelector);
    IMP imp = method_getImplementation(originMethod);
    BOOL hasOverride = HasOverrideSuperclassMethod(targetClass, targetSelector);
    
    IMP (^originalIMPProvider)(void) = ^IMP(void) {
        IMP result = NULL;
        if (hasOverride) {
            result = imp;
        } else {
            Class superclass = class_getSuperclass(targetClass);
            result = class_getMethodImplementation(superclass, targetSelector);
        }
        if (!result) {
            result = imp_implementationWithBlock(^(id selfObject){
                NSLog(([NSString stringWithFormat:@"%@", targetClass]), @"%@ 没有初始实现，%@\n%@", NSStringFromSelector(targetSelector), selfObject, [NSThread callStackSymbols]);
            });
        }
        return result;
    };
    
    if (hasOverride) {
        method_setImplementation(originMethod, imp_implementationWithBlock(implementationBlock(targetClass, targetSelector, originalIMPProvider)));
    } else {
        const char *typeEncoding = method_getTypeEncoding(originMethod);
        if (!typeEncoding) {
            NSMethodSignature *signature = [targetClass instanceMethodSignatureForSelector:targetSelector];
            SEL sel = NSSelectorFromString([NSString stringWithFormat:@"_%@String", @"type"]);
            if ([signature respondsToSelector:sel]) {
                #pragma clang diagnostic push
                #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                    NSString *typeString = [signature performSelector:sel];
                #pragma clang diagnostic pop
                typeEncoding = typeString.UTF8String;
            }
        }
        class_addMethod(targetClass, targetSelector, imp_implementationWithBlock(implementationBlock(targetClass, targetSelector, originalIMPProvider)), typeEncoding);
    }
    
    return YES;
}
