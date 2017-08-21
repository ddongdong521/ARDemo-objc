//
//  ARCameraTrakingState.h
//  ARDemo
//
//  Created by apple on 2017/8/4.
//  Copyright © 2017年 Charly. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ARKit/ARKit.h>

@interface ARCameraTrakingState : NSObject

@property (nonatomic,strong)NSString *presentationString;
@property (nonatomic,strong)ARCamera *camera;


+ (instancetype)cameraTrakingStateWithCamera:(ARCamera *)camera;
@end
