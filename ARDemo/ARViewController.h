//
//  ViewController.h
//  ARDemo
//
//  Created by apple on 2017/7/18.
//  Copyright © 2017年 Charly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SceneKit/SceneKit.h>
#import <ARKit/ARKit.h>
#import "PositionModel.h"


@interface  ARViewController: UIViewController
@property (weak, nonatomic) IBOutlet UIVisualEffectView *messagePanel;
@property (weak, nonatomic) IBOutlet UILabel *debugMessageLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

@property (nonatomic,strong) IBOutlet UILabel *featurePointCountLabel;
@property (nonatomic,assign)BOOL showDebugVisuals;
@property (nonatomic,strong)NSMutableDictionary *planes;

- (IBAction)restartExperience:(id)sender;

- (PositionModel *)worldPositionFromScreenPosition:(CGPoint)position ObjectPostion:(SCNVector3)objectPosition InfinitePlane:(BOOL)infinitePlane;

- (void)moveVirtualObjectToPosition:(SCNVector3)position Instantly:(BOOL)instantly FilterPosition:(BOOL)filterPosition;
@end


