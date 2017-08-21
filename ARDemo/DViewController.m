//
//  ViewController.m
//  ARDemo
//
//  Created by apple on 2017/7/18.
//  Copyright © 2017年 Charly. All rights reserved.
//

#import "DViewController.h"
#import "SCNVector3Tool.h"
#import "Plane.h"
#import <Photos/Photos.h>
#import "SettingManager.h"
#import "TextManager.h"
#import "FocusSquare.h"
#import "VirtualObject.h"
#import "HitTestVisualization.h"
#import "SCNVector3Tool.h"
#import "Gesture.h"
#import "VirtualObjectSelectionViewController.h"
#import "UIImage+Extension.h"
#import "NSMutableArray+Extension.h"
#import "ARSCNView+Extension.h"
#import "FeatureHitTestResult.h"
#import "SettingsViewController.h"



@interface DViewController ()<ARSCNViewDelegate,ARSessionDelegate,UIPopoverControllerDelegate,VirtualObjectSelectionViewControllerDelegate,UIPopoverPresentationControllerDelegate>
@property (weak, nonatomic) IBOutlet ARSCNView *sceneView;
@property (weak, nonatomic) IBOutlet UIButton *addObjectButton;
@property (weak, nonatomic) IBOutlet UIButton *settingButton;
@property (weak, nonatomic) IBOutlet UIButton *screenShotButton;
@property (weak, nonatomic) IBOutlet UIButton *restartExperienceButton;
@property (nonatomic,assign) CGPoint screenCenter;
@property (nonatomic,strong) ARSession *session;
@property (nonatomic,strong) ARSessionConfiguration *sessionCfg;

@property (nonatomic,strong) TextManager *textManager;
@property (nonatomic,strong) FocusSquare *focusSquare;
@property (nonatomic,assign) VirtualObject *virtualObject;
@property (nonatomic,strong) HitTestVisualization *hitTestVisualization;
@property (nonatomic,strong) Gesture *currentGesture;

@property (nonatomic,strong) NSTimer *trackingFallbackTimer;
@property (nonatomic,assign) BOOL dragOnInfinitePlanesEnabled;
@property (nonatomic,assign) BOOL showHitTestAPIVisualization;
@property (nonatomic,assign) BOOL use3DOFTracking;
@property (nonatomic,assign) BOOL use3DOFTrackingFallback;
@property (nonatomic,assign) BOOL isLoadingObject;
@property (nonatomic,assign) BOOL restartExperienceButtonIsEnabled;
@property (nonatomic,strong) NSMutableArray *recentVirtualObjectDistances;
@end

@implementation DViewController
#pragma mark ----- Main Setup & View Controller methods
- (void)viewDidLoad {
    [super viewDidLoad];
    //初始化设置
    [SettingManager registerDefaults];
    //设置SceneView
    [self setupScene];
    //设置debug面板
    [self setupDebug];
    //初始化显示文字的管理工具
    [self setupUIControls];
    //初始化焦点区域
    [self setupFocusSquare];
    //更新设置内容
    [self updateSettings];
    //重置3D模型
    [self resetVirtualObject];
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //设置屏幕常亮
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    //重启Session
    [self restartPlaneDetection];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.session pause];
}
#pragma mark --------SceneView
- (void)setupScene{
    self.sceneView.delegate = self;
    self.sceneView.session = self.session;
    //抗锯齿模式 4倍多采样
    self.sceneView.antialiasingMode = SCNAntialiasingModeMultisampling4X;
    // 自动刷新灯光（一般用于3d游戏）
    self.sceneView.automaticallyUpdatesLighting = YES;
    // 设置每秒帧数
    self.sceneView.preferredFramesPerSecond =60;
    //内容比例因子
    self.sceneView.contentScaleFactor = 1.3;
    [self enableEnvironmentMapWithIntensity:25.0];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.screenCenter = self.sceneView.center;
    });
    //设置相机
    SCNCamera *camera = self.sceneView.pointOfView.camera;
    camera.wantsHDR = YES;
    camera.wantsExposureAdaptation = YES;
    camera.exposureOffset = -1;
    camera.minimumExposure = -1;
}

- (void)enableEnvironmentMapWithIntensity:(CGFloat)intensity{
    if (self.sceneView.scene.lightingEnvironment.contents==nil) {
        UIImage *environmentMap = [UIImage imageNamed:@"Models.scnassets/sharedImages/environment_blur.exr"];
        self.sceneView.scene.lightingEnvironment.contents = environmentMap;
    }
    self.sceneView.scene.lightingEnvironment.intensity = intensity;
}

