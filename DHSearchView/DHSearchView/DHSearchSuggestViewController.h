//
//  DHSearchSuggestViewController.h
//  DHSearchView
//
//  Created by 张丁豪 on 2017/5/4.
//  Copyright © 2017年 zhangdinghao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DHSearchSuggestViewController : UITableViewController

/** 选中cell时调用此Block  */
@property (nonatomic, copy) void(^didSelectText)(NSString *selectedText);

@end
