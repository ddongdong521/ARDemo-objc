//
//  Line.m
//  ARDemo
//
//  Created by apple on 2017/8/4.
//  Copyright © 2017年 Charly. All rights reserved.
//

#import "Line.h"

@implementation Line

+ (instancetype)lineWithStart:(CGPoint)start End:(CGPoint)end{
    Line *line = [[self alloc]init];
    line.start = start;
    line.end = end;
    return line;
}
@end