#pragma mark -------------Ambient Light Estimation
- (void)toggleAmbientLightEstimation:(BOOL)enable{
    if (enable) {
        if (!self.sessionCfg.isLightEstimationEnabled) {
            self.sessionCfg.lightEstimationEnabled = YES;
            [self.session runWithConfiguration:self.sessionCfg];
        }
    }else{
        if(self.sessionCfg.isLightEstimationEnabled){
            self.sessionCfg.lightEstimationEnabled = NO;
            [self.session runWithConfiguration:self.sessionCfg];
        }
    }
}



#pragma mark ---------ARSCNViewDelegate
- (void)renderer:(id<SCNSceneRenderer>)renderer updateAtTime:(NSTimeInterval)time{
    [self refreshFeaturePoints];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateFocusSquare];
        [self.hitTestVisualization render];
    });
    if (self.session.currentFrame.lightEstimate) {
        [self enableEnvironmentMapWithIntensity:self.session.currentFrame.lightEstimate.ambientIntensity/40];
    }else{
        [self enableEnvironmentMapWithIntensity:25];
    }
}
- (void)renderer:(id<SCNSceneRenderer>)renderer didAddNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self addPlaneWithNode:node Anchor:(ARPlaneAnchor *)anchor];
        [self checkIfObjectShouldMoveOntoPlane:(ARPlaneAnchor *)anchor];
    });
    
}
- (void)renderer:(id<SCNSceneRenderer>)renderer didUpdateNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor{
    [self updatePlaneWithAnchor:(ARPlaneAnchor *)anchor];
    [self checkIfObjectShouldMoveOntoPlane:(ARPlaneAnchor *)anchor];
    
}
- (void)renderer:(id<SCNSceneRenderer>)renderer didRemoveNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor{
    [self removePlaneWithAnchor:(ARPlaneAnchor *)anchor];
}
#pragma mark ---------ARSessionDelegate
- (void)session:(ARSession *)session cameraDidChangeTrackingState:(ARCamera *)camera{
    [self.textManager showTrackingQualityInfoForARCameraTrackingState:camera AutoHide:!self.showDebugVisuals];
    switch (camera.trackingState) {
        case ARTrackingStateNotAvailable:
            [self.textManager escalateFeedbackForARCameraTrackingState:camera InSeconds:5.0];
            break;
        case ARTrackingStateLimited:
            if (self.use3DOFTrackingFallback) {
                self.trackingFallbackTimer = [NSTimer scheduledTimerWithTimeInterval:10.0 repeats:NO block:^(NSTimer * _Nonnull timer) {
                    self.use3DOFTracking = YES;
                    [self.trackingFallbackTimer invalidate];
                    self.trackingFallbackTimer = nil;
                }];
            }else{
                [self.textManager escalateFeedbackForARCameraTrackingState:camera InSeconds:5.0];
                
            }
            break;
            case ARTrackingStateNormal:
                [self.textManager cancelScheduledMessageForType:MessageTypeTrackingStateEscalation];
            if (self.use3DOFTrackingFallback && self.trackingFallbackTimer !=nil) {
                [self.trackingFallbackTimer invalidate];
                self.trackingFallbackTimer = nil;
            }
            break;
        default:
            break;
    }
    
}
- (void)session:(ARSession *)session didFailWithError:(NSError *)error{
    NSString * sessionErrorMsg = [NSString stringWithFormat:@"%@,%@",error.localizedDescription,error.localizedFailureReason];
    NSMutableString *mutaSessionErrorMsg = [NSMutableString stringWithString:sessionErrorMsg];
    if (error.localizedRecoveryOptions.count!=0) {
        for (NSString *option in error.localizedRecoveryOptions) {
            [mutaSessionErrorMsg appendString:@"--"];
            [mutaSessionErrorMsg appendString:option];
        }
    }
    BOOL isRecoverable = NO;
    if (error.code ==ARErrorCodeWorldTrackingFailed) {
        isRecoverable = YES;
        [mutaSessionErrorMsg appendString:@"\nYou can try resetting the session or quit the application."];
    }else{
        [mutaSessionErrorMsg appendString:@"\nThis is an unrecoverable error that requires to quit the application."];
    }
    [self displayErrorMessageWithTitle:@"We're sorry!" Message:mutaSessionErrorMsg AllowRestart:isRecoverable];
}
- (void)sessionWasInterrupted:(ARSession *)session{
    [self.textManager  blurBackground];
    [self.textManager showAlertWithTitle:@"Session Interrupted" Message:@"The session will be reset after the interruption has ended." Actions:nil];
}
- (void)sessionInterruptionEnded:(ARSession *)session{
    [self.textManager unblurBackground ];
    [self.session runWithConfiguration:self.sessionCfg options:ARSessionRunOptionResetTracking|ARSessionRunOptionRemoveExistingAnchors];
    
    //重新初始化界面及设置
    [self restartExperience:self];
    [self.textManager showMessageWithText:@"RESETTING SESSION" AutoHide:YES];;
}

