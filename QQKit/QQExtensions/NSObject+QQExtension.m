//
//  NSObject+QQExtension.m
//  NNKit
//
//  Created by xuze on 2021/2/27.
//

#import "NSObject+QQExtension.h"
#import "NSException+QQExtension.h"

@implementation NSObject (QQExtension)

- (id)qq_valueForKey:(NSString *)key {
    if (@available(iOS 13.0, *)) {
        if ([self isKindOfClass:[UIView class]]) {
            [NSThread currentThread].qq_shouldIgnoreAccessKVCException = YES;
            id value = [self valueForKey:key];
            [NSThread currentThread].qq_shouldIgnoreAccessKVCException = NO;
            return value;
        }
    }
    return [self valueForKey:key];
}

- (void)qq_setValue:(id)value forKey:(NSString *)key {
    if (@available(iOS 13.0, *)) {
        if ([self isKindOfClass:[UIView class]]) {
            [NSThread currentThread].qq_shouldIgnoreAccessKVCException = YES;
            [self setValue:value forKey:key];
            [NSThread currentThread].qq_shouldIgnoreAccessKVCException = NO;
            return;
        }
    }
    [self setValue:value forKey:key];
}

- (nullable id)qq_valueForKeyPath:(NSString *)keyPath {
    if (@available(iOS 13.0, *)) {
        if ([self isKindOfClass:[UIView class]]) {
            [NSThread currentThread].qq_shouldIgnoreAccessKVCException = YES;
            id value = [self valueForKeyPath:keyPath];
            [NSThread currentThread].qq_shouldIgnoreAccessKVCException = NO;
            return value;
        }
    }
    return [self valueForKeyPath:keyPath];
}

- (void)qq_setValue:(nullable id)value forKeyPath:(NSString *)keyPath {
    if (@available(iOS 13.0, *)) {
        if ([self isKindOfClass:[UIView class]]) {
            [NSThread currentThread].qq_shouldIgnoreAccessKVCException = YES;
            [self setValue:value forKeyPath:keyPath];
            [NSThread currentThread].qq_shouldIgnoreAccessKVCException = NO;
            return;
        }
    }
    [self setValue:value forKeyPath:keyPath];
}

- (BOOL)qq_hasOverrideMethod:(SEL)selector ofSuperclass:(Class)superclass {
    return [NSObject qq_hasOverrideMethod:selector forClass:self.class ofSuperclass:superclass];
}

+ (BOOL)qq_hasOverrideMethod:(SEL)selector forClass:(Class)aClass ofSuperclass:(Class)superclass {
    if (![aClass isSubclassOfClass:superclass]) {
        return NO;
    }
    
    if (![superclass instancesRespondToSelector:selector]) {
        return NO;
    }
    
    Method superclassMethod = class_getInstanceMethod(superclass, selector);
    Method instanceMethod = class_getInstanceMethod(aClass, selector);
    if (!instanceMethod || instanceMethod == superclassMethod) {
        return NO;
    }
    return YES;
}

- (void)qq_enumrateIvarsUsingBlock:(void (^)(Ivar _Nonnull, NSString * _Nonnull))block {
    unsigned int outCount = 0;
    Ivar *ivars = class_copyIvarList(self.class, &outCount);
    
    for (unsigned int i = 0; i < outCount; i ++) {
        Ivar ivar = ivars[i];
        const char *name = ivar_getName(ivar);
        NSString *ivarName = nil;
        if (name) {
            ivarName = [NSString stringWithFormat:@"%s", name];
        }
        if (block) {
            block(ivar, ivarName);
        }
    }
    
    free(ivars);
}

- (void)qq_enumratePropertiesUsingBlock:(void (^)(objc_property_t property, NSString *propertyName))block {
    unsigned int propertiesCount = 0;
    objc_property_t *properties = class_copyPropertyList(self.class, &propertiesCount);
    
    for (unsigned int i = 0; i < propertiesCount; i++) {
        objc_property_t property = properties[i];
        const char *name = property_getName(property);
        NSString *propertyName = nil;
        if (name) {
            propertyName = [NSString stringWithFormat:@"%s", name];
        }
        if (block) {
            block(property, propertyName);
        }
    }
    
    free(properties);
}

/**
 使用 block 遍历当前实例的所有方法，不包含 superclasses 里定义的 method
 */
- (void)qq_enumrateInstanceMethodsUsingBlock:(void (^)(Method method, SEL selector))block {
    unsigned int methodCount = 0;
    Method *methods = class_copyMethodList(self.class, &methodCount);
    
    for (unsigned int i = 0; i < methodCount; i++) {
        Method method = methods[i];
        SEL selector = method_getName(method);
        if (block) {
            block(method, selector);
        }
    }
    
    free(methods);
}

/**
 遍历某个 protocol 里的所有方法
 
 @param protocol 要遍历的 protocol，例如 \@protocol(xxx)
 @param block 遍历过程中调用的 block
 */
+ (void)qq_enumerateProtocolMethods:(Protocol *)protocol usingBlock:(void (^)(SEL selector))block {
    unsigned int methodCount = 0;
    struct objc_method_description *methods = protocol_copyMethodDescriptionList(protocol, NO, YES, &methodCount);
    
    for (int i = 0; i < methodCount; i++) {
        struct objc_method_description methodDescription = methods[i];
        if (block) {
            block(methodDescription.name);
        }
    }
    
    free(methods);
}

@end


