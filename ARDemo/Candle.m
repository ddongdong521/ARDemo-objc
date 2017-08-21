//
//  Candle.m
//  ARDemo
//
//  Created by apple on 2017/7/21.
//  Copyright © 2017年 Charly. All rights reserved.
//

#import "Candle.h"

@implementation Candle


- (instancetype)init{
   return  [super initWithModelName:@"candle" FileExtension:@"scn" ThumbImageFilename:@"candle" Title:@"Candle"];
}

- (void)reactToScale{
    SCNNode *flameNode = [self childNodeWithName:@"flame" recursively:YES];
    //颗粒大小
    CGFloat particleSize = 0.018;
    [flameNode.particleSystems.firstObject reset];
    flameNode.particleSystems.firstObject.particleSize = particleSize;
}
@end