#pragma mark ---------Gesture
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (!self.virtualObject) {
        return;
    }
    if (self.currentGesture ==nil) {
        self.currentGesture = [Gesture startGestureFromTouches:touches SceneView:self.sceneView VirtualObject:self.virtualObject];
    }else{
     self.currentGesture = [self.currentGesture updateGestureFromTouches:touches Type:TouchEventTypeTouchBegan];
    }
    [self displayVirtualObjectTransform];
}
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (!self.virtualObject) {
        return;
    }
   self.currentGesture = [self.currentGesture updateGestureFromTouches:touches Type:TouchEventTypeTouchMoved];
    [self displayVirtualObjectTransform];
}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (self.virtualObject == nil) {
        [self chooseObject:self.addObjectButton];
        return;
    }
    self.currentGesture = [self.currentGesture updateGestureFromTouches:touches Type:TouchEventTypeTouchEnded];
}
- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (self.virtualObject == nil) {
        return;
    }
    self.currentGesture = [self.currentGesture updateGestureFromTouches:touches Type:TouchEventTypeTouchCancelled];
    
}
#pragma mark ---------Virtual Object Manipulation
- (void)displayVirtualObjectTransform{
    SCNVector3 cameraPos = [SCNVector3Tool positionFromTransform:self.session.currentFrame.camera.transform];
    SCNVector3 vectorToCamera = SCNVector3Make(cameraPos.x - self.virtualObject.position.x, cameraPos.y - self.virtualObject.position.y, cameraPos.z - self.virtualObject.position.z);
    CGFloat distanceToUser = [SCNVector3Tool lengthWith:vectorToCamera];
    NSInteger angleDegrees = (int)((self.virtualObject.eulerAngles.y) * 180 /M_PI ) % 360;
    if (angleDegrees < 0) {
        angleDegrees += 360;
    }
    NSString *distance = [NSString stringWithFormat:@"%.2f",distanceToUser];
    NSString *scale = [NSString stringWithFormat:@"%.2f",self.virtualObject.scale.x];
    [self.textManager showDebugMessage:[NSString stringWithFormat:@"Distance:%@ m\nRotation:%ld °\nScale:%@x ",distance,angleDegrees,scale]];
    
}
- (void)moveVirtualObjectToPosition:(SCNVector3)position Instantly:(BOOL)instantly FilterPosition:(BOOL)filterPosition{
    if (position.x == 0 && position.y == 0 && position.z == 0) {
        [self.textManager showMessageWithText:@"CANNOT PLACE OBJECT\nTry moving left or right." AutoHide:YES];
        if(self.virtualObject == nil){
            [self resetVirtualObject];
        }
        return;
    }
    if(instantly){
        [self setNewVirtualObjectPosition:position];
    }else{
        [self updateVirtualObjectPosition:position FilterPosition:filterPosition];
    }
}
- (void)setNewVirtualObjectPosition:(SCNVector3)pos{
    [self.recentVirtualObjectDistances removeAllObjects];
    SCNVector3 cameraWorldPos = [SCNVector3Tool positionFromTransform:self.session.currentFrame.camera.transform];
    SCNVector3 cameraToPosition = SCNVector3Make(pos.x - cameraWorldPos.x, pos.y - cameraWorldPos.y, pos.z - cameraWorldPos.z);
    cameraToPosition = [SCNVector3Tool setMaximumLength:cameraToPosition Length:10];
    self.virtualObject.position = SCNVector3Make(cameraWorldPos.x + cameraToPosition.x, cameraWorldPos.y + cameraToPosition.y, cameraWorldPos.z + cameraToPosition.z);
    if(self.virtualObject.parentNode == nil){
        [self.sceneView.scene.rootNode addChildNode:self.virtualObject];
    }
    
}
- (void)updateVirtualObjectPosition:(SCNVector3)position FilterPosition:(BOOL)filterPosition{
    SCNVector3 cameraWorldPos = [SCNVector3Tool positionFromTransform:self.session.currentFrame.camera.transform];
    SCNVector3 cameraToPosition = SCNVector3Make(position.x - cameraWorldPos.x, position.y - cameraWorldPos.y, position.z - cameraWorldPos.z);
    cameraToPosition = [SCNVector3Tool setMaximumLength:cameraToPosition Length:10];
    CGFloat hitTestResultDistance = [SCNVector3Tool lengthWith:cameraToPosition];
    [self.recentVirtualObjectDistances addObject:@(hitTestResultDistance)];
    [self.recentVirtualObjectDistances keepLastWithElements:10];
    
    if (filterPosition) {
        CGFloat averageDistance = [NSArray getAverageFromCGFloatArray:self.recentVirtualObjectDistances];
      cameraToPosition = [SCNVector3Tool setLengthWith:cameraToPosition Length:averageDistance];
        SCNVector3 averagedDistancePos = SCNVector3Make(cameraWorldPos.x + cameraToPosition.x, cameraWorldPos.y + cameraToPosition.y, cameraWorldPos.z + cameraToPosition.z);
        self.virtualObject.position = averagedDistancePos;
    }else{
         SCNVector3 averagedDistancePos = SCNVector3Make(cameraWorldPos.x + cameraToPosition.x, cameraWorldPos.y + cameraToPosition.y, cameraWorldPos.z + cameraToPosition.z);
        self.virtualObject.position = averagedDistancePos;
    }
}
- (void)resetVirtualObject{
    [self.virtualObject unloadModel];
    [self.virtualObject removeFromParentNode];
    self.virtualObject = nil;
    [self.addObjectButton setImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
    [self.addObjectButton setImage:[UIImage imageNamed:@"addPressed"] forState:UIControlStateHighlighted];
    [SettingManager setSelectedObjectWithInteger:-1];
    
}
- (void)checkIfObjectShouldMoveOntoPlane:(ARPlaneAnchor *)anchor{
    VirtualObject *object = self.virtualObject;
    SCNNode *planeAnchorNode = [self.sceneView nodeForAnchor:anchor];
    SCNVector3 objectPos = [planeAnchorNode convertPosition:object.position fromNode:object.parentNode];
    if (objectPos.y ==0) {
        return;
    }
    CGFloat tolerance = 0.1;
    CGFloat minX = anchor.center.x - anchor.extent.x / 2 - anchor.extent.x * tolerance;
    CGFloat maxX = anchor.center.x + anchor.extent.x / 2 + anchor.extent.x * tolerance;
    CGFloat minZ = anchor.center.z - anchor.extent.z / 2 - anchor.extent.z * tolerance;
    CGFloat maxZ = anchor.center.z + anchor.extent.z / 2 + anchor.extent.z * tolerance;
    if(objectPos.x > maxX||objectPos.x < minX||objectPos.z > maxZ|| objectPos.z < minZ){
        return;
    }
    CGFloat verticalAllowance = 0.03;
    if (objectPos.y > -verticalAllowance && objectPos.y < verticalAllowance){
        [self.textManager showDebugMessage:@"OBJECT MOVED\nSurface detected nearby"];
        [SCNTransaction begin];
        SCNTransaction.animationDuration = 0.5;
        SCNTransaction.animationTimingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        SCNVector3 pos = object.position;
        pos.y = anchor.transform.columns[3].y;
        object.position = pos;
        [SCNTransaction commit];
    }
}

- (void)worldPositionFromScreenPosition:(CGPoint)position ObjectPostion:(SCNVector3)objectPosition InfinitePlane:(BOOL)infinitePlane PointBL:(pointBlock)pointBL{
    NSArray <ARHitTestResult *>*planeHitTestResult = [self.sceneView hitTest:position types:ARHitTestResultTypeExistingPlaneUsingExtent];
    // 1. Always do a hit test against exisiting plane anchors first.
    //首先要对现有的平面做一个hit test
    //    (If any such anchors exist & only within their extents.)
    //  如果有这样的锚存在&仅在它们的范围内
    if(planeHitTestResult.firstObject){
        SCNVector3 planHitTestPosition = [SCNVector3Tool positionFromTransform:planeHitTestResult.firstObject.worldTransform];
        ARAnchor *planeAnchor = planeHitTestResult.firstObject.anchor;
        pointBL(planHitTestPosition,(ARPlaneAnchor *)planeAnchor,YES);
    }
    // 2. Collect more information about the environment by hit testing against
    //通过点击测试来收集更多关于环境的信息
    //    the feature point cloud, but do not return the result yet.
    //特征点云，但还没有返回结果
    SCNVector3 featureHitTestPosition = SCNVector3Zero;
    BOOL highQualityFeatureHitTestResult = NO;
    NSArray<FeatureHitTestResult *> *highQualityfeatureHitTestResults = [self.sceneView hitTestWithFeatures:position ConeOpeningAngleInDegrees:18 MinDistance:0.2 MaxDistance:2.0 MaxResults:1];
    if (highQualityfeatureHitTestResults.count!=0) {
        FeatureHitTestResult *result = highQualityfeatureHitTestResults[0];
        featureHitTestPosition = result.position;
        highQualityFeatureHitTestResult = YES;
    }
    if ((infinitePlane && self.dragOnInfinitePlanesEnabled)||!highQualityFeatureHitTestResult) {
        SCNVector3 pointOnPlane = objectPosition;
        SCNVector3 pointOnInfinitePlane = [self.sceneView hitTestWithInfiniteHorizontalPlane:position PointOnPlane:pointOnPlane];
        if (pointOnInfinitePlane.x!=0 && pointOnInfinitePlane.y!=0 && pointOnInfinitePlane.z!=0 ) {
            pointBL(pointOnInfinitePlane,nil,YES);
        }
    }
    if (highQualityFeatureHitTestResult) {
        pointBL(featureHitTestPosition,nil,NO);
    }
    NSArray<FeatureHitTestResult *>*unfilteredFeatureHitTestResults = [self.sceneView hitTestWithFeatures:position];
    if (unfilteredFeatureHitTestResults.count!=0) {
        FeatureHitTestResult *result = unfilteredFeatureHitTestResults[0];
        pointBL(result.position,nil,false);
    }
         pointBL(SCNVector3Zero,nil,false);
}
#pragma mark ---------Plane
- (void)addPlaneWithNode:(SCNNode *)node Anchor:(ARPlaneAnchor *)anchor{
    SCNVector3 position = [SCNVector3Tool positionFromTransform:anchor.transform];
    [self.textManager showDebugMessage:[NSString stringWithFormat:@"EW SURFACE DETECTED AT %@",[SCNVector3Tool friendlyStringWithSCNVector3:position]]];
    Plane *plane = [[Plane alloc]initWithAnchor:anchor ShowDebugVisualization:self.showDebugVisuals];
    self.planes[anchor] = plane;
    [node addChildNode:plane];
    [self.textManager cancelScheduledMessageForType:MessageTypePlaneEstimation];
    [self.textManager showMessageWithText:@"SURFACE DETECTED" AutoHide:YES];
    if (self.virtualObject ==nil) {
        [self.textManager scheduleMessageWithString:@"TAP + TO PLACE AN OBJECT" InSeconds:7.5 MessageType:MessageTypeContentPlacement];
    }
}
- (void)updatePlaneWithAnchor:(ARPlaneAnchor *)anchor{
    Plane *plane = self.planes[anchor];
    [plane updateWithAnchor:anchor];
}
- (void)removePlaneWithAnchor:(ARPlaneAnchor *)anchor{
    Plane *plane = self.planes[anchor];
    [self.planes removeObjectForKey:anchor];
    [plane removeFromParentNode];
}
- (void)restartPlaneDetection{
    
    ARWorldTrackingSessionConfiguration *worldSessionConfig = (ARWorldTrackingSessionConfiguration *)self.sessionCfg;
    worldSessionConfig.planeDetection = ARPlaneDetectionHorizontal;
    [self.session runWithConfiguration: worldSessionConfig options: ARSessionRunOptionResetTracking|ARSessionRunOptionRemoveExistingAnchors];
    if (self.trackingFallbackTimer !=nil) {
        [self.trackingFallbackTimer invalidate];
        self.trackingFallbackTimer = nil;
    }
    [self.textManager scheduleMessageWithString:@"FIND A SURFACE TO PLACE AN OBJECT" InSeconds:7.5 MessageType:MessageTypePlaneEstimation];
}
#pragma mark ---------Debug Visualizations
- (void)refreshFeaturePoints{
    if (!self.showDebugVisuals) {
        return;
    }
    if (!self.session.currentFrame.rawFeaturePoints) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        self.featurePointCountLabel.text = [[NSString stringWithFormat:@"Features:%ld",self.session.currentFrame.rawFeaturePoints.count] uppercaseString];
    });
}

