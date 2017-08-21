//
//  CGSizeTool.m
//  ARDemo
//
//  Created by apple on 2017/7/28.
//  Copyright © 2017年 Charly. All rights reserved.
//

#import "CGSizeTool.h"

@implementation CGSizeTool
+ (CGSize)makeSizeWithPoint:(CGPoint)point{
    
    return CGSizeMake(point.x, point.y);
}

+ (NSString *)friendlyStringWithSize:(CGSize)size{
    
    return [NSString stringWithFormat:@"width:%.2f,height:%.2f",size.width,size.height];
}
@end
