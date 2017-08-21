//
//  VirtualObject.h
//  ARDemo
//
//  Created by apple on 2017/7/18.
//  Copyright © 2017年 Charly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SceneKit/SceneKit.h>
#import <ARKit/ARKit.h>
#import "ARViewController.h"
@protocol ReactsToScale <NSObject>
-(void)reactToScale;
@end

@interface VirtualObject : SCNNode
@property (nonatomic,strong) NSString *modelName;
@property (nonatomic,strong) NSString *fileExtension;
@property (nonatomic,strong) UIImage *thumbImage;
@property (nonatomic,strong) NSString *title;
@property (nonatomic) BOOL modelLoaded;
@property (nonatomic,strong)ARViewController  *viewController;


-(instancetype)initWithModelName:(NSString *)modelName FileExtension:(NSString *)fileExtension ThumbImageFilename:(NSString *)thumbImageFileName Title:(NSString *)title;

- (void)translateBasedOnScreenPos:(CGPoint)pos Instantly:(BOOL)instantly InfinitePlane:(BOOL)infinitePlane;
/**
 判断是否是VirtualObject的子节点
 
 @return YESorNo
 */
+ (BOOL)isNodePartOfVirtualObject:(SCNNode *)node;
+ (NSArray<VirtualObject *> *)getObjects;
- (void)loadModel;
- (void)unloadModel;
@end