- (void)setupDebug{
    self.messagePanel.layer.cornerRadius = 3.0;
    self.messagePanel.clipsToBounds = YES;
}
#pragma mark ---------Error handling
- (void)displayErrorMessageWithTitle:(NSString *)title Message:(NSString *)message AllowRestart:(BOOL)allRestart{
    [self.textManager blurBackground];
    if (allRestart) {
        UIAlertAction * restartAction = [UIAlertAction actionWithTitle:@"Reset" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self.textManager unblurBackground];
            [self restartExperience:self];
        }];
        [self.textManager showAlertWithTitle:title Message:message Actions:@[restartAction]];
    }else{
          [self.textManager showAlertWithTitle:title Message:message Actions:@[]];
    }
}
#pragma mark ---------UI Elements and Actions
- (void)setupUIControls{
    self.textManager = [[TextManager alloc]initWithViewController:self];
    self.debugMessageLabel.hidden = YES;
    self.featurePointCountLabel.text = @"";
    self.debugMessageLabel.text = @"";
    self.messageLabel.text = @"";
}

- (void)updateSettings{
    self.showDebugVisuals = [SettingManager getPopulateSettingWithSetting:SettingDebugMode];
    [self toggleAmbientLightEstimation:[SettingManager getPopulateSettingWithSetting:SettingAmbientLightEstimation]];
    self.dragOnInfinitePlanesEnabled = [SettingManager getPopulateSettingWithSetting:SettingDragOnInfinitePlanes];
    self.showHitTestAPIVisualization = [SettingManager getPopulateSettingWithSetting:SettingShowHitTestAPI];
    self.use3DOFTracking = [SettingManager getPopulateSettingWithSetting:SettingUse3DOFTracking];
    self.use3DOFTrackingFallback = [SettingManager getPopulateSettingWithSetting:SettingUse3DOFFallback];
    for (Plane *plane in self.planes.allValues) {
        [plane updateOcclusionSetting];
    }
}
#pragma mark ---------Virtual Object Loading
- (void)loadVirtualObjectAt:(NSInteger)index{
    [self resetVirtualObject];
    UIActivityIndicatorView *spinner =[[UIActivityIndicatorView alloc]init];
    spinner.center = self.addObjectButton.center;
    CGRect rect = spinner.bounds;
    rect.size = CGSizeMake(self.addObjectButton.bounds.size.width - 5, self.addObjectButton.bounds.size.height - 5);
    spinner.bounds = rect;
    [self.addObjectButton setImage:[UIImage imageNamed:@"buttonring"] forState:0];
    [self.sceneView addSubview:spinner];
    [spinner startAnimating];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        self.isLoadingObject = YES;
        VirtualObject *object = [VirtualObject getObjects][index];
        object.viewController = self;
        self.virtualObject = object;
        [object loadModel];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.focusSquare.lastPosition.x == 0 && self.focusSquare.lastPosition.x == 0 && self.focusSquare.lastPosition.x == 0) {
                [self setNewVirtualObjectPosition:SCNVector3Zero];
            }else{
                [self setNewVirtualObjectPosition:self.focusSquare.lastPosition];
            }
            [spinner removeFromSuperview];
            UIImage *buttonImage = [UIImage composeButtonImageWithThumbImage:self.virtualObject.thumbImage Alpha:1.0];
            UIImage *pressedButtonImage = [UIImage composeButtonImageWithThumbImage:self.virtualObject.thumbImage Alpha:0.3];
            [self.addObjectButton setImage:buttonImage forState:UIControlStateNormal];
            [self.addObjectButton setImage:pressedButtonImage forState:UIControlStateHighlighted];
            self.isLoadingObject = NO;
            
        });
        
    });
    
}
- (IBAction)chooseObject:(UIButton *)sender {
    if (self.isLoadingObject) {
        return;
    }
    [self.textManager cancelScheduledMessageForType:MessageTypeContentPlacement];
    NSInteger rowHeight = 45;
    CGSize popoverSize = CGSizeMake(250, rowHeight * 5);
    VirtualObjectSelectionViewController * objectViewController = [[VirtualObjectSelectionViewController alloc]initWithSize:popoverSize];
    objectViewController.delegate = self;
    objectViewController.modalPresentationStyle = UIModalPresentationPopover;
    objectViewController.popoverPresentationController.delegate = self;
    [self presentViewController:objectViewController animated:YES completion:nil];
    objectViewController.popoverPresentationController.sourceView = sender;
    objectViewController.popoverPresentationController.sourceRect = sender.bounds;
}
#pragma mark ---------Settings

