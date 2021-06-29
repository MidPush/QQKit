//
//  NSObject+QQExtension.h
//  NNKit
//
//  Created by xuze on 2021/2/27.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (QQExtension)

#pragma mark - KeyValueCoding
/**
 iOS 13 后系统禁止通过 KVC 访问私有 API，因此提供这种方式在遇到 access prohibited 的异常时可以忽略此异常。
 */
- (nullable id)qq_valueForKey:(NSString *)key;
- (void)qq_setValue:(nullable id)value forKey:(NSString *)key;
- (nullable id)qq_valueForKeyPath:(NSString *)keyPath;
- (void)qq_setValue:(nullable id)value forKeyPath:(NSString *)keyPath;

#pragma mark - ClassInfo
/**
 判断当前类是否有重写某个父类的指定方法
 */
- (BOOL)qq_hasOverrideMethod:(SEL)selector ofSuperclass:(Class)superclass;

/**
 判断指定的类是否有重写某个父类的指定方法
 */
+ (BOOL)qq_hasOverrideMethod:(SEL)selector forClass:(Class)aClass ofSuperclass:(Class)superclass;

/**
 使用 block 遍历指定 class 的所有成员变量（也即 _xxx 那种），不包含 property 对应的 _property 成员变量，也不包含 superclasses 里定义的变量
 */
- (void)qq_enumrateIvarsUsingBlock:(void (^)(Ivar ivar, NSString *ivarDescription))block;

/**
 使用 block 遍历指定 class 的所有属性，不包含 superclasses 里定义的 property
 */
- (void)qq_enumratePropertiesUsingBlock:(void (^)(objc_property_t property, NSString *propertyName))block;

/**
 使用 block 遍历当前实例的所有方法，不包含 superclasses 里定义的 method
 */
- (void)qq_enumrateInstanceMethodsUsingBlock:(void (^)(Method method, SEL selector))block;

/**
 遍历某个 protocol 里的所有方法
 
 @param protocol 要遍历的 protocol，例如 \@protocol(xxx)
 @param block 遍历过程中调用的 block
 */
+ (void)qq_enumerateProtocolMethods:(Protocol *)protocol usingBlock:(void (^)(SEL selector))block;

@end

NS_ASSUME_NONNULL_END
