//
//  DMViewController.m
//  QQKitDemo
//
//  Created by xuze on 2021/4/14.
//

#import "DMViewController.h"

@interface DMViewController ()

@end

@implementation DMViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (UIImage *)navBarBackgroundImage {
    return [UIImage qq_imageWithStartColor:[UIColor.qq_randomColor colorWithAlphaComponent:0.98] endColor:[UIColor.qq_randomColor colorWithAlphaComponent:0.98] size:CGSizeMake(QQUIHelper.screenWidth, QQUIHelper.navigationBarMaxY)];
}

- (void)dealloc {
    NSLog(@"%@ dealloc", NSStringFromClass(self.class));
}

@end