- (IBAction)restartExperience:(id)sender {
    if (!self.restartExperienceButton.enabled&&self.isLoadingObject) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        self.restartExperienceButtonIsEnabled = NO;
        [self.textManager cancelAllScheduledMessages];
        [self.textManager dismissPresentedAlert];
        [self.textManager showMessageWithText:@"STARTING A NEW SESSION" AutoHide:YES];
        self.use3DOFTracking = NO;
        [self setupFocusSquare];
        [self resetVirtualObject];
        [self restartPlaneDetection];
        
        [self.restartExperienceButton setImage:[UIImage imageNamed:@"restart"] forState:0];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.restartExperienceButtonIsEnabled = YES;
        });
    });
}
- (IBAction)takeScreenshot:(UIButton *)sender {
    if (!self.screenShotButton.enabled) {
        return;
    }
    void(^takeScreenshotBlock)(void) = ^{
        UIImageWriteToSavedPhotosAlbum(self.sceneView.snapshot, nil, nil, nil);
        dispatch_async(dispatch_get_main_queue(), ^{
            UIView *flashOverlay = [[UIView alloc]initWithFrame:self.sceneView.frame];
            flashOverlay.backgroundColor = [UIColor whiteColor];
            [self.sceneView addSubview:flashOverlay];
            [UIView animateWithDuration:0.25 animations:^{
                flashOverlay.alpha = 0.0;
            } completion:^(BOOL finished) {
                [flashOverlay removeFromSuperview];
            }];
        });
    };
    
    switch ([PHPhotoLibrary authorizationStatus]) {
        case PHAuthorizationStatusAuthorized:
        {
            takeScreenshotBlock();
        }
            break;
        case PHAuthorizationStatusDenied:
        {
            NSString *title = @"Photos access denied";
            NSString *message = @"Please enable Photos access for this application in Settings > Privacy to allow saving screenshots.";
            [self.textManager showAlertWithTitle:title Message:message Actions:nil];
        }
            break;
        case PHAuthorizationStatusNotDetermined:
        {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                if (status ==PHAuthorizationStatusAuthorized) {
                    takeScreenshotBlock();
                }
            }];
        }
            break;
        case PHAuthorizationStatusRestricted:
        {
            NSString *title = @"Photos access denied";
            NSString *message = @"Please enable Photos access for this application in Settings > Privacy to allow saving screenshots.";
            [self.textManager showAlertWithTitle:title Message:message Actions:nil];
        }
            break;
    }
}
- (IBAction)showSettings:(UIButton *)sender {
    UIStoryboard *storyborad = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    SettingsViewController *setting = [storyborad instantiateViewControllerWithIdentifier:@"settingsViewController"];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissSettings)];
    setting.navigationItem.rightBarButtonItem = barButtonItem;
    setting.title = @"Options";
    UINavigationController *navigationController = [[UINavigationController alloc]initWithRootViewController:setting];
    navigationController.modalPresentationStyle = UIModalPresentationPopover;
    navigationController.popoverPresentationController.delegate = self;
    navigationController.preferredContentSize = CGSizeMake(self.sceneView.bounds.size.width - 20, self.sceneView.bounds.size.height - 50);
    [self presentViewController:navigationController animated:YES completion:nil];
    navigationController.popoverPresentationController.sourceView = self.settingButton;
    navigationController.popoverPresentationController.sourceRect = self.settingButton.bounds;
}
- (void)dismissSettings{
    [self dismissViewControllerAnimated:YES completion:nil];
    [self updateSettings];
}
#pragma mark ---------FocusSquare
-  (void)setupFocusSquare{
    self.focusSquare.hidden = YES;
    [self.focusSquare removeFromParentNode];
    self.focusSquare = [[FocusSquare alloc]init];
    [self.sceneView.scene.rootNode addChildNode:self.focusSquare];
    
    [self.textManager scheduleMessageWithString:@"TRY MOVING LEFT OR RIGHT" InSeconds:5.0 MessageType:MessageTypeFocusSquare];
}

