//
//  YZDrawerViewController.m
//  CYSlideView
//
//  Created by YeYiFeng on 2018/3/30.
//  Copyright © 2018年 叶子. All rights reserved.
//
// 主页面用来管理其他三个页面的
#import "YZDrawerViewController.h"
#import <objc/runtime.h>
typedef NS_ENUM(NSInteger, YZDrawerViewControllerType) {
    YZDrawerViewControllerTypeNone,
    YZDrawerViewControllerTypeCloseLeft,
    YZDrawerViewControllerTypeOpenLeft,
    YZDrawerViewControllerTypeOpenRight,
    YZDrawerViewControllerTypeCloseRight
};
@interface YZDrawerViewController ()<UIGestureRecognizerDelegate, UINavigationControllerDelegate> {
    CGRect _beginCenterContentViewFrame;
    CGRect _beginDrawerContentViewFrame;
    CGFloat kPalaxPercent; // 同步滚动的视差比例 1.0
    CGFloat _beginningScale;
}
// 左边抽屉菜单的控制器
@property (strong, nonatomic) UIViewController *leftController;
// 中间菜单的控制器
@property (strong, nonatomic) UIViewController *centerController;
// 右边抽屉菜单的控制器
@property (strong, nonatomic) UIViewController *rightController;
// 管理中间菜单view
@property (strong, nonatomic) UIView *centerContentView;
// 管理左右抽屉菜单的view
@property (strong, nonatomic) UIView *drawerContentView;

/** 设置image时才会加载 */
@property (strong, nonatomic) UIImageView *backgroundImageView;
//点击(tap)手势, 用来关闭打开的抽屉菜单
@property (strong, nonatomic) UITapGestureRecognizer *tapGesture;
//拖拽手势(pan), 用来滑动打开和关闭抽屉菜单.
@property (strong, nonatomic) UIPanGestureRecognizer *panGesture;

@property (assign, nonatomic) BOOL isLeftDrawerOpen;
@property (assign, nonatomic) BOOL isRightDrawerOpen;
@property (assign, nonatomic) BOOL isAnimating;
@end


@implementation YZDrawerViewController
#pragma mark - 初始化
- (instancetype)initWithLeftController:(UIViewController *)leftController centerController:(UIViewController *)centerViewController rightController:(UIViewController *)rightController {
    if (self = [super initWithNibName:nil bundle:nil]) {
        // 赋值
        _leftController = leftController;
        _centerController = centerViewController;
        _rightController = rightController;
        // 需要的初始化 -- 初始化常量, 添加手势, 添加必要的view
        [self commonInit];
    }
    return self;
}
// 单个抽屉的初始化，直接调用上面的方法
- (instancetype)initWithLeftController:(UIViewController *)leftController centerController:(UIViewController *)centerViewController {
    return [self initWithLeftController:leftController centerController:centerViewController rightController:nil];
}

