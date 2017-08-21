//
//  SceneKitTool.m
//  ARDemo
//
//  Created by apple on 2017/7/28.
//  Copyright © 2017年 Charly. All rights reserved.
//

#import "SceneKitTool.h"
#import "SCNVector3Tool.h"

@implementation SceneKitTool
+ (SCNVector3)rayIntersectionWithHorizontalPlane:(SCNVector3)rayOrigin Direction:(SCNVector3)direction PlaneY:(CGFloat)planeY{
    SCNVector3 direction1 = [SCNVector3Tool normalizedWithSCNVector3:direction];
    //特殊情况处理:检查光线是否水平方向
    if (direction1.y==0){
        if (rayOrigin.y == planeY) {
     // 射线是水平的，在平面上，因此射线的所有点都与平面相交
            //因此我们简单地返回原点
            return rayOrigin;
        }else{
            //这条射线平行于平面，永不相交
            return SCNVector3Zero;
        }
    }
    /**从射线的原点到平面上的交点处的距离:
     (平面的点-原点)/普通平面的点
     
     因为我们知道水平平面是正常的(0,1,0)，我们可以化简成：
     
    **/
    CGFloat dist = (planeY - rayOrigin.y)/direction1.y;
    //不返回原点之后与射线的交点
    if (dist < 0 ) {
        return SCNVector3Zero;
    }
    return SCNVector3Make(rayOrigin.x + direction1.x * dist, rayOrigin.y + direction1.y * dist, rayOrigin.z + direction1.z * dist);
}
@end
