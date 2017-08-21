//
//  CGPointTool.m
//  ARDemo
//
//  Created by apple on 2017/7/28.
//  Copyright © 2017年 Charly. All rights reserved.
//

#import "CGPointTool.h"

@implementation CGPointTool
+ (CGPoint)makePointWithCGSize:(CGSize)size{
    return CGPointMake(size.width, size.height);
}
+ (CGPoint)makePointWithSCNVector3:(SCNVector3)vector{
    return CGPointMake(vector.x, vector.y);
}
+ (CGFloat)distanceFromPoint_1:(CGPoint)point_1 ToPoint_2:(CGPoint)point_2{
    CGPoint point =CGPointMake(point_1.x-point_2.x, point_1.y-point_2.y);
    return [self lengthWithCGPoint:point];
}
+ (CGFloat)lengthWithCGPoint:(CGPoint)point{
    return  sqrt(point.x*point.x+point.y*point.y);
}
+ (CGPoint)midPointFromPoint_1:(CGPoint)point_1 ToPoint_2:(CGPoint)point_2{
    return CGPointMake((point_1.x+point_2.x)/2, (point_1.y+point_2.y)/2);
}
+ (NSString *)firendlyStringWithCGPoint:(CGPoint)point{
    return [NSString stringWithFormat:@"x:%.2f,y:%.2f",point.x,point.y];
}
@end
