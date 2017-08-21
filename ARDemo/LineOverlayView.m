//
//  LineOverlayView.m
//  ARDemo
//
//  Created by apple on 2017/8/3.
//  Copyright © 2017年 Charly. All rights reserved.
//

#import "LineOverlayView.h"

@implementation LineOverlayView
- (NSMutableArray<Line *>*)lines{
    if (!_lines) {
        _lines = [NSMutableArray array];
    }
    return _lines;
}

- (void)addLineWithStart:(CGPoint)start End:(CGPoint)end{
    [self.lines addObject:[Line lineWithStart:start End:end]];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    for (Line *line in self.lines) {
        UIBezierPath *path =  [[UIBezierPath alloc]init];
        [path moveToPoint:line.start];
        [path addLineToPoint:line.end];
        [path closePath];
        [[UIColor redColor] set];
        [path stroke];
        [path fill];
    }
    [self.lines removeAllObjects];
}

@end
