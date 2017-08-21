//
//  FocusSquare.m
//  ARDemo
//
//  Created by apple on 2017/7/31.
//  Copyright © 2017年 Charly. All rights reserved.
//

#import "FocusSquare.h"
#import "NSMutableArray+Extension.h"
#import "SCNMaterial+Extension.h"
#import "SCNNode+Extension.h"
#import "SCNVector3Tool.h"
#import "FocusSquareSegment.h"
@interface FocusSquare()
@property (nonatomic,assign)CGFloat focusSquareSize;
@property (nonatomic,assign)CGFloat focusSquareThickness;
@property (nonatomic,assign)CGFloat scaleForClosedSquare;
@property (nonatomic,assign)CGFloat sideLengthForOpenSquareSegments;
@property (nonatomic,assign)CGFloat animationDuration;
@property (nonatomic,strong)UIColor *focusSquareColor;
@property (nonatomic,assign)UIColor *focusSquareColorLight;
@property (nonatomic,assign)SCNVector3 lastPositionOnPlane;

@property (nonatomic,strong)NSMutableArray *recentFocusSquarePositions;
@property (nonatomic,strong)NSMutableSet<ARAnchor *> *anchorsOfVisitedPlanes;
@property (nonatomic,assign)BOOL isOpen;
@property (nonatomic,assign)BOOL isAnimating;

@property (nonatomic,strong)SCNNode *entireSquare;
@property (nonatomic,strong)SCNNode *fillPlane;
@property (nonatomic,strong)NSMutableArray <FocusSquareSegment *>* segments;
@end
@implementation FocusSquare

- (SCNNode *)entireSquare{
    return self.childNodes.firstObject;
}

- (NSMutableArray<FocusSquareSegment *>*)segments{
    if (!_segments) {
        _segments = [NSMutableArray array];
        if ([[self childNodeWithName:@"s1" recursively:YES] isKindOfClass:[FocusSquareSegment class]]&&
            [[self childNodeWithName:@"s2" recursively:YES] isKindOfClass:[FocusSquareSegment class]]&&
            [[self childNodeWithName:@"s3" recursively:YES] isKindOfClass:[FocusSquareSegment class]]&&
            [[self childNodeWithName:@"s4" recursively:YES] isKindOfClass:[FocusSquareSegment class]]&&
            [[self childNodeWithName:@"s5" recursively:YES] isKindOfClass:[FocusSquareSegment class]]&&
            [[self childNodeWithName:@"s6" recursively:YES] isKindOfClass:[FocusSquareSegment class]]&&
            [[self childNodeWithName:@"s7" recursively:YES] isKindOfClass:[FocusSquareSegment class]]&&
            [[self childNodeWithName:@"s8" recursively:YES] isKindOfClass:[FocusSquareSegment class]]) {
            FocusSquareSegment *s1 = (FocusSquareSegment *)[self childNodeWithName:@"s1" recursively:YES];
            FocusSquareSegment *s2 = (FocusSquareSegment *)[self childNodeWithName:@"s2" recursively:YES];
            FocusSquareSegment *s3 = (FocusSquareSegment *)[self childNodeWithName:@"s3" recursively:YES];
            FocusSquareSegment *s4 = (FocusSquareSegment *)[self childNodeWithName:@"s4" recursively:YES];
            FocusSquareSegment *s5 = (FocusSquareSegment *)[self childNodeWithName:@"s5" recursively:YES];
            FocusSquareSegment *s6 = (FocusSquareSegment *)[self childNodeWithName:@"s6" recursively:YES];
            FocusSquareSegment *s7 = (FocusSquareSegment *)[self childNodeWithName:@"s5" recursively:YES];
            FocusSquareSegment *s8 = (FocusSquareSegment *)[self childNodeWithName:@"s6" recursively:YES];
            [_segments addObjectsFromArray:@[s1,s2,s3,s4,s5,s6,s7,s8]];
        }
        
    }
    return _segments;
}
- (SCNNode *)fillPlane{
    return  [self childNodeWithName:@"fillPlane" recursively:YES];
}

