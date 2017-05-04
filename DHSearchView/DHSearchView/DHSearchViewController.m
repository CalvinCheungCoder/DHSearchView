//
//  DHSearchViewController.m
//  DHSearchView
//
//  Created by 张丁豪 on 2017/5/4.
//  Copyright © 2017年 zhangdinghao. All rights reserved.
//

#import "DHSearchViewController.h"
#import "UIColor+DHExtension.h"
#import "DHSearchSuggestViewController.h"
#import "UIView+Addition.h"

#define SEARCH_SEARCH_HISTORY_CACHE_PATH [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"Searchhistories.plist"] // 搜索历史存储路径

#define kScreenWidth ([[UIScreen mainScreen] bounds].size.width)
#define kScreenHeight ([[UIScreen mainScreen] bounds].size.height)

#define RandomColor self.colorPol[arc4random_uniform((uint32_t)self.colorPol.count)] // 随机选取颜色池中的颜色

@interface DHSearchViewController ()<UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *tagsView;
@property (nonatomic, strong) UIView *headerView;
// 搜索历史
@property (nonatomic, strong) NSMutableArray *searchHistories;
// 搜索历史缓存保存路径, 默认为PYSEARCH_SEARCH_HISTORY_CACHE_PATH(PYSearchConst.h文件中的宏定义)
@property (nonatomic, copy) NSString *searchHistoriesCachePath;
// 搜索历史记录缓存数量，默认为20
@property (nonatomic, assign) NSUInteger searchHistoriesCount;
// 搜索建议（推荐）控制器
@property (nonatomic, weak) DHSearchSuggestViewController *searchSuggestionVC;

@property (nonatomic, strong) NSMutableArray<UIColor *> *colorPol;

@end

@implementation DHSearchViewController

- (DHSearchSuggestViewController *)searchSuggestionVC
{
    if (!_searchSuggestionVC) {
        DHSearchSuggestViewController *searchSuggestionVC = [[DHSearchSuggestViewController alloc] initWithStyle:UITableViewStylePlain];
        __weak typeof(self) _weakSelf = self;
        searchSuggestionVC.didSelectText = ^(NSString *didSelectText) {
            
            if ([didSelectText isEqualToString:@""]) {
                [self.searchBar resignFirstResponder];
            }else{
                // 设置搜索信息
                _weakSelf.searchBar.text = didSelectText;
                // 缓存数据并且刷新界面
                [_weakSelf saveSearchCacheAndRefreshView];
            }
        };
        searchSuggestionVC.view.frame = CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height-64);
        searchSuggestionVC.view.backgroundColor = [UIColor whiteColor];
        
        [self.view addSubview:searchSuggestionVC.view];
        [self addChildViewController:searchSuggestionVC];
        _searchSuggestionVC = searchSuggestionVC;
    }
    return _searchSuggestionVC;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.searchHistoriesCount = 20;
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight) style:UITableViewStylePlain];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    // 创建搜索框
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(10, 0, kScreenWidth-20, 20)];
    searchBar.placeholder = @"搜索平台";
    searchBar.delegate = self;
    searchBar.backgroundColor = [UIColor clearColor];
    searchBar.showsCancelButton = YES;
    searchBar.tintColor = [UIColor blueColor];
    self.searchBar = searchBar;
    self.navigationItem.titleView = self.searchBar;
    
    // headView
    self.headerView = [[UIView alloc] init];
    self.headerView.sd_x = 0;
    self.headerView.sd_y = 0;
    self.headerView.sd_width = kScreenWidth;
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 20, kScreenWidth-20, 30)];
    titleLabel.text = @"热门推荐";
    titleLabel.font = [UIFont systemFontOfSize:13];
    titleLabel.textColor = [UIColor grayColor];
    [titleLabel sizeToFit];
    [self.headerView addSubview:titleLabel];
    
    self.tagsView = [[UIView alloc] init];
    self.tagsView.sd_x = 10;
    self.tagsView.sd_y = titleLabel.sd_y+30;
    self.tagsView.sd_width = kScreenWidth-20;
    [self.headerView addSubview:self.tagsView];
    self.tableView.tableHeaderView = self.headerView;
    
    
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 40)];
    UILabel *footLabel = [[UILabel alloc] initWithFrame:footView.frame];
    footLabel.textColor = [UIColor grayColor];
    footLabel.font = [UIFont systemFontOfSize:13];
    footLabel.userInteractionEnabled = YES;
    footLabel.text = @"清空搜索记录";
    footLabel.textAlignment = NSTextAlignmentCenter;
    [footLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(emptySearchHistoryDidClick)]];
    [footView addSubview:footLabel];
    self.tableView.tableFooterView = footView;
    
    [self tagsViewWithTag];
}


