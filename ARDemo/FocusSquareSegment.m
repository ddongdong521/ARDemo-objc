//
//  FocusSquareSegment.m
//  ARDemo
//
//  Created by apple on 2017/8/1.
//  Copyright © 2017年 Charly. All rights reserved.
//

#import "FocusSquareSegment.h"
#import "SCNMaterial+Extension.h"
#import "SCNVector3Tool.h"

@implementation FocusSquareSegment
- (instancetype)initWithName:(NSString *)name Width:(CGFloat)width Thickness:(CGFloat)thickness Color:(UIColor *)color Vertical:(BOOL)vertical{
    if (self = [super init]) {
        SCNMaterial *material = [SCNMaterial materialWithDiffuse:color RespondsToLighting:false];
        SCNPlane *plane;
        if (vertical) {
            plane = [SCNPlane planeWithWidth:thickness height:width];
        }else{
            plane = [SCNPlane planeWithWidth:width height:thickness];
        }
        plane.materials = @[material];
        self.geometry = plane;
        self.name = name;
    }
    return self;
}
- (void)openWithDirection:(Direction)direction newLength:(CGFloat)length{
    if (![self.geometry isKindOfClass:[SCNPlane class]]) {
        return;
    }    
    SCNPlane *p = (SCNPlane *)self.geometry;
    if (direction == left||direction == right) {
        p.width = length;
    }else{
        p.height = length;
    }
    SCNVector3 position = self.position;
    switch (direction) {
         case left:
            position.x -= 0.5 / 2 - p.width / 2;
            break;
         case right:
            position.x += 0.5 / 2 - p.width / 2;
            break;
         case up:
            position.y -= 0.5 / 2 - p.height / 2;
            break;
         case down:
            position.y += 0.5 / 2 - p.height / 2;
            break;
        default:
            break;
    }
    self.position = position;
    NSLog(@"open------name:%@---%@",self.name,[SCNVector3Tool friendlyStringWithSCNVector3:self.position]);
}

- (void)closeWithDirection:(Direction)direction{
    if (![self.geometry isKindOfClass:[SCNPlane class]]) {
        return;
    }
    SCNPlane *p = (SCNPlane *)self.geometry;
    CGFloat oldLength ;
    if (direction == left|| direction == right) {
        oldLength = p.width;
        p.width = 0.5;
    }else{
        oldLength = p.height;
        p.height = 0.5;
    }
    SCNVector3 position = self.position;
    switch (direction) {
        case left:
            position.x -= 0.5 / 2 - oldLength / 2;
            break;
        case right:
            position.x += 0.5 / 2 - oldLength / 2;
            break;
        case up:
            position.y -= 0.5 / 2 - oldLength / 2;
            break;
        case down:
            position.y += 0.5 / 2 - oldLength / 2;
            break;
        default:
            break;
    }
    self.position = position;
    
    NSLog(@"close----name:%@,%@",self.name,[SCNVector3Tool friendlyStringWithSCNVector3:self.position]);
    
}
@end
