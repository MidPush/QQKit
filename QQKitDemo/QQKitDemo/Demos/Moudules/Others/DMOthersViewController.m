//
//  DMOthersViewController.m
//  QQKitDemo
//
//  Created by xuze on 2021/4/14.
//

#import "DMOthersViewController.h"
#import <CoreTelephony/CoreTelephonyDefines.h>
#import <OpenGLES/OpenGLESAvailability.h>
#import <Photos/Photos.h>
#import <PhotosUI/PhotosUI.h>
#import <SafariServices/SafariServices.h>
#import "QQWebViewController.h"

@interface AppInfo : NSObject

@property (nonatomic, copy) NSString *bundleID;
@property (nonatomic, copy) NSString *appName;

@end

@implementation AppInfo

@end

@interface DMOthersViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) QQTableView *tableView;
@property (nonatomic, strong) id workspace;
@property (nonatomic, strong) NSMutableArray<AppInfo *> *datas;

@end

@implementation DMOthersViewController

- (NSMutableArray *)datas {
    if (!_datas) {
        _datas = [NSMutableArray array];
    }
    return _datas;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadAppInfo];
}

- (void)initSubviews {
    _tableView = [[QQTableView alloc] initWithFrame:self.view.bounds style:0];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.sectionHeaderHeight = 0;
    _tableView.sectionFooterHeight = 0;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [self.view addSubview:_tableView];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    _tableView.frame = self.view.bounds;
}

- (void)loadAppInfo {

    self.datas = [NSMutableArray array];
    
    Class appClass = NSClassFromString(@"LSApplicationWorkspace");
    _workspace = [appClass performSelector:@selector(defaultWorkspace)];
    
    NSArray *apps = [_workspace performSelector:@selector(installedPlugins)];
    for (NSInteger i = 0; i < apps.count; i++) {
        id plugInKitProxy = apps[i];
        if (!plugInKitProxy) continue;
        id applicationProxy = [plugInKitProxy performSelector:@selector(containingBundle)];
        if (!applicationProxy) continue;
        
        NSMutableArray *ivars = [NSMutableArray array];
        [applicationProxy qq_enumrateIvarsUsingBlock:^(Ivar  _Nonnull ivar, NSString * _Nonnull ivarDescription) {
            [ivars addObject:ivarDescription];
        }];
        
        NSString *bundleID = nil;
        NSString *appName = nil;
        if ([ivars containsObject:@"_diskUsage"]) {
            id diskUsage = [applicationProxy qq_valueForKey:@"_diskUsage"];
            bundleID = [diskUsage qq_valueForKey:@"_bundleIdentifier"];
            appName = [applicationProxy qq_valueForKey:@"itemName"];
        } else {
            bundleID = [applicationProxy qq_valueForKey:@"_bundleIdentifier"];
            appName = [applicationProxy qq_valueForKey:@"itemName"];
        }
        if (![self containsApp:bundleID]) {
            AppInfo *appInfo = [[AppInfo alloc] init];
            appInfo.bundleID = bundleID;
            appInfo.appName = appName;
            if ([bundleID containsString:@"com.apple."]) {
                [self.datas insertObject:appInfo atIndex:0];
            } else {
                [self.datas addObject:appInfo];
            }
        }
    }
    self.navigationItem.title = [NSString stringWithFormat:@"%ld个APP", (long)self.datas.count];
    [self.tableView reloadData];
}

- (BOOL)containsApp:(NSString *)bundleID {
    if (!bundleID) return YES;
    for (AppInfo *appInfo in self.datas) {
        if ([appInfo.bundleID isEqualToString:bundleID]) {
            return YES;
        }
    }
    return NO;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.datas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }
    AppInfo *appInfo = self.datas[indexPath.row];
    cell.textLabel.text = appInfo.appName;
    cell.detailTextLabel.text = appInfo.bundleID;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSArray *testURLs = @[
                         @"https:www.baidu.com",
                         @"https://taoke.zswx141319.com/wap/?uid=4",
                         @"https://www.jianshu.com/p/176537b0d9dd"];
    
    NSURL *url = [NSURL URLWithString:testURLs[1]];

    if (indexPath.row == 0) {
        QQWebViewController *vc = [[QQWebViewController alloc] initWithURL:url];
        [self.navigationController pushViewController:vc animated:YES];
        vc.showsToolbar = YES;
        vc.hidesToolbarOnSwipe = YES;
        vc.progressTintColor = UIColor.dm_tintColor;
    } else {
        SFSafariViewControllerConfiguration *c = [[SFSafariViewControllerConfiguration alloc] init];
        c.entersReaderIfAvailable = NO;
        c.barCollapsingEnabled = NO;
        
        SFSafariViewController *v = [[SFSafariViewController alloc] initWithURL:url];
        v.preferredControlTintColor = UIColor.dm_tintColor;
        v.dismissButtonStyle = SFSafariViewControllerDismissButtonStyleClose;
        [self presentViewController:v animated:YES completion:nil];
    }
    return;
    AppInfo *appInfo = self.datas[indexPath.row];
    [_workspace performSelector:@selector(openApplicationWithBundleID:) withObject:appInfo.bundleID];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.01f;
}

- (void)push {
    
    [SFSafariViewController qq_enumratePropertiesUsingBlock:^(objc_property_t  _Nonnull property, NSString * _Nonnull propertyName) {
        NSLog(@"%@", propertyName);
    }];
    
    [SFSafariViewController qq_enumrateIvarsUsingBlock:^(Ivar  _Nonnull ivar, NSString * _Nonnull ivarDescription) {
        NSLog(@"%@", ivarDescription);
    }];
    
    
    
}

@end
