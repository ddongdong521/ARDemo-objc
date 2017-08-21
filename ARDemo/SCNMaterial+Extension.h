//
//  SCNMaterial+Extension.h
//  ARDemo
//
//  Created by apple on 2017/7/28.
//  Copyright © 2017年 Charly. All rights reserved.
//

#import <SceneKit/SceneKit.h>

@interface SCNMaterial (Extension)

+ (SCNMaterial *)materialWithDiffuse:(UIColor *)diffuse RespondsToLighting:(BOOL)responds;

@end
