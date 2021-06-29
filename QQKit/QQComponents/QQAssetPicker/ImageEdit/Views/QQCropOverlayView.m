//
//  QQCropOverlayView.m
//  QQKitDemo
//
//  Created by Mac on 2021/4/9.
//

#import "QQCropOverlayView.h"

static const CGFloat kQQCropOverLayerCornerWidth = 20.0f;

@interface QQCropOverlayView ()

@property (nonatomic, strong) NSArray *horizontalGridLines;
@property (nonatomic, strong) NSArray *verticalGridLines;

@property (nonatomic, strong) NSArray *outerLineViews;   //top, right, bottom, left

@property (nonatomic, strong) NSArray *topLeftLineViews;
@property (nonatomic, strong) NSArray *bottomLeftLineViews;
@property (nonatomic, strong) NSArray *bottomRightLineViews;
@property (nonatomic, strong) NSArray *topRightLineViews;

@end

@implementation QQCropOverlayView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.clipsToBounds = NO;
    self.backgroundColor = [UIColor clearColor];
    
    UIView *(^newLineView)(void) = ^UIView *(void) {
        return [self createNewLineView];
    };
    
    _horizontalGridLines = @[newLineView(), newLineView()];
    _verticalGridLines = @[newLineView(), newLineView()];
    
    _outerLineViews = @[newLineView(), newLineView(), newLineView(), newLineView()];
    
    _topLeftLineViews = @[newLineView(), newLineView()];
    _bottomLeftLineViews = @[newLineView(), newLineView()];
    _topRightLineViews = @[newLineView(), newLineView()];
    _bottomRightLineViews = @[newLineView(), newLineView()];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    if (_outerLineViews) {
        [self layoutLines];
    }
}

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    if (_outerLineViews) {
        [self layoutLines];
    }
}

- (void)setGridHidden:(BOOL)gridHidden {
    [self setGridHidden:gridHidden animated:NO];
}

- (void)setGridHidden:(BOOL)hidden animated:(BOOL)animated {
    _gridHidden = hidden;
    if (animated) {
        [UIView animateWithDuration:hidden?0.35f:0.2f animations:^{
            for (UIView *lineView in self.horizontalGridLines) {
                lineView.alpha = hidden ? 0.0f : 1.0f;
            }
                
            for (UIView *lineView in self.verticalGridLines) {
                lineView.alpha = hidden ? 0.0f : 1.0f;
            }
                
        }];
    } else {
        for (UIView *lineView in self.horizontalGridLines) {
            lineView.alpha = hidden ? 0.0f : 1.0f;
        }
        
        for (UIView *lineView in self.verticalGridLines) {
            lineView.alpha = hidden ? 0.0f : 1.0f;
        }
    }
}

- (void)layoutLines {
    CGSize boundsSize = self.bounds.size;
    
    // 边框线
    for (NSInteger i = 0; i < self.outerLineViews.count; i++) {
        UIView *lineView = self.outerLineViews[i];
        CGRect frame = CGRectZero;
        switch (i) {
            case 0: frame = CGRectMake(0, -1, boundsSize.width + 2, 1); break; //top
            case 1: frame = CGRectMake(boundsSize.width, 0, 1, boundsSize.height); break; //right
            case 2: frame = CGRectMake(-1, boundsSize.height, boundsSize.width + 2, 1); break; //bottom
            case 3: frame = CGRectMake(-1, 0, 1, boundsSize.height + 1); break; //left
            default: break;
        }
        lineView.frame = frame;
    }
    
    // 边角线
    NSArray *cornerLines = @[self.topLeftLineViews, self.topRightLineViews, self.bottomRightLineViews, self.bottomLeftLineViews];
    for (NSInteger i = 0; i < cornerLines.count; i++) {
        NSArray *cornerLine = cornerLines[i];
        
        CGRect verticalFrame = CGRectZero, horizontalFrame = CGRectZero;
        switch (i) {
            case 0: //top left
                verticalFrame = CGRectMake(-3, -3, 3, kQQCropOverLayerCornerWidth + 3);
                horizontalFrame = CGRectMake(0, -3, kQQCropOverLayerCornerWidth, 3);
                break;
            case 1: //top right
                verticalFrame = CGRectMake(boundsSize.width, -3, 3, kQQCropOverLayerCornerWidth + 3);
                horizontalFrame = CGRectMake(boundsSize.width - kQQCropOverLayerCornerWidth, -3, kQQCropOverLayerCornerWidth, 3);
                break;
            case 2: //bottom right
                verticalFrame = CGRectMake(boundsSize.width, boundsSize.height - kQQCropOverLayerCornerWidth, 3, kQQCropOverLayerCornerWidth + 3);
                horizontalFrame = CGRectMake(boundsSize.width - kQQCropOverLayerCornerWidth, boundsSize.height , kQQCropOverLayerCornerWidth, 3);
                break;
            case 3: //bottom left
                verticalFrame = CGRectMake(-3, boundsSize.height - kQQCropOverLayerCornerWidth, 3, kQQCropOverLayerCornerWidth);
                horizontalFrame = CGRectMake(-3, boundsSize.height, kQQCropOverLayerCornerWidth + 3, 3);
                break;
        }
        
        [cornerLine[0] setFrame:verticalFrame];
        [cornerLine[1] setFrame:horizontalFrame];
    }
    
    //水平格子线
    CGFloat thickness = 1.0f / [[UIScreen mainScreen] scale];
    NSInteger numberOfLines = self.horizontalGridLines.count;
    CGFloat padding = (CGRectGetHeight(self.bounds) - (thickness*numberOfLines)) / (numberOfLines + 1);
    for (NSInteger i = 0; i < numberOfLines; i++) {
        UIView *lineView = self.horizontalGridLines[i];
        CGRect frame = CGRectZero;
        frame.size.height = thickness;
        frame.size.width = CGRectGetWidth(self.bounds);
        frame.origin.y = (padding * (i + 1)) + (thickness * i);
        lineView.frame = frame;
    }
    
    //垂直格子线
    numberOfLines = self.verticalGridLines.count;
    padding = (CGRectGetWidth(self.bounds) - (thickness*numberOfLines)) / (numberOfLines + 1);
    for (NSInteger i = 0; i < numberOfLines; i++) {
        UIView *lineView = self.verticalGridLines[i];
        CGRect frame = CGRectZero;
        frame.size.width = thickness;
        frame.size.height = CGRectGetHeight(self.bounds);
        frame.origin.x = (padding * (i + 1)) + (thickness * i);
        lineView.frame = frame;
    }
}

- (UIView *)createNewLineView {
    UIView *line = [[UIView alloc] init];
    line.backgroundColor = [UIColor whiteColor];
    [self addSubview:line];
    return line;
}

@end
