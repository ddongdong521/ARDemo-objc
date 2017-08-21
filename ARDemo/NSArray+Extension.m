//
//  NSArray+Extension.m
//  ARDemo
//
//  Created by apple on 2017/7/26.
//  Copyright © 2017年 Charly. All rights reserved.
//

#import "NSArray+Extension.h"
#import <SceneKit/SceneKit.h>
#import <ARKit/ARKit.h>

@implementation NSArray (Extension)

+ (CGFloat)getAverageFromCGFloatArray:(NSArray *)array{
    if (array.count==0) {
        return 0;
    }
    CGFloat total = 0;
    for (int i = 0; i<array.count; i++) {
        total += [array[i] doubleValue];
    }
    return total/array.count;
}

+ (SCNVector3)getAverageFromSCNVector3Array:(NSArray *)array{
    if (array.count==0) {
        return SCNVector3Make(0, 0, 0);
    }
    SCNVector3 total = SCNVector3Make(0, 0, 0);
    for (int i = 0; i<array.count; i++) {
        SCNVector3 temp = [array[i] SCNVector3Value];
        total.x += temp.x;
        total.y += temp.y;
        total.z += temp.z;
    }
    return SCNVector3Make(total.x/array.count, total.y/array.count, total.z/array.count);
}

- (void)keepLastWithElements:(NSInteger)elementsToKeep{
    
}
@end
