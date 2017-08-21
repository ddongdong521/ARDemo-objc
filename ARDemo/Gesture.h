//
//  Gesture.h
//  ARDemo
//
//  Created by apple on 2017/8/1.
//  Copyright © 2017年 Charly. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ARKit/ARKit.h>
#import "VirtualObject.h"
@interface Gesture : NSObject

enum TouchEventType {
    TouchEventTypeTouchBegan,
    TouchEventTypeTouchMoved,
    TouchEventTypeTouchEnded,
    TouchEventTypeTouchCancelled,
};

typedef enum TouchEventType TouchEventType;

@property (nonatomic,strong)NSMutableSet<UITouch *>*currentTouches;
@property (nonatomic,strong)ARSCNView *sceneView;
@property (nonatomic,strong)VirtualObject *virtualObject;
@property (nonatomic,strong)NSTimer *refreshTimer;

- (instancetype)initWithTouches:(NSSet<UITouch *> *)touches SceneView:(ARSCNView *)sceneView VirtualObject:(VirtualObject *)virtualObject;
+ (Gesture *)startGestureFromTouches:(NSSet<UITouch *> *)touches SceneView:(ARSCNView *)sceneView VirtualObject:(VirtualObject *)virtualObject;
- (void)refreshCurrentGesture;
- (Gesture *)updateGestureFromTouches:(NSSet<UITouch *> *)touches Type:(TouchEventType)type;
- (void)updateGesture;
@end
