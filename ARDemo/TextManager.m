//
//  TextManager.m
//  ARDemo
//
//  Created by apple on 2017/8/7.
//  Copyright © 2017年 Charly. All rights reserved.
//

#import "TextManager.h"
#import "ARCameraTrakingState.h"

@interface TextManager()
@property (nonatomic,strong) ARViewController *viewController;
@property (nonatomic,strong)NSTimer *messageHideTimer;
@property (nonatomic,strong)NSTimer *debugMessageHideTimer;
@property (nonatomic,strong)NSTimer *focusSquareMessageTimer;
@property (nonatomic,strong)NSTimer *planeEstimationMessageTimer;
@property (nonatomic,strong)NSTimer *contentPlacementMessageTimer;
@property (nonatomic,strong)NSTimer *trackingStateFeedbackEscalationTimer;

@end
@implementation TextManager
- (instancetype)initWithViewController:(ARViewController *)viewController{
    if (self = [super init]) {
        self.viewController = viewController;
    }
    return self;
}
- (void)showMessageWithText:(NSString *)text AutoHide:(BOOL)autoHide{
    [self.messageHideTimer invalidate];
    self.viewController.messageLabel.text = text;
    [self showHideMessageWithHide:NO Animated:YES];
    if (autoHide) {
        NSInteger charCount = text.length;
        NSTimeInterval displayDuration = MIN(10, charCount / 15.0 + 1.0);
         __weak typeof(self)weakSelf = self;
        self.messageHideTimer = [NSTimer scheduledTimerWithTimeInterval:displayDuration repeats:NO block:^(NSTimer * _Nonnull timer) {
            [weakSelf showHideMessageWithHide:YES Animated:YES];
        }];
    }
}
- (void)showDebugMessage:(NSString *)message{
    if(!self.viewController.showDebugVisuals){
        return;
    }
    [self.debugMessageHideTimer invalidate];
    self.viewController.debugMessageLabel.text = message;
    [self showHideDebugMessage:NO Animated:YES];
    NSInteger charCount = message.length;
    NSTimeInterval displayDuration = MIN(10, charCount / 15.0 + 1.0);
    __weak typeof(self)weakSelf = self;
    
    self.debugMessageHideTimer = [NSTimer scheduledTimerWithTimeInterval:displayDuration repeats:NO block:^(NSTimer * _Nonnull timer) {
        [weakSelf showHideDebugMessage:YES Animated:YES];
   }];
    
}
- (void)scheduleMessageWithString:(NSString *)text InSeconds:(NSTimeInterval)seconds MessageType:(MessageType)messageType{
    if (self.schedulingMessagesBlocked) {
        return;
    }
    NSTimer *timer;
    switch (messageType) {
        case MessageTypeContentPlacement:
            timer = self.contentPlacementMessageTimer;
            break;
        case MessageTypeFocusSquare:
            timer = self.focusSquareMessageTimer;
            break;
        case MessageTypePlaneEstimation:
            timer = self.planeEstimationMessageTimer;
            break;
        case MessageTypeTrackingStateEscalation:
            timer = self.trackingStateFeedbackEscalationTimer;
            break;
        default:
            break;
    }
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
    __weak typeof(self)weakSelf = self;
    timer =[NSTimer scheduledTimerWithTimeInterval:seconds repeats:NO block:^(NSTimer * _Nonnull timer) {
        [weakSelf showMessageWithText:text AutoHide:YES];
        [timer invalidate];
        timer = nil;
    }];
    switch (messageType) {
        case MessageTypeContentPlacement:
            self.contentPlacementMessageTimer = timer;
            break;
        case MessageTypeFocusSquare:
            self.focusSquareMessageTimer = timer;
            break;
        case MessageTypePlaneEstimation:
            self.planeEstimationMessageTimer = timer;
            break;
        case MessageTypeTrackingStateEscalation:
            self.trackingStateFeedbackEscalationTimer = timer;
            break;
        default:
            break;
    }
}
- (void)showTrackingQualityInfoForARCameraTrackingState:(ARCamera *)arCamera AutoHide:(BOOL)autoHide{
    ARCameraTrakingState *states = [ARCameraTrakingState cameraTrakingStateWithCamera:arCamera];
    
    [self showMessageWithText:states.presentationString AutoHide:autoHide];
    
}
- (void)escalateFeedbackForARCameraTrackingState:(ARCamera *)arCamera InSeconds:(NSTimeInterval)seconds{
    if (self.trackingStateFeedbackEscalationTimer != nil) {
        [self.trackingStateFeedbackEscalationTimer invalidate];
        self.trackingStateFeedbackEscalationTimer = nil;
    }
    self.trackingStateFeedbackEscalationTimer = [NSTimer scheduledTimerWithTimeInterval:seconds repeats:NO block:^(NSTimer * _Nonnull timer) {
        [self.trackingStateFeedbackEscalationTimer invalidate];
        self.trackingStateFeedbackEscalationTimer = nil;
        self.schedulingMessagesBlocked = YES;
        NSString *title = @"";
        NSString *message = @"";
        switch (arCamera.trackingState) {
            case ARTrackingStateNotAvailable:
                title = @"Tracking status: Not available.";
                message = @"Tracking status has been unavailable for an extended time. Try resetting the session.";
                break;
             case ARTrackingStateLimited:
                title = @"Tracking status: Limited.";
                switch (arCamera.trackingStateReason) {
                    case ARTrackingStateReasonExcessiveMotion:
                        message = @"Tracking status has been limited for an extended time.Try slowing down your movement, or reset the session.";
                        break;
                        case ARTrackingStateReasonInsufficientFeatures:
                        message = @"Tracking status has been limited for an extended time.Try pointing at a flat surface, or reset the session.";
                    default:
                        break;
                }
            default:
                break;
        }
        UIAlertAction *restartAction = [UIAlertAction actionWithTitle:@"Reset" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [self.viewController restartExperience:self];
            self.schedulingMessagesBlocked = NO;
        }];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            self.schedulingMessagesBlocked = NO;
        }];
        
        [self showAlertWithTitle:title Message:message Actions:@[restartAction,okAction]];
    }];
    
}
- (void)cancelScheduledMessageForType:(MessageType)messageType{
    NSTimer *timer;
    switch (messageType) {
        case MessageTypeContentPlacement:
            timer = self.contentPlacementMessageTimer;
            break;
        case MessageTypeFocusSquare:
            timer = self.focusSquareMessageTimer;
            break;
        case MessageTypePlaneEstimation:
            timer = self.planeEstimationMessageTimer;
            break;
        case MessageTypeTrackingStateEscalation:
            timer = self.trackingStateFeedbackEscalationTimer;
            break;
        default:
            break;
    }
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
}
- (void)cancelAllScheduledMessages{
    [self cancelScheduledMessageForType: MessageTypeTrackingStateEscalation];
    [self cancelScheduledMessageForType: MessageTypePlaneEstimation];
    [self cancelScheduledMessageForType: MessageTypeFocusSquare];
    [self cancelScheduledMessageForType: MessageTypeContentPlacement];
}
- (void)showAlertWithTitle:(NSString *)title Message:(NSString *)message Actions:(NSArray<UIAlertAction *>*)actions{
    self.alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    if (actions.count!=0) {
        for (UIAlertAction *action in actions) {
            [self.alertController addAction:action];
        }
    }else{
        [self.alertController addAction: [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    }
    [self.viewController presentViewController:self.alertController animated:YES completion:nil];
    
}
- (void)dismissPresentedAlert{
    [self.alertController dismissViewControllerAnimated:YES completion:nil];
    
}
- (void)blurBackground{
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle: UIBlurEffectStyleLight];
    UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc]initWithEffect:blurEffect];
    blurEffectView.frame = self.viewController.view.bounds;
    blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    blurEffectView.tag = self.blurEffectViewTag;
    [self.viewController.view addSubview:blurEffectView];
}
- (void)unblurBackground{
    for (UIView *sub in self.viewController.view.subviews) {
        if([sub isKindOfClass:[UIVisualEffectView class]]){
            if (sub.tag == self.blurEffectViewTag) {
                [sub removeFromSuperview];
            }
        }
    }
}

- (void)showHideMessageWithHide:(BOOL)hide Animated:(BOOL)animated{
    if (!animated) {
        self.viewController.messageLabel.hidden = hide;
        return;
    }
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.viewController.messageLabel.hidden = hide;
        [self updateMessagePanelVisibility];
    } completion:nil];
}
- (void)showHideDebugMessage:(BOOL)hide Animated:(BOOL)animated{
    if (!animated) {
        self.viewController.debugMessageLabel.hidden = hide;
        return;
    }
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.viewController.debugMessageLabel.hidden = hide;
        [self updateMessagePanelVisibility];
    } completion:nil];
    
}

- (void)updateMessagePanelVisibility{
    self.viewController.messagePanel.hidden = self.viewController.messageLabel.hidden &&self.viewController.debugMessageLabel.hidden&&self.viewController.featurePointCountLabel.hidden;
}
@end
