//
//  SCNMaterial+Extension.m
//  ARDemo
//
//  Created by apple on 2017/7/28.
//  Copyright © 2017年 Charly. All rights reserved.
//

#import "SCNMaterial+Extension.h"

@implementation SCNMaterial (Extension)
+ (SCNMaterial *)materialWithDiffuse:(UIColor *)diffuse RespondsToLighting:(BOOL)responds{
    SCNMaterial *materia = [[SCNMaterial alloc]init];
    materia.diffuse.contents = diffuse;
    materia.doubleSided = YES;
    if (responds) {
        materia.locksAmbientWithDiffuse = YES;
    }else{
        materia.ambient.contents = [UIColor blackColor];
        materia.lightingModelName = SCNLightingModelConstant;
        materia.emission.contents = diffuse;
    }
    return materia;
    
}
@end
