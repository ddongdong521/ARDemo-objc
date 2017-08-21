//
//  UIImage+Extension.h
//  ARDemo
//
//  Created by apple on 2017/7/26.
//  Copyright © 2017年 Charly. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Extension)

/**
 翻转图片
 
 @return 翻转后的图片
 */
- (UIImage *)inverted;
+ (UIImage *)composeButtonImageWithThumbImage:(UIImage *)thumbImage Alpha:(CGFloat)alpha;
@end
