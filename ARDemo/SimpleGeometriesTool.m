//
//  SimpleGeometriesTool.m
//  ARDemo
//
//  Created by apple on 2017/7/31.
//  Copyright © 2017年 Charly. All rights reserved.
//

#import "SimpleGeometriesTool.h"
#import "SCNMaterial+Extension.h"

@implementation SimpleGeometriesTool
+ (SCNNode *)createAxesNodeWithQuiverLength:(CGFloat)quiverLength QuiverThickness:(CGFloat)quiverThickness{
    
     quiverThickness = (quiverLength / 50.0) * quiverThickness;
    CGFloat chamferRadius = quiverThickness / 2.0;
    SCNBox *xQuiverBox = [SCNBox boxWithWidth:quiverLength height:quiverThickness length:quiverThickness chamferRadius:chamferRadius];
    xQuiverBox.materials = @[[SCNMaterial materialWithDiffuse:[UIColor redColor] RespondsToLighting:NO]];
    
    SCNNode *xQuiverNode = [SCNNode nodeWithGeometry:xQuiverBox];
    xQuiverNode.position =  SCNVector3Make(quiverLength / 2.0, 0.0, 0.0);
    SCNBox *yQuiverBox = [SCNBox boxWithWidth:quiverThickness height:quiverThickness length:quiverLength chamferRadius:chamferRadius];
    yQuiverBox.materials = @[[SCNMaterial materialWithDiffuse:[UIColor greenColor] RespondsToLighting:NO]];
    SCNNode *yQuiverNode = [SCNNode nodeWithGeometry:yQuiverBox];
    yQuiverNode.position = SCNVector3Make(0.0, quiverLength / 2.0, 0.0);
    
    SCNBox *zQuiverBox = [SCNBox boxWithWidth:quiverThickness height:quiverThickness length:quiverLength chamferRadius:chamferRadius];
    zQuiverBox.materials = @[[SCNMaterial materialWithDiffuse:[UIColor blueColor] RespondsToLighting:NO]];
    SCNNode *zQuiverNode = [SCNNode nodeWithGeometry:zQuiverBox];
    zQuiverNode.position = SCNVector3Make(0.0, 0.0, quiverLength / 2.0);
    SCNNode *quiverNode = [[SCNNode alloc]init];
    [quiverNode addChildNode:xQuiverNode];
    [quiverNode addChildNode:yQuiverNode];
    [quiverNode addChildNode:zQuiverNode];
    return  quiverNode;
    
}

+ (SCNNode *)createCrossNodeWithSize:(CGFloat)size Color:(UIColor *)color Horizontal:(BOOL)horizontal Opacity:(CGFloat)opacity{
    CGFloat planeDimension = size;
    NSString *fileName = @"";
    if (color == [UIColor blueColor]) {
        fileName = @"crosshair_blue";
    }else if (color == [UIColor yellowColor]){
        fileName = @"crosshair_yellow";
    }else{
        fileName = @"crosshair_yellow";
    }
    NSString *path = [[NSBundle mainBundle]pathForResource:@"fileName" ofType:@"png" inDirectory:@"Models.scnassets"];
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    SCNNode *planeNode = [SCNNode nodeWithGeometry:[self createSquarePlaneWithSize:planeDimension Contents:image]];
    planeNode.geometry.firstMaterial.ambient.contents = [UIColor blackColor];
    planeNode.geometry.firstMaterial.lightingModelName = SCNLightingModelConstant;
    if (horizontal) {
        planeNode.eulerAngles = SCNVector3Make(M_PI_2, 0, M_PI);
    }else{
        planeNode.constraints = @[[[SCNBillboardConstraint alloc]init]];
    }
    SCNNode *cross = [SCNNode node];
    [cross addChildNode:planeNode];
    cross.opacity = opacity;
    return cross;
}

+ (SCNPlane *)createSquarePlaneWithSize:(CGFloat)size Contents:(id)contents{
    SCNPlane *plane = [SCNPlane planeWithWidth:size height:size];
    plane.materials = @[[SCNMaterial materialWithDiffuse:contents RespondsToLighting:YES]];
    return plane;
}
+ (SCNPlane *)createPlaneWithSize:(CGSize)size Contents:(id)contents{
    SCNPlane *plane = [SCNPlane planeWithWidth:size.width height:size.height];
    plane.materials = @[[SCNMaterial materialWithDiffuse:contents RespondsToLighting:YES]];
    return plane;}
@end