#pragma mark --
#pragma mark -- 设置标签
- (void)tagsViewWithTag
{
    CGFloat allLabelWidth = 0;
    CGFloat allLabelHeight = 0;
    int rowHeight = 0;
    for (int i = 0; i < self.tagsArray.count; i++) {
        if (i != self.tagsArray.count-1) {
            
            CGFloat width = [self getWidthWithTitle:self.tagsArray[i+1] font:[UIFont systemFontOfSize:14]];
            if (allLabelWidth + width+10 > self.tagsView.frame.size.width) {
                rowHeight++;
                allLabelWidth = 0;
                allLabelHeight = rowHeight*40;
            }
        }else{
            CGFloat width = [self getWidthWithTitle:self.tagsArray[self.tagsArray.count-1] font:[UIFont systemFontOfSize:14]];
            if (allLabelWidth + width+10 > self.tagsView.frame.size.width) {
                rowHeight++;
                allLabelWidth = 0;
                allLabelHeight = rowHeight*40;
            }
        }
        UILabel *rectangleTagLabel = [[UILabel alloc] init];
        // 设置属性
        rectangleTagLabel.userInteractionEnabled = YES;
        rectangleTagLabel.font = [UIFont systemFontOfSize:14];
        rectangleTagLabel.textColor = [UIColor whiteColor];
        rectangleTagLabel.backgroundColor = RandomColor;
        rectangleTagLabel.text = self.tagsArray[i];
        rectangleTagLabel.textAlignment = NSTextAlignmentCenter;
        [rectangleTagLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tagDidCLick:)]];
        CGFloat labelWidth = [self getWidthWithTitle:self.tagsArray[i] font:[UIFont systemFontOfSize:14]];
        rectangleTagLabel.layer.cornerRadius = 3;
        [rectangleTagLabel.layer setMasksToBounds:YES];
        if (labelWidth > kScreenWidth-20) {
            labelWidth = kScreenWidth-20;
        }
        rectangleTagLabel.frame = CGRectMake(allLabelWidth, allLabelHeight, labelWidth, 25);
        [self.tagsView addSubview:rectangleTagLabel];
        allLabelWidth = allLabelWidth+10+labelWidth;
    }
    self.tagsView.sd_height = rowHeight*40+40;
    self.headerView.sd_height = self.tagsView.sd_y+self.tagsView.sd_height+10;
}

- (NSMutableArray *)colorPol
{
    if (!_colorPol) {
        NSArray *colorStrPol = @[@"009999", @"0099cc", @"0099ff", @"00cc99", @"00cccc", @"336699", @"3366cc", @"3366ff", @"339966", @"666666", @"666699", @"6666cc", @"6666ff", @"996666", @"996699", @"999900", @"999933", @"99cc00", @"99cc33", @"660066", @"669933", @"990066", @"cc9900", @"cc6600" , @"cc3300", @"cc3366", @"cc6666", @"cc6699", @"cc0066", @"cc0033", @"ffcc00", @"ffcc33", @"ff9900", @"ff9933", @"ff6600", @"ff6633", @"ff6666", @"ff6699", @"ff3366", @"ff3333"];
        NSMutableArray *colorPolM = [NSMutableArray array];
        for (NSString *colorStr in colorStrPol) {
            UIColor *color = [UIColor dh_colorWithHexString:colorStr];
            [colorPolM addObject:color];
        }
        _colorPol = colorPolM;
    }
    return _colorPol;
}

#pragma mark --
#pragma mark -- 选中标签
- (void)tagDidCLick:(UITapGestureRecognizer *)gr
{
    UILabel *label = (UILabel *)gr.view;
    self.searchBar.text = label.text;
    // 缓存数据并且刷新界面
    [self saveSearchCacheAndRefreshView];
    self.tableView.tableFooterView.hidden = NO;
    self.searchSuggestionVC.view.hidden = NO;
    self.tableView.hidden = YES;
    [self.view bringSubviewToFront:self.searchSuggestionVC.view];
    
    //创建一个消息对象
    NSNotification *notice = [NSNotification notificationWithName:@"searchBarDidChange" object:nil userInfo:@{@"searchText":label.text}];
    //发送消息
    [[NSNotificationCenter defaultCenter]postNotification:notice];
}

#pragma mark --
#pragma mark -- 视图完全显示
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // 弹出键盘
    [self.searchBar becomeFirstResponder];
}

#pragma mark --
#pragma mark -- 视图即将消失
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    // 回收键盘
    [self.searchBar resignFirstResponder];
}

