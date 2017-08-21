//
//  CGSizeTool.h
//  ARDemo
//
//  Created by apple on 2017/7/28.
//  Copyright © 2017年 Charly. All rights reserved.
//
#import <UIKit/UIKit.h>

@interface CGSizeTool : NSObject

/**
 使用point初始化size
 
 @param point point
 @return size
 */
+ (CGSize)makeSizeWithPoint:(CGPoint)point;


/**
 返回描述宽高的字符串
 
 @param size size
 @return string
 */
+ (NSString *)friendlyStringWithSize:(CGSize)size;
@end
