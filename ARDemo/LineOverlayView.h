//
//  LineOverlayView.h
//  ARDemo
//
//  Created by apple on 2017/8/3.
//  Copyright © 2017年 Charly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Line.h"

@interface LineOverlayView : UIView
@property (nonatomic, strong)NSMutableArray<Line *> *lines;

- (void)addLineWithStart:(CGPoint)start End:(CGPoint)end;


@end
