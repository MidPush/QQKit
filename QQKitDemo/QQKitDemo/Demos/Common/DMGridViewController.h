//
//  DMGridViewController.h
//  QQKitDemo
//
//  Created by xuze on 2021/4/14.
//

#import "DMViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface DMGridViewController : DMViewController

@property (nonatomic, strong) NSArray<NSDictionary *> *dataSource;

- (void)initDataSource;

@end

NS_ASSUME_NONNULL_END
