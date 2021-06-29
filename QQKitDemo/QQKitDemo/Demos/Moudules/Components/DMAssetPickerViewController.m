//
//  DMAssetPickerViewController.m
//  QQKitDemo
//
//  Created by Mac on 2021/4/16.
//

#import "DMAssetPickerViewController.h"
#import "QQAssetPickerController.h"
#import <Photos/Photos.h>
#import <PhotosUI/PhotosUI.h>

@interface DMAssetPickerItemView : UIView

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UISwitch *switchButton;

@end

@implementation DMAssetPickerItemView

- (instancetype)initWithTitle:(NSString *)title {
    if (self = [super init]) {
        self.backgroundColor = UIColor.dm_whiteColor;
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:15];
        _titleLabel.text = title;
        _titleLabel.textColor = UIColor.dm_mainTextColor;
        [self addSubview:_titleLabel];
        
        _switchButton = [[UISwitch alloc] init];
        _switchButton.tintColor = UIColor.dm_tintColor;
        [self addSubview:_switchButton];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [_titleLabel sizeToFit];
    _titleLabel.frame = CGRectMake(20, 0, _titleLabel.qq_width, self.qq_height);
    
    [_switchButton sizeToFit];
    _switchButton.frame = CGRectMake(self.qq_width - _switchButton.qq_width - 20, (self.qq_height - _switchButton.qq_height) / 2, _switchButton.qq_width, _switchButton.qq_height);
}

@end

@protocol DMPhotoCellDelegate <NSObject>

@optional
- (void)onPhotoCellDeleteButtonClicked:(QQAsset *)asset;

@end

@interface DMPhotoCell : QQCollectionViewCell

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) QQButton *deleteButton;
@property (nonatomic, strong) QQAsset *asset;
@property (nonatomic, weak) id<DMPhotoCellDelegate> delegate;

@end

@implementation DMPhotoCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        _imageView.layer.cornerRadius = 5;
        _imageView.layer.masksToBounds = YES;
        [self.contentView addSubview:_imageView];
        
        _deleteButton = [[QQButton alloc] init];
        _deleteButton.outsideEdgeInsets = UIEdgeInsetsMake(20, 20, 20, 20);
        [_deleteButton setImage:[UIImage imageNamed:@"icon_delete"] forState:UIControlStateNormal];
        [_deleteButton addTarget:self action:@selector(onDeleteButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_deleteButton];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _imageView.frame = self.bounds;
    _deleteButton.frame = CGRectMake(self.qq_width - 15, 0, 15, 15);
}

- (void)onDeleteButtonClicked {
    if ([self.delegate respondsToSelector:@selector(onPhotoCellDeleteButtonClicked:)]) {
        [self.delegate onPhotoCellDeleteButtonClicked:self.asset];
    }
}

- (void)setAsset:(QQAsset *)asset {
    _asset = asset;
    if (asset) {
        _imageView.image = asset.thumbnailImage;
        _deleteButton.hidden = NO;
    } else {
        _imageView.image = [UIImage imageNamed:@"upload_camera"];
        _deleteButton.hidden = YES;
    }
}

@end

static NSString *kCellReuseID = @"PhotoCell";
@interface DMAssetPickerViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, DMPhotoCellDelegate, QQAssetPickerControllerDelegate>

@property (nonatomic, strong) QQScrollView *scrollView;
@property (nonatomic, strong) DMAssetPickerItemView *itemView1;
@property (nonatomic, strong) DMAssetPickerItemView *itemView2;
@property (nonatomic, strong) DMAssetPickerItemView *itemView3;
@property (nonatomic, strong) DMAssetPickerItemView *itemView4;
@property (nonatomic, strong) DMAssetPickerItemView *itemView5;
@property (nonatomic, strong) DMAssetPickerItemView *itemView6;
@property (nonatomic, strong) DMAssetPickerItemView *itemView7;

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray<QQAsset *> *selectedAssets;

@end

@implementation DMAssetPickerViewController

