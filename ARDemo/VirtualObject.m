//
//  VirtualObject.m
//  ARDemo
//
//  Created by apple on 2017/7/18.
//  Copyright © 2017年 Charly. All rights reserved.
//

#import "VirtualObject.h"
#import "PositionModel.h"
#import "Candle.h"
#import "Cup.h"
#import "Chair.h"
#import "Lamp.h"
#import "Vase.h"

@implementation VirtualObject

-(instancetype)init{
    if (self = [super init]) {
        self.name = @"Virtual object root node";
    }
    return self;
}

-(instancetype)initWithModelName:(NSString *)modelName FileExtension:(NSString *)fileExtension ThumbImageFilename:(NSString *)thumbImageFileName Title:(NSString *)title{
    if (self = [super init]) {
        self.name = @"Virtual object root node";
        self.modelName = modelName;
        self.fileExtension = fileExtension;
        self.thumbImage = [UIImage imageNamed:thumbImageFileName];
        self.title =title;
    }
    return self;
}

+ (NSArray *)getObjects{
    Candle *candle = [[Candle alloc]init];
    Cup *cup = [[Cup alloc]init];
    Vase *vase = [[Vase alloc]init];
    Lamp *lamp = [[Lamp alloc]init];
    Chair *chair = [[Chair alloc]init];
    return @[candle,
             cup,
             vase,
             lamp,
             chair];
}

/**
 加载模型
 */
- (void)loadModel{
    NSString *scneName = [NSString stringWithFormat:@"%@.%@",self.modelName,self.fileExtension];
    NSString *dire = [NSString stringWithFormat:@"Models.scnassets/%@",self.modelName];
    SCNScene *virtualObjectScene = [SCNScene sceneNamed:scneName inDirectory:dire options:nil];
    SCNNode *wrapperNode = [[SCNNode alloc]init];
    for (SCNNode *child in virtualObjectScene.rootNode.childNodes) {
        child.geometry.firstMaterial.lightingModelName = SCNLightingModelPhysicallyBased;
        child.movabilityHint = SCNMovabilityHintMovable;
        [wrapperNode addChildNode:child];
    }
    self.modelLoaded = YES;
}

/**
 卸载模型
 */
- (void)unloadModel{
    for (SCNNode *child in self.childNodes) {
        [child removeFromParentNode];
    }
    self.modelLoaded = NO;
}
- (void)translateBasedOnScreenPos:(CGPoint)pos Instantly:(BOOL)instantly InfinitePlane:(BOOL)infinitePlane{
    if (!self.viewController) {
        return;
    }
    PositionModel *result = [self.viewController worldPositionFromScreenPosition:pos ObjectPostion:self.position InfinitePlane:infinitePlane];
    [self.viewController moveVirtualObjectToPosition:result.position Instantly:instantly FilterPosition:!result.hitAPlane];
}

+ (BOOL)isNodePartOfVirtualObject:(SCNNode *)node{
 {
        if ([node.name isEqualToString:@"Virtual object root node"]){
            return YES;
        }
        if (node.parentNode !=nil){
            return  [self isNodePartOfVirtualObject:node.parentNode];
        }
     return NO;
    }
}


@end
