//
//  ViewController.m
//  CYSlideView
//
//  Created by YeYiFeng on 2018/3/29.
//  Copyright © 2018年 叶子. All rights reserved.
//

#import "ViewController.h"
#import "YZLeftViewController.h"
#import "YZRightViewController.h"
#import "YZCenterViewController.h"
#import "YZDrawerViewController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    YZLeftViewController * leftVc = [YZLeftViewController new];
    YZCenterViewController * centerVc = [YZCenterViewController new];
    centerVc.view.backgroundColor = [UIColor redColor];
    UINavigationController * navi = [[UINavigationController alloc]initWithRootViewController:centerVc];
    YZRightViewController * rightVc = [YZRightViewController new];
    YZDrawerViewController * drawVc = [[YZDrawerViewController alloc]initWithLeftController:leftVc centerController:navi rightController:rightVc];
    [self presentViewController:drawVc animated:YES completion:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