- (instancetype)init{
    if (self = [super init]) {
        self.focusSquareSize = 0.17;
        self.focusSquareThickness = 0.018;
        self.scaleForClosedSquare = 0.97;
        self.sideLengthForOpenSquareSegments = 0.2;
        self.animationDuration = 0.7;
        self.focusSquareColor = [UIColor yellowColor];
        self.focusSquareColorLight = [UIColor yellowColor];
        self.opacity = 0.0;
        [self addChildNode:[self focusSquareNode]];
        [self open];
        self.lastPositionOnPlane = SCNVector3Zero;
        self.lastPosition = SCNVector3Zero;
        self.recentFocusSquarePositions = [NSMutableArray array];
        self.anchorsOfVisitedPlanes = [NSMutableSet set];
    }
    return self;
}


- (void)updateForPosition:(SCNVector3)position PlaneAnchor:(ARPlaneAnchor *)planeAnchor Camera:(ARCamera *)camera{
    self.lastPosition = position;
    if (planeAnchor) {
        [self closeWithFlash:![self.anchorsOfVisitedPlanes containsObject:planeAnchor]];
        self.lastPositionOnPlane = position;
        [self.anchorsOfVisitedPlanes addObject:planeAnchor];
    }else{
        [self open];
    }
    [self updateTransformForPosition:position Camera:camera];
}
- (void)hide{
    if (self.opacity ==1.0) {
        [self runAction:[SCNAction fadeOutWithDuration:0.5]];
    }
}
- (void)unhide{
    if (self.opacity ==0.0) {
        [self runAction: [SCNAction fadeInWithDuration:0.5]];
    }
}
- (void)updateTransformForPosition:(SCNVector3)position Camera:(ARCamera *)camera{
    NSValue *value = [NSValue valueWithSCNVector3:position];
    [self.recentFocusSquarePositions addObject:value];
    [self.recentFocusSquarePositions keepLastWithElements:8];
    SCNVector3 average = [NSArray getAverageFromSCNVector3Array:self.recentFocusSquarePositions];
    if (average.x!=0 &&average.y!=0&&average.z!=0) {
        self.position = average;
        [self setUniformScale: [self scaleBasedOnDistanceWithCamera:camera]];
    }
    if (camera) {
        CGFloat tilt = fabs(camera.eulerAngles.x);
        CGFloat threshold1 = M_PI_2 * 0.65;
        CGFloat threshold2 = M_PI_2 * 0.75;
        CGFloat yaw = atan2f(camera.transform.columns[0].x, camera.transform.columns[1].x);
        CGFloat angle = 0;
        if(tilt<threshold1){
            angle = camera.eulerAngles.y;
        }else if (tilt<threshold2&&tilt>=threshold1){
            CGFloat relativeInRange = fabs((tilt - threshold1) / (threshold2 - threshold1));
            CGFloat normalizedY = [self normalizeWithAngle:camera.eulerAngles.y ForMinimalRotationTo:yaw];
            angle = normalizedY * (1 - relativeInRange) + yaw * relativeInRange;
        }else{
            angle = yaw;
        }
        self.rotation = SCNVector4Make(0, 1, 0, angle);
    }
}
- (CGFloat)normalizeWithAngle:(CGFloat)angle ForMinimalRotationTo:(CGFloat)ref{
    CGFloat normalized = angle;
    
    while (fabs(normalized - ref)>M_PI_4) {
        if(angle>ref){
            normalized -= M_PI_2;
        }else{
            normalized += M_PI_2;
        }
    }
    return normalized;
}
- (CGFloat)scaleBasedOnDistanceWithCamera:(ARCamera *)camera{
    if (camera) {
        SCNVector3 position = [SCNVector3Tool positionFromTransform:camera.transform];
        SCNVector3 temp = SCNVector3Make(self.worldPosition.x - position.x, self.worldPosition.y - position.y, self.worldPosition.z - position.z);
        
        CGFloat distanceFromCamera = [SCNVector3Tool lengthWith:temp];
        CGFloat newScale = distanceFromCamera < 0.7 ? (distanceFromCamera / 0.7) : (0.25 * distanceFromCamera + 0.825);
        return newScale;
    }
    return 1.0;
}
- (SCNAction *)pulseAction{
    SCNAction *pulseOutAction = [SCNAction fadeOpacityTo:0.4 duration:0.5];
    SCNAction *pulseInAction = [SCNAction fadeOpacityTo:1.0 duration:0.5];
    pulseOutAction.timingMode = SCNActionTimingModeEaseOut;
    pulseInAction.timingMode = SCNActionTimingModeEaseOut;
    return [SCNAction repeatActionForever:[SCNAction sequence:@[pulseOutAction,pulseInAction]]];
}
- (void)stopPulsingForNode:(SCNNode *)node{
    [node removeActionForKey:@"pulse"];
    node.opacity = 1.0;
}
- (void)open{
    if (self.isOpen||self.isAnimating) {
        return;
    }
    [SCNTransaction begin];
    SCNTransaction.animationTimingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    SCNTransaction.animationDuration = self.animationDuration / 4;
    self.entireSquare.opacity = 1.0;
    [self.segments[0] openWithDirection:left newLength:self.sideLengthForOpenSquareSegments];
    [self.segments[1] openWithDirection:right newLength:self.sideLengthForOpenSquareSegments];
    [self.segments[2] openWithDirection:up newLength:self.sideLengthForOpenSquareSegments];
    [self.segments[3] openWithDirection:up newLength:self.sideLengthForOpenSquareSegments];
    [self.segments[4] openWithDirection:down newLength:self.sideLengthForOpenSquareSegments];
    [self.segments[5] openWithDirection:down newLength:self.sideLengthForOpenSquareSegments];
    [self.segments[6] openWithDirection:left newLength:self.sideLengthForOpenSquareSegments];
    [self.segments[7] openWithDirection:right newLength:self.sideLengthForOpenSquareSegments];
    SCNTransaction.completionBlock = ^{
        [self.entireSquare runAction:[self pulseAction] forKey:@"pulse"];
    };
    [SCNTransaction commit];
    
    [SCNTransaction begin];
    [SCNTransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    SCNTransaction.animationDuration = self.animationDuration/4;
    [self.entireSquare setUniformScale: self.focusSquareSize];
    self.isOpen = true;
    
}

- (void)closeWithFlash:(BOOL)flash{
    if (!self.isOpen || self.isAnimating) {
        return;
    }
    self.isAnimating = true;
    [self stopPulsingForNode:self.entireSquare];
    [SCNTransaction begin];
    SCNTransaction.animationTimingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    SCNTransaction.animationDuration = self.animationDuration / 2;
    self.entireSquare.opacity = 0.99;
    SCNTransaction.completionBlock = ^{
        [SCNTransaction begin];
        [SCNTransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
        SCNTransaction.animationDuration = self.animationDuration / 4;
        [self.segments[0] closeWithDirection:right];
        [self.segments[1] closeWithDirection:left];
        [self.segments[2] closeWithDirection:down];
        [self.segments[3] closeWithDirection:down];
        [self.segments[4] closeWithDirection:up];
        [self.segments[5] closeWithDirection:up];
        [self.segments[6] closeWithDirection:right];
        [self.segments[7] closeWithDirection:left];
        
        SCNTransaction.completionBlock = ^{ self.isAnimating = NO; };
        [SCNTransaction commit];
    };
        [SCNTransaction commit];
    
    [self.entireSquare addAnimation:[self scaleAnimationForKeyPath:@"transform.scale.x"] forKey:@"transform.scale.x"];
    [self.entireSquare addAnimation:[self scaleAnimationForKeyPath:@"transform.scale.y"] forKey:@"transform.scale.y"];
    [self.entireSquare addAnimation:[self scaleAnimationForKeyPath:@"transform.scale.z"] forKey:@"transform.scale.z"];
    
    if (flash) {
        SCNAction *waitAction = [SCNAction waitForDuration:self.animationDuration * 0.75];
        SCNAction *fadeInAction = [SCNAction fadeOpacityTo:0.25 duration:self.animationDuration * 0.125];
        SCNAction *fadeOutAction = [SCNAction fadeOpacityTo:0.0 duration:self.animationDuration * 0.125];
        [self.fillPlane runAction: [SCNAction sequence:@[waitAction,fadeInAction,fadeOutAction]]];
        SCNAction *flashSquareAction = [self flashAnimationWithDuration:self.animationDuration * 0.25];
         [self.segments[0] runAction: [SCNAction sequence:@[waitAction,flashSquareAction]]];
         [self.segments[1] runAction: [SCNAction sequence:@[waitAction,flashSquareAction]]];
         [self.segments[2] runAction: [SCNAction sequence:@[waitAction,flashSquareAction]]];
         [self.segments[3] runAction: [SCNAction sequence:@[waitAction,flashSquareAction]]];
         [self.segments[4] runAction: [SCNAction sequence:@[waitAction,flashSquareAction]]];
         [self.segments[5] runAction: [SCNAction sequence:@[waitAction,flashSquareAction]]];
         [self.segments[6] runAction: [SCNAction sequence:@[waitAction,flashSquareAction]]];
         [self.segments[7] runAction: [SCNAction sequence:@[waitAction,flashSquareAction]]];
    }
    self.isOpen = NO;
    
}
- (SCNAction *)flashAnimationWithDuration:(NSTimeInterval)duration{
    SCNAction *action = [SCNAction customActionWithDuration:duration actionBlock:^(SCNNode * _Nonnull node, CGFloat elapsedTime) {
          CGFloat elapsedTimePercentage = elapsedTime / duration;
        CGFloat saturation = 2.8 * (elapsedTimePercentage - 0.5) * (elapsedTimePercentage - 0.5) + 0.3;
        node.geometry.firstMaterial.diffuse.contents = [UIColor colorWithHue:0.1333 saturation:saturation brightness:1.0 alpha:1.0];
    }];
     return action;
    
}
- (CAKeyframeAnimation *)scaleAnimationForKeyPath:(NSString *)keyPath{
    CAKeyframeAnimation *scaleAnimation = [CAKeyframeAnimation animationWithKeyPath:keyPath];
    CAMediaTimingFunction *easeOut = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    CAMediaTimingFunction *easeInOut = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    CAMediaTimingFunction *linear = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    CGFloat fs = self.focusSquareSize;
    CGFloat ts = self.focusSquareSize * self.scaleForClosedSquare;
    NSArray *values = @[@(fs),@(fs * 1.15),@(fs * 1.15),@(ts * 0.97), @(ts)];
    NSArray *keyTimes= @[@(0.00),@(0.25),@(0.50),@(0.75),@(1.00)];
    NSArray *timingFunctions = @[easeOut,linear,easeOut,easeInOut];
    scaleAnimation.values = values;
    scaleAnimation.keyTimes = keyTimes;
    scaleAnimation.timingFunctions = timingFunctions;
    scaleAnimation.duration =self.animationDuration;
    
    return scaleAnimation;
    
}
- (SCNNode *)focusSquareNode{
    CGFloat sl = 0.5;
    CGFloat st = self.focusSquareThickness;
    CGFloat c= self.focusSquareThickness/2;
    
    FocusSquareSegment * s1 = [[FocusSquareSegment alloc]initWithName:@"s1" Width:sl Thickness:st Color:self.focusSquareColor Vertical:NO];
    NSLog(@"%@",[SCNVector3Tool friendlyStringWithSCNVector3:s1.position]);
     FocusSquareSegment * s2 = [[FocusSquareSegment alloc]initWithName:@"s2" Width:sl Thickness:st Color:self.focusSquareColor Vertical:NO];
     FocusSquareSegment * s3 = [[FocusSquareSegment alloc]initWithName:@"s3" Width:sl Thickness:st Color:self.focusSquareColor Vertical:YES];
     FocusSquareSegment * s4 = [[FocusSquareSegment alloc]initWithName:@"s4" Width:sl Thickness:st Color:self.focusSquareColor Vertical:YES];
     FocusSquareSegment * s5 = [[FocusSquareSegment alloc]initWithName:@"s5" Width:sl Thickness:st Color:self.focusSquareColor Vertical:YES];
     FocusSquareSegment * s6 = [[FocusSquareSegment alloc]initWithName:@"s6" Width:sl Thickness:st Color:self.focusSquareColor Vertical:YES];
     FocusSquareSegment * s7 = [[FocusSquareSegment alloc]initWithName:@"s7" Width:sl Thickness:st Color:self.focusSquareColor Vertical:NO];
     FocusSquareSegment * s8 = [[FocusSquareSegment alloc]initWithName:@"s8" Width:sl Thickness:st Color:self.focusSquareColor Vertical:NO];
    s1.position = SCNVector3Make(s1.position.x - (sl / 2 - c), s1.position.y - (sl - c), s1.position.z + 0);
    s2.position = SCNVector3Make(s2.position.x + (sl / 2 - c), s2.position.y -(sl - c) , s2.position.z + 0);
    s3.position = SCNVector3Make(s3.position.x - sl, s3.position.y -(sl / 2) , s3.position.z + 0);
    s4.position = SCNVector3Make(s4.position.x + sl, s4.position.y -(sl / 2) , s4.position.z + 0);
    s5.position = SCNVector3Make(s5.position.x - sl, s5.position.y +(sl / 2) , s5.position.z + 0);
    s6.position = SCNVector3Make(s6.position.x + sl, s6.position.y +(sl / 2) , s6.position.z + 0);
    s7.position = SCNVector3Make(s7.position.x - (sl / 2 - c), s7.position.y +(sl - c) , s7.position.z + 0);
    s8.position = SCNVector3Make(s8.position.x + (sl / 2 - c), s8.position.y +(sl - c) , s8.position.z + 0);
    NSLog(@"%@,\n%@,\n%@,\n%@,\n%@,\n%@,\n%@,\n%@,",[SCNVector3Tool friendlyStringWithSCNVector3:s1.position],[SCNVector3Tool friendlyStringWithSCNVector3:s2.position],[SCNVector3Tool friendlyStringWithSCNVector3:s3.position],[SCNVector3Tool friendlyStringWithSCNVector3:s4.position],[SCNVector3Tool friendlyStringWithSCNVector3:s5.position],[SCNVector3Tool friendlyStringWithSCNVector3:s6.position],[SCNVector3Tool friendlyStringWithSCNVector3:s7.position],[SCNVector3Tool friendlyStringWithSCNVector3:s8.position]);
    
    SCNPlane *fillPlane = [SCNPlane planeWithWidth:1.0 - st * 2 + c height:1.0 - st * 2 + c];
    SCNMaterial *material = [SCNMaterial materialWithDiffuse:self.focusSquareColorLight RespondsToLighting:NO];
    fillPlane.materials = @[material];
    SCNNode *fillPlaneNode = [SCNNode nodeWithGeometry:fillPlane];
    fillPlaneNode.name = @"fillPlane";
    fillPlaneNode.opacity = 0.0;
    
    SCNNode *planeNode = [SCNNode node];
    planeNode.eulerAngles = SCNVector3Make(M_PI_2, 0, 0);
    [planeNode setUniformScale:self.focusSquareSize * self.scaleForClosedSquare];
    [planeNode addChildNode:s1];
    [planeNode addChildNode:s2];
    [planeNode addChildNode:s3];
    [planeNode addChildNode:s4];
    [planeNode addChildNode:s5];
    [planeNode addChildNode:s6];
    [planeNode addChildNode:s7];
    [planeNode addChildNode:s8];
    [planeNode addChildNode:fillPlaneNode];
    self.isOpen = NO;
    
    [planeNode renderOnTop];
    return planeNode;
}

    

@end