- (NSMutableArray<QQAsset *> *)selectedAssets {
    if (!_selectedAssets) {
        _selectedAssets = [NSMutableArray array];
    }
    return _selectedAssets;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)initSubviews {
    _scrollView = [[QQScrollView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_scrollView];
    
    _itemView1 = [[DMAssetPickerItemView alloc] initWithTitle:@"允许编辑图片"];
    _itemView1.switchButton.on = YES;
    [_scrollView addSubview:_itemView1];
    
    _itemView2 = [[DMAssetPickerItemView alloc] initWithTitle:@"允许编辑视频"];
    _itemView2.switchButton.on = YES;
    [_scrollView addSubview:_itemView2];
    
    _itemView3 = [[DMAssetPickerItemView alloc] initWithTitle:@"允许多选"];
    _itemView3.switchButton.on = YES;
    [_scrollView addSubview:_itemView3];
    
    _itemView4 = [[DMAssetPickerItemView alloc] initWithTitle:@"允许选择动图"];
    _itemView4.switchButton.on = YES;
    [_scrollView addSubview:_itemView4];
    
    _itemView5 = [[DMAssetPickerItemView alloc] initWithTitle:@"允许选择LivePhoto"];
    _itemView5.switchButton.on = YES;
    [_scrollView addSubview:_itemView5];
    
    _itemView6 = [[DMAssetPickerItemView alloc] initWithTitle:@"只选图片"];
    [_itemView6.switchButton addTarget:self action:@selector(onPickeImageSwitchClicked) forControlEvents:UIControlEventTouchUpInside];
    [_scrollView addSubview:_itemView6];
    
    _itemView7 = [[DMAssetPickerItemView alloc] initWithTitle:@"只选视频"];
    [_itemView7.switchButton addTarget:self action:@selector(onPickeVideoSwitchClicked) forControlEvents:UIControlEventTouchUpInside];
    [_scrollView addSubview:_itemView7];
    
    //
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = 10;
    layout.minimumInteritemSpacing = 10;
    layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    _collectionView.backgroundColor = UIColor.whiteColor;
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.scrollEnabled = NO;
    [_collectionView registerClass:[DMPhotoCell class] forCellWithReuseIdentifier:kCellReuseID];
    [_scrollView addSubview:_collectionView];
    
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    _scrollView.frame = self.view.bounds;
    CGFloat itemHeight = 44;
    _itemView1.frame = CGRectMake(0, 0, _scrollView.qq_width, itemHeight);
    _itemView2.frame = CGRectMake(0, _itemView1.qq_bottom, _scrollView.qq_width, itemHeight);
    _itemView3.frame = CGRectMake(0, _itemView2.qq_bottom, _scrollView.qq_width, itemHeight);
    _itemView4.frame = CGRectMake(0, _itemView3.qq_bottom, _scrollView.qq_width, itemHeight);
    _itemView5.frame = CGRectMake(0, _itemView4.qq_bottom, _scrollView.qq_width, itemHeight);
    _itemView6.frame = CGRectMake(0, _itemView5.qq_bottom, _scrollView.qq_width, itemHeight);
    _itemView7.frame = CGRectMake(0, _itemView6.qq_bottom, _scrollView.qq_width, itemHeight);
    _collectionView.frame = CGRectMake(0, _itemView7.qq_bottom + 20, _scrollView.qq_width, [self collectionViewHeight]);
    _scrollView.contentSize = CGSizeMake(_scrollView.qq_width, _collectionView.qq_bottom + 10);
}

#pragma mark - UICollectionView
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.selectedAssets.count + 1;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    DMPhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellReuseID forIndexPath:indexPath];
    cell.delegate = self;
    if (indexPath.item < self.selectedAssets.count) {
        cell.asset = self.selectedAssets[indexPath.item];
    } else {
        cell.asset = nil;
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self itemSize];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item == self.selectedAssets.count) {

        QQPickerConfiguration *configuration = [[QQPickerConfiguration alloc] init];
        configuration.allowsImageEditing = _itemView1.switchButton.isOn;
        configuration.allowsVideoEditing = _itemView2.switchButton.isOn;
        configuration.allowsMultipleSelection = _itemView3.switchButton.isOn;
        configuration.allowsSelectionGIF = _itemView4.switchButton.isOn;
        configuration.allowsSelectionLivePhoto = _itemView5.switchButton.isOn;
        if (_itemView6.switchButton.isOn) {
            configuration.filterType = QQPickerFilterTypeImage;
        }
        if (_itemView7.switchButton.isOn) {
            configuration.filterType = QQPickerFilterTypeVideo;
        }
        
        configuration.selectionLimit = 9;
        
        QQAssetPickerController *picker = [[QQAssetPickerController alloc] initWithConfiguration:configuration selectedAssets:self.selectedAssets];
        picker.pickerDelegate = self;
        picker.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:picker animated:YES completion:nil];
    }
}

- (void)updateCollectionViewLayout {
    self.collectionView.qq_height = [self collectionViewHeight];
    _scrollView.contentSize = CGSizeMake(_scrollView.qq_width, _collectionView.qq_bottom + 10);
}

- (CGFloat)collectionViewHeight {
    NSInteger count = self.selectedAssets.count + 1;
    NSInteger row = (count - 1) / 3 + 1;
    CGFloat height = ([self itemSize].height + 10) * row + 10;
    return height;
}

- (CGSize)itemSize {
    CGFloat itemWidth = (self.view.qq_width - 10 * 4) / 3;
    return CGSizeMake(itemWidth, itemWidth);;
}

#pragma mark - DMPhotoCellDelegate
- (void)onPhotoCellDeleteButtonClicked:(QQAsset *)asset {
    [self.selectedAssets removeObject:asset];
    [self updateCollectionViewLayout];
    [self.collectionView reloadData];
}

#pragma mark - QQAssetPickerControllerDelegate
- (void)picker:(QQAssetPickerController *)picker didFinishPicking:(NSArray<QQAsset *> *)assets usingOriginalImage:(BOOL)usingOriginalImage {
    self.selectedAssets = [assets mutableCopy];
    [self updateCollectionViewLayout];
    [self.collectionView reloadData];
}

#pragma mark - Actions
- (void)onPickeImageSwitchClicked {
    _itemView7.switchButton.on = NO;
}

- (void)onPickeVideoSwitchClicked {
    _itemView6.switchButton.on = NO;
}

@end
