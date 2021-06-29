//
//  NSDate+QQExtension.h
//  QQKitDemo
//
//  Created by Mac on 2021/4/13.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDate (QQExtension)

#pragma mark - Component Properties

@property (nonatomic, readonly) NSInteger qq_year;
@property (nonatomic, readonly) NSInteger qq_month;
@property (nonatomic, readonly) NSInteger qq_day;
@property (nonatomic, readonly) NSInteger qq_hour;
@property (nonatomic, readonly) NSInteger qq_minute;
@property (nonatomic, readonly) NSInteger qq_second;
@property (nonatomic, readonly) NSInteger qq_nanosecond;
@property (nonatomic, readonly) NSInteger qq_weekday;
@property (nonatomic, readonly) NSInteger qq_weekdayOrdinal;
@property (nonatomic, readonly) NSInteger qq_weekOfMonth;
@property (nonatomic, readonly) NSInteger qq_weekOfYear;
@property (nonatomic, readonly) NSInteger qq_yearForWeekOfYear;
@property (nonatomic, readonly) NSInteger qq_quarter;
@property (nonatomic, readonly) BOOL qq_isLeapMonth;
@property (nonatomic, readonly) BOOL qq_isLeapYear;
@property (nonatomic, readonly) BOOL qq_isToday;
@property (nonatomic, readonly) BOOL qq_isYesterday;

#pragma mark - Date modify

- (nullable NSDate *)qq_dateByAddingYears:(NSInteger)years;
- (nullable NSDate *)qq_dateByAddingMonths:(NSInteger)months;
- (nullable NSDate *)qq_dateByAddingWeeks:(NSInteger)weeks;
- (nullable NSDate *)qq_dateByAddingDays:(NSInteger)days;
- (nullable NSDate *)qq_dateByAddingHours:(NSInteger)hours;
- (nullable NSDate *)qq_dateByAddingMinutes:(NSInteger)minutes;
- (nullable NSDate *)qq_dateByAddingSeconds:(NSInteger)seconds;

#pragma mark - Date Format

- (nullable NSString *)qq_stringWithFormat:(NSString *)format;

- (nullable NSString *)qq_stringWithFormat:(NSString *)format
                               timeZone:(nullable NSTimeZone *)timeZone
                                 locale:(nullable NSLocale *)locale;

- (nullable NSString *)qq_stringWithISOFormat;

/**
 时间戳转时间字符串，注意 timestamp 单位是秒，如果是毫秒，记得除以1000
 */
+ (nullable NSString *)qq_stringWithTimestamp:(NSTimeInterval)timestamp format:(NSString *)format;

+ (nullable NSDate *)qq_dateWithString:(NSString *)dateString format:(NSString *)format;

+ (nullable NSDate *)qq_dateWithString:(NSString *)dateString
                             format:(NSString *)format
                           timeZone:(nullable NSTimeZone *)timeZone
                             locale:(nullable NSLocale *)locale;

+ (nullable NSDate *)qq_dateWithISOFormatString:(NSString *)dateString;

@end

NS_ASSUME_NONNULL_END