- (instancetype)initWithRightController:(UIViewController *)rightController centerController:(UIViewController *)centerViewController {
    return [self initWithLeftController:nil centerController:centerViewController rightController:rightController];
    
}
// 配置页面布局，添加顺序为重要环节
- (void)commonInit {
 
    _maxLeftControllerWidth = _leftController ? 200.0f : 0.0f;
    _maxRightControllerWidth = _rightController ? 200.0f : 0.0f;
    _minimumHoldScrollVeloticyX = 200.0f;
    _minimumHoldScrollTranstionXPercent = 0.35f;
    kPalaxPercent = 1.0f;
    _scrollEdgeWidth = 80.0f;
    _minimumScale = 0.7f;
    _isDrawingShadow = YES;
    _canOpenDrawerAtAnyPage = NO;
    _drawerControllerStyle = YZDrawerViewControllerStyleNormalSlide;
    _drawerControllerOpenStyle = YZDrawerViewControllerStyleFromAnyWhere;
    self.isAnimating = NO;
    
    // 添加两个管理view
    [self.view addSubview:self.drawerContentView];
    [self.view addSubview:self.centerContentView];
    // 添加手势到centerView上面，我们希望只有内容上的view上面能够响应手势
    [self.centerContentView addGestureRecognizer:self.panGesture];
    [self.centerContentView addGestureRecognizer:self.tapGesture];
    // 添加子视图控制器到容器(self)中
    [self addDrawerViewController:_leftController];
    [self addDrawerViewController:_rightController];
    // 最后添加centerViewController，让他的view显示在最上方
    [self addCenterViewController:_centerController];
    
}
// 添加管理左右的控制器
- (void)addDrawerViewController:(UIViewController *)drawerViewController
{
    if (drawerViewController) {
        // 添加子视图控制器
        [self addChildViewController:drawerViewController];
        drawerViewController.view.frame = CGRectZero;
        // 添加子视图的控制器view到容器view中来
        [self.drawerContentView addSubview:drawerViewController.view];
        // 添加完成后，必须调用这个方法通知系统，添加的操作已经完成
        [drawerViewController didMoveToParentViewController:self];
    }
}
// 添加中间控制器
- (void)addCenterViewController:(UIViewController *)centerViewController
{
    if (centerViewController) {
        [self addChildViewController:centerViewController];
        centerViewController.view.frame = CGRectZero;
        [self.centerContentView addSubview:centerViewController.view];
        [centerViewController didMoveToParentViewController:self];
    }
    
}
-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    NSLog(@"-- viewWillLayoutSubviews --");
    // 中间需要全屏显示，初始化frame和当前控制器的view的尺寸一样
    self.centerContentView.frame = self.view.bounds;
    /*
     (CGRect) $0 = (origin = (x = 200, y = 0), size = (width = 775, height = 667))
     */
    self.drawerContentView.frame = CGRectMake(_maxLeftControllerWidth, 0, self.view.bounds.size.width +(_maxLeftControllerWidth + _maxRightControllerWidth), self.view.bounds.size.height);
    /*
     (CGRect) $0 = (origin = (x = 0, y = 0), size = (width = 375, height = 667))

     */
    _centerController.view.frame = self.centerContentView.bounds;
    /*
     (CGRect) $1 = (origin = (x = 0, y = 0), size = (width = 200, height = 667))
     */
    _leftController.view.frame = CGRectMake(0, 0, _maxLeftControllerWidth, self.view.bounds.size.height);
    /*
     CGRect) $2 = (origin = (x = 575, y = 0), size = (width = 200, height = 667))
     */
    _rightController.view.frame = CGRectMake(self.drawerContentView.bounds.size.width-_maxRightControllerWidth, 0, _maxRightControllerWidth, self.view.bounds.size.height);
    
}

- (BOOL)shouldAutomaticallyForwardAppearanceMethods
{
    return NO;
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (_centerController) {
        [_centerController beginAppearanceTransition:YES animated:animated];
    }
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (_centerController) {
        [_centerController endAppearanceTransition];
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (UITapGestureRecognizer *)tapGesture {
    if (!_tapGesture) {
        _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        _tapGesture.numberOfTapsRequired = 1;
        _tapGesture.delegate = self;
    }
    return  _tapGesture;
}

- (UIPanGestureRecognizer *)panGesture {
    if (!_panGesture) {
        _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        _panGesture.delegate = self;
    }
    return _panGesture;
}

- (UIView *)centerContentView {
    if (!_centerContentView) {
        _centerContentView = [UIView new];
        _centerContentView.backgroundColor = [UIColor clearColor];
//        _centerContentView.backgroundColor = [UIColor redColor];

        _centerContentView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    }
    return _centerContentView;
}

- (UIView *)drawerContentView {
    if (!_drawerContentView) {
        _drawerContentView = [UIView new];
        _drawerContentView.backgroundColor = [UIColor clearColor];
//        _drawerContentView.backgroundColor = [UIColor greenColor];
        _drawerContentView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    }
    return _drawerContentView;
    
}

- (UIImageView *)backgroundImageView {
    if (!_backgroundImage) {
        return nil;
    }
    
    if (!_backgroundImageView) {
        _backgroundImageView = [[UIImageView alloc] init];
        _backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.view insertSubview:_backgroundImageView atIndex:0];
    }
    
    return _backgroundImageView;
}

- (void)setBackgroundImage:(UIImage *)backgroundImage {
    _backgroundImage = backgroundImage;
    if (backgroundImage) {
        self.backgroundImageView.image = backgroundImage;
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
