//
//  SCNNode+Extension.h
//  ARDemo
//
//  Created by apple on 2017/7/26.
//  Copyright © 2017年 Charly. All rights reserved.
//

#import <SceneKit/SceneKit.h>

@interface SCNNode (Extension)
- (BOOL)reactsToScale;

/**
 设置统一大小
 
 @param scale 大小
 */
- (void)setUniformScale:(CGFloat)scale;

/**
 呈现在上方
 */
- (void)renderOnTop;
@end
