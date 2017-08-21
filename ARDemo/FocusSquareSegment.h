//
//  FocusSquareSegment.h
//  ARDemo
//
//  Created by apple on 2017/8/1.
//  Copyright © 2017年 Charly. All rights reserved.
//

#import <SceneKit/SceneKit.h>

@interface FocusSquareSegment : SCNNode

enum Direction{
    up,
    down,
    left,
    right
};
typedef enum Direction Direction;

- (instancetype)initWithName:(NSString *)name Width:(CGFloat)width Thickness:(CGFloat)thickness Color:(UIColor *)color Vertical:(BOOL)vertical;

- (void)openWithDirection:(Direction)direction newLength:(CGFloat)length;

- (void)closeWithDirection:(Direction)direction;

@end
