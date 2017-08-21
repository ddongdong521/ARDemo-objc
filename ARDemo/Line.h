//
//  Line.h
//  ARDemo
//
//  Created by apple on 2017/8/4.
//  Copyright © 2017年 Charly. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Line : NSObject

@property (nonatomic,assign)CGPoint start;
@property (nonatomic,assign)CGPoint end;


+ (instancetype)lineWithStart:(CGPoint)start End:(CGPoint)end;

@end