- (void)updateFocusSquare{
    if (self.virtualObject!=nil &&[self.sceneView isNodeInsideFrustum:self.virtualObject withPointOfView:self.sceneView.pointOfView]) {
        [self.focusSquare hide];
    }else{
        [self.focusSquare unhide];
    }
    [self worldPositionFromScreenPosition:self.screenCenter ObjectPostion:self.focusSquare.position InfinitePlane:NO PointBL:^(SCNVector3 position, ARPlaneAnchor *planeAnchor, BOOL hitAPlane) {
        [self.focusSquare updateForPosition:position PlaneAnchor:planeAnchor Camera:self.session.currentFrame.camera];
        [self.textManager cancelScheduledMessageForType:MessageTypeFocusSquare];
    }];
    
}
#pragma mark ---------VirtualObjectSelectionViewControllerDelegate
- (void)virtualObjectSelectionViewControllerDidDeselectObject:(VirtualObjectSelectionViewController *)controller{
    [self resetVirtualObject];
}
- (void)virtualObjectSelectionViewController:(VirtualObjectSelectionViewController *)controller DidSelectedObjectAtIndexPath:(NSInteger)indexpath{
    [self loadVirtualObjectAt:indexpath];
}
#pragma mark ---------UIPopoverPresentationControllerDelegate
-(UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller{
    return UIModalPresentationNone;
}
- (void)popoverPresentationControllerDidDismissPopover:(UIPopoverPresentationController *)popoverPresentationController{
    [self updateSettings];
}
#pragma mark ---------SET
- (void)setShowDebugVisuals:(BOOL)showDebugVisuals{
    _showDebugVisuals = showDebugVisuals;
    self.featurePointCountLabel.hidden = !showDebugVisuals;
    self.debugMessageLabel.hidden = !showDebugVisuals;
    self.messagePanel.hidden = !showDebugVisuals;
    
    for (Plane *plane in self.planes.allValues) {
        [plane showDebugVisualization:showDebugVisuals];
    }
    if (self.showDebugVisuals) {
        self.sceneView.debugOptions = ARSCNDebugOptionShowWorldOrigin|ARSCNDebugOptionShowFeaturePoints;
    }else{
        self.sceneView.debugOptions = 0;
    }
    [SettingManager setSettingWithSetting:SettingDebugMode Value:self.showDebugVisuals];
}
- (void)setUse3DOFTracking:(BOOL)use3DOFTracking{
    _use3DOFTracking = use3DOFTracking;
    if (use3DOFTracking) {
        self.sessionCfg = [[ARSessionConfiguration alloc]init];
    }
    // 自适应灯光（相机从暗到强光快速过渡效果会平缓一些）
    self.sessionCfg.lightEstimationEnabled = [SettingManager getPopulateSettingWithSetting:SettingAmbientLightEstimation];
    [self.session runWithConfiguration:self.sessionCfg];
}
- (void)setIsLoadingObject:(BOOL)isLoadingObject{
    _isLoadingObject = isLoadingObject;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.settingButton.enabled = !self.isLoadingObject;
        self.addObjectButton.enabled = !self.isLoadingObject;
        self.screenShotButton.enabled = !self.isLoadingObject;
        self.restartExperienceButton.enabled = !self.isLoadingObject;
    });
}
#pragma mark ---------LAZY
- (ARSession *)session{
    if (!_session) {
        _session = [[ARSession alloc]init];
        _session.delegate = self;
    }
    return _session;
}
- (ARSessionConfiguration *)sessionCfg{
    if(!_sessionCfg){
        ARWorldTrackingSessionConfiguration *worldCfg = [[ARWorldTrackingSessionConfiguration alloc]init];
        _sessionCfg = worldCfg;
    }
    return _sessionCfg;
}
- (NSMutableArray *)recentVirtualObjectDistances{
    if (!_recentVirtualObjectDistances) {
        _recentVirtualObjectDistances = [NSMutableArray array];
    }
    return _recentVirtualObjectDistances;
}
@end
