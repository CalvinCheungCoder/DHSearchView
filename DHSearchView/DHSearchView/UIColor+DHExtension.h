//
//  UIColor+DHExtension.h
//  DHSearchView
//
//  Created by 张丁豪 on 2017/5/4.
//  Copyright © 2017年 zhangdinghao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (DHExtension)

/** 根据16进制字符串返回对应颜色 */
+ (instancetype)dh_colorWithHexString:(NSString *)hexString;

/** 根据16进制字符串返回对应颜色 带透明参数 */
+ (instancetype)dh_colorWithHexString:(NSString *)hexString alpha:(CGFloat)alpha;

@end
