//
//  SCNVector3Tool.m
//  ARDemo
//
//  Created by apple on 2017/7/21.
//  Copyright © 2017年 Charly. All rights reserved.
//

#import "SCNVector3Tool.h"

@implementation SCNVector3Tool
+ (SCNVector3)makeSCNVector3With:(vector_float3)vec{
    SCNVector3 scve = SCNVector3Make(vec.x, vec.y, vec.z);
    return scve;
}

+ (CGFloat)lengthWith:(SCNVector3)scve{
    return sqrt(scve.x*scve.x+scve.y*scve.y+scve.z*scve.z);
}

+ (SCNVector3)setLengthWith:(SCNVector3)scve Length:(CGFloat)length{
    scve = [self normalizeWithSCNVector3:scve];
    scve = SCNVector3Make(scve.x*length, scve.y*length, scve.z*length);
    return scve;
}
+ (SCNVector3)setMaximumLength:(SCNVector3)scve Length:(CGFloat)maxLength{
    if ([self lengthWith:scve]<=maxLength) {
        return scve;
    }else{
      scve = [self setLengthWith:scve Length:maxLength];
    }
    return scve;
}

+ (SCNVector3)normalizeWithSCNVector3:(SCNVector3)scve{
    return [self normalizedWithSCNVector3:scve];
}

+ (SCNVector3)normalizedWithSCNVector3:(SCNVector3)scve{
    CGFloat length = [self lengthWith:scve];
    if (length == 0) {
        return  scve;
    }
    return SCNVector3Make(scve.x/length, scve.y/length, scve.z/length);
}

+ (SCNVector3 )positionFromTransform:(matrix_float4x4)transform{
    return SCNVector3Make(transform.columns[3].x, transform.columns[3].y, transform.columns[3].z);
}

+ (NSString *)friendlyStringWithSCNVector3:(SCNVector3)scve{
    return [NSString stringWithFormat:@"x:%.2f,y:%.2f,z:%.2f",scve.x,scve.y,scve.z];
}

+ (CGFloat)dotWithSCNVector3:(SCNVector3)scve1 SCNVector3_2:(SCNVector3)scve2{
    return (scve1.x * scve2.x + scve1.y * scve2.y + scve1.z * scve2.z);
}

+ (SCNVector3 )crossWithSCNVector3_1:(SCNVector3)scve1 SCNVector3_2:(SCNVector3)scve2{
    return SCNVector3Make(scve1.y * scve2.z - scve1.z * scve2.y, scve1.x * scve2.z - scve1.z * scve2.x, scve1.x * scve2.y - scve1.y * scve2.x);
}
+ (SCNVector3)makeSCNVector3One{
    return SCNVector3Make(1.0, 1.0, 1.0);
}
+ (SCNVector3)makeSCNVector3UniformValue:(CGFloat)value{
    return SCNVector3Make(value, value, value);
}
@end
