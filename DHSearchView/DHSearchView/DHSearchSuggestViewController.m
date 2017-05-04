//
//  DHSearchSuggestViewController.m
//  DHSearchView
//
//  Created by 张丁豪 on 2017/5/4.
//  Copyright © 2017年 zhangdinghao. All rights reserved.
//

#import "DHSearchSuggestViewController.h"

@interface DHSearchSuggestViewController ()

@end

@implementation DHSearchSuggestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    // 获取通知中心单例对象
    NSNotificationCenter * center = [NSNotificationCenter defaultCenter];
    // 添加当前类对象为一个观察者，name和object设置为nil，表示接收一切通知
    [center addObserver:self selector:@selector(handleColorChange:) name:@"searchBarDidChange" object:nil];
}

-(void)handleColorChange:(NSNotification* )sender
{
    NSString *text = sender.userInfo[@"searchText"];
    NSLog(@"%@", text);
    // 搜索
}

#pragma mark --
#pragma mark -- Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 50;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"这是搜索结果列表 %ld",(long)indexPath.row+1];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 取消选中
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.didSelectText([tableView cellForRowAtIndexPath:indexPath].textLabel.text);
    
    UIViewController *vc = [[UIViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    self.didSelectText(@"");
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
