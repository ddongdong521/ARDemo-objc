//
//  TextManager.h
//  ARDemo
//
//  Created by apple on 2017/8/7.
//  Copyright © 2017年 Charly. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ARViewController.h"

@interface TextManager : NSObject
@property (nonatomic,assign)BOOL schedulingMessagesBlocked;
@property (nonatomic,strong)UIAlertController *alertController;
@property (nonatomic,assign)NSInteger blurEffectViewTag;


typedef NS_ENUM(NSUInteger,MessageType){
    MessageTypeTrackingStateEscalation,
    MessageTypePlaneEstimation,
    MessageTypeContentPlacement,
    MessageTypeFocusSquare,
};

- (instancetype)initWithViewController:(ARViewController *)viewController;
- (void)showMessageWithText:(NSString *)text AutoHide:(BOOL)autoHide;
- (void)showDebugMessage:(NSString *)message;
- (void)scheduleMessageWithString:(NSString *)text InSeconds:(NSTimeInterval)seconds MessageType:(MessageType)messageType;
- (void)showTrackingQualityInfoForARCameraTrackingState:(ARCamera *)arCamera AutoHide:(BOOL)autoHide;
- (void)escalateFeedbackForARCameraTrackingState:(ARCamera *)arCamera InSeconds:(NSTimeInterval)seconds;
- (void)cancelScheduledMessageForType:(MessageType)messageType;
- (void)cancelAllScheduledMessages;
- (void)showAlertWithTitle:(NSString *)title Message:(NSString *)message Actions:(NSArray<UIAlertAction *>*)actions;
- (void)dismissPresentedAlert;
- (void)blurBackground;
- (void)unblurBackground;
@end
