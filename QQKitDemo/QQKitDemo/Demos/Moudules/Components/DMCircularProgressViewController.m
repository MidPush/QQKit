//
//  DMCircularProgressViewController.m
//  QQKitDemo
//
//  Created by xuze on 2021/4/16.
//

#import "DMCircularProgressViewController.h"
#import "QQCircularProgressView.h"

@interface DMCircularProgressViewController ()

@property (strong, nonatomic) NSTimer *timer;
@property (nonatomic, strong) QQCircularProgressView *progressView1;
@property (nonatomic, strong) QQCircularProgressView *progressView2;
@property (nonatomic, strong) QQCircularProgressView *progressView3;
@property (nonatomic, strong) QQCircularProgressView *progressView4;
@property (nonatomic, strong) QQCircularProgressView *progressView5;

@end

@implementation DMCircularProgressViewController

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self stopAnimation];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)initSubviews {
    
    self.progressView1 = [[QQCircularProgressView alloc] init];
    self.progressView1.roundedCorners = YES;
    self.progressView1.trackTintColor = [UIColor clearColor];
    [self.view addSubview:self.progressView1];
    
    self.progressView2 = [[QQCircularProgressView alloc] init];
    self.progressView2.roundedCorners = NO;
    [self.view addSubview:self.progressView2];
    
    self.progressView3 = [[QQCircularProgressView alloc] init];
    self.progressView3.trackTintColor = [UIColor blackColor];
    self.progressView3.progressTintColor = [UIColor yellowColor];
    self.progressView3.thicknessRatio = 1.0;
    self.progressView3.clockwise = NO;
    [self.view addSubview:self.progressView3];
    
    self.progressView4 = [[QQCircularProgressView alloc] init];
    self.progressView4.roundedCorners = YES;
    self.progressView4.innerTintColor = [UIColor redColor];
    [self.view addSubview:self.progressView4];
    
    self.progressView5 = [[QQCircularProgressView alloc] init];
    self.progressView5.roundedCorners = YES;
    self.progressView5.progress = 0.4;
    self.progressView5.indeterminate = YES;
    [self.view addSubview:self.progressView5];
    
    [self startAnimation];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.progressView1.frame = CGRectMake((self.view.qq_width - 60) / 2, QQUIHelper.navigationBarMaxY + 20, 60, 60);
    self.progressView2.frame = CGRectMake(self.progressView1.qq_left, self.progressView1.qq_bottom + 10, self.progressView1.qq_width, self.progressView1.qq_height);
    self.progressView3.frame = CGRectMake(self.progressView2.qq_left, self.progressView2.qq_bottom + 10, self.progressView2.qq_width, self.progressView2.qq_height);
    self.progressView4.frame = CGRectMake(self.progressView3.qq_left, self.progressView3.qq_bottom + 10, self.progressView3.qq_width, self.progressView3.qq_height);
    self.progressView5.frame = CGRectMake(self.progressView4.qq_left, self.progressView4.qq_bottom + 10, self.progressView4.qq_width, self.progressView4.qq_height);
}

- (void)progressChange {
    NSArray *progressViews = @[self.progressView1,
                               self.progressView2,
                               self.progressView3];
    for (QQCircularProgressView *progressView in progressViews) {
        CGFloat progress =  progressView.progress + 0.01;
        [progressView setProgress:progress animated:YES];
        if (progressView.progress >= 1.0 && [self.timer isValid]) {
            [progressView setProgress:0.0 animated:YES];
        }
    }
    
    // Labeled progress views
    NSArray *labeledProgressViews = @[self.progressView4];
    for (QQCircularProgressView *labeledProgressView in labeledProgressViews) {
        CGFloat progress = labeledProgressView.progress + 0.01;
        [labeledProgressView setProgress:progress animated:YES];
        
        if (labeledProgressView.progress >= 1.0 && [self.timer isValid]) {
            [labeledProgressView setProgress:0.0 animated:YES];
        }
        
        labeledProgressView.progressLabel.text = [NSString stringWithFormat:@"%.2f", labeledProgressView.progress];
    }
}

- (void)startAnimation {
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.03
                                                  target:self
                                                selector:@selector(progressChange)
                                                userInfo:nil
                                                 repeats:YES];
}

- (void)stopAnimation {
    [self.timer invalidate];
    self.timer = nil;
}

@end
