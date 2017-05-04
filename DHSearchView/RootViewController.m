//
//  RootViewController.m
//  DHSearchView
//
//  Created by 张丁豪 on 2017/5/4.
//  Copyright © 2017年 zhangdinghao. All rights reserved.
//

#import "RootViewController.h"
#import "DHSearchViewController.h"

@interface RootViewController ()

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Touch View To Search";
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    DHSearchViewController *search = [[DHSearchViewController alloc]init];
    search.tagsArray = @[@"好利网",@"小微金融",@"发薪贷",@"陆金所",@"人人利",@"去哪贷",@"好利网",@"黄金所"];
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:search];
    [self presentViewController:nav animated:YES completion:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