#pragma mark --
#pragma mark -- Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    self.tableView.tableFooterView.hidden = self.searchHistories.count == 0;
    return self.searchHistories.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    }
    // 添加关闭按钮
    UIButton *closetButton = [[UIButton alloc] init];
    // 设置图片容器大小、图片原图居中
    closetButton.frame = CGRectMake(0, 0, cell.sd_height, cell.sd_height);
    closetButton.tag = indexPath.row;
    [closetButton setTitle:@"x" forState:UIControlStateNormal];
    [closetButton addTarget:self action:@selector(closeDidClick:) forControlEvents:UIControlEventTouchUpInside];
    cell.accessoryView = closetButton;
    [closetButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    
    cell.textLabel.textColor = [UIColor grayColor];
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    cell.textLabel.text = self.searchHistories[indexPath.row];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (self.searchHistories.count != 0) {
        return @"搜索历史";
    }
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(10, 0, kScreenWidth-10, 60)];
    view.backgroundColor = [UIColor whiteColor];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:view.frame];
    titleLabel.text = @"搜索历史";
    titleLabel.font = [UIFont systemFontOfSize:14];
    [titleLabel sizeToFit];
    [view addSubview:titleLabel];
    
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 取出选中的cell
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.searchBar.text = cell.textLabel.text;
    // 缓存数据并且刷新界面
    [self saveSearchCacheAndRefreshView];
    [self searchBarSearchButtonClicked:self.searchBar];
    self.searchSuggestionVC.view.hidden = NO;
    self.tableView.hidden = YES;
    [self.view bringSubviewToFront:self.searchSuggestionVC.view];
    //创建一个消息对象
    NSNotification * notice = [NSNotification notificationWithName:@"searchBarDidChange" object:nil userInfo:@{@"searchText":cell.textLabel.text}];
    //发送消息
    [[NSNotificationCenter defaultCenter]postNotification:notice];
}

- (CGFloat)getWidthWithTitle:(NSString *)title font:(UIFont *)font {
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 1000, 0)];
    label.text = title;
    label.font = font;
    [label sizeToFit];
    return label.frame.size.width+10;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // 滚动时，回收键盘
    [self.searchBar resignFirstResponder];
}

- (NSMutableArray *)searchHistories
{
    
    if (!_searchHistories) {
        self.searchHistoriesCachePath = SEARCH_SEARCH_HISTORY_CACHE_PATH;
        _searchHistories = [NSMutableArray arrayWithArray:[NSKeyedUnarchiver unarchiveObjectWithFile:self.searchHistoriesCachePath]];
    }
    return _searchHistories;
}

- (void)setSearchHistoriesCachePath:(NSString *)searchHistoriesCachePath
{
    _searchHistoriesCachePath = [searchHistoriesCachePath copy];
    // 刷新
    self.searchHistories = nil;
    [self.tableView reloadData];
}

#pragma mark --
#pragma mark -- 进入搜索状态调用此方法
- (void)saveSearchCacheAndRefreshView
{
    UISearchBar *searchBar = self.searchBar;
    // 回收键盘
    [searchBar resignFirstResponder];
    // 先移除再刷新
    [self.searchHistories removeObject:searchBar.text];
    [self.searchHistories insertObject:searchBar.text atIndex:0];
    
    // 移除多余的缓存
    if (self.searchHistories.count > self.searchHistoriesCount) {
        // 移除最后一条缓存
        [self.searchHistories removeLastObject];
    }
    // 保存搜索信息
    [NSKeyedArchiver archiveRootObject:self.searchHistories toFile:self.searchHistoriesCachePath];
    [self.tableView reloadData];
}

- (void)closeDidClick:(UIButton *)sender
{
    // 获取当前cell
    UITableViewCell *cell = (UITableViewCell *)sender.superview;
    // 移除搜索信息
    [self.searchHistories removeObject:cell.textLabel.text];
    // 保存搜索信息
    [NSKeyedArchiver archiveRootObject:self.searchHistories toFile:SEARCH_SEARCH_HISTORY_CACHE_PATH];
    if (self.searchHistories.count == 0) {
        self.tableView.tableFooterView.hidden = YES;
    }
    // 刷新
    [self.tableView reloadData];
}

#pragma mark --
#pragma mark -- 点击清空历史按钮
- (void)emptySearchHistoryDidClick
{
    self.tableView.tableFooterView.hidden = YES;
    // 移除所有历史搜索
    [self.searchHistories removeAllObjects];
    // 移除数据缓存
    [NSKeyedArchiver archiveRootObject:self.searchHistories toFile:self.searchHistoriesCachePath];
    [self.tableView reloadData];
}

#pragma mark --
#pragma mark -- UISearchBarDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    // 缓存数据并且刷新界面
    [self saveSearchCacheAndRefreshView];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if ([searchText isEqualToString:@""]) {
        self.searchSuggestionVC.view.hidden = YES;
        self.tableView.hidden = NO;
    }else{
        self.searchSuggestionVC.view.hidden = NO;
        self.tableView.hidden = YES;
        [self.view bringSubviewToFront:self.searchSuggestionVC.view];
        
        //创建一个消息对象
        NSNotification * notice = [NSNotification notificationWithName:@"searchBarDidChange" object:nil userInfo:@{@"searchText":searchText}];
        //发送消息
        [[NSNotificationCenter defaultCenter]postNotification:notice];
    }
}


@end
