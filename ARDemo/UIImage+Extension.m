//
//  UIImage+Extension.m
//  ARDemo
//
//  Created by apple on 2017/7/26.
//  Copyright © 2017年 Charly. All rights reserved.
//

#import "UIImage+Extension.h"

@implementation UIImage (Extension)

- (UIImage *)inverted{
    CIImage *image = [[CIImage alloc]initWithImage:self];
    if (!image) {
        return nil;
    }
    image = [image imageByApplyingFilter:@"CIColorInvert" withInputParameters:nil];
    return [UIImage imageWithCIImage:image];
}
+ (UIImage *)composeButtonImageWithThumbImage:(UIImage *)thumbImage Alpha:(CGFloat)alpha{
    UIImage *maskImage = [UIImage imageNamed:@"buttonring"];
    UIImage *thumbnailImage = thumbImage;
    UIImage *invertedImage = [thumbImage inverted];
    if (invertedImage) {
        thumbnailImage = invertedImage;
    }
    UIGraphicsBeginImageContextWithOptions(maskImage.size, NO, 0.0);
    CGRect maskDrawRect = {CGPointZero,maskImage.size};
    CGRect thumbDrawRect = {CGPointMake((maskImage.size.width-thumbImage.size.width)/2, (maskImage.size.height-thumbImage.size.height)/2),thumbImage.size};
    [maskImage drawInRect:maskDrawRect blendMode:kCGBlendModeNormal alpha:alpha];
    [thumbnailImage drawInRect:thumbDrawRect blendMode:kCGBlendModeNormal alpha:alpha];
    UIImage *composedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return composedImage;
}

@end
