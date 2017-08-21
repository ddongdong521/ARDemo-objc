//
//  VirtualObjectSelectionViewController.h
//  ARDemo
//
//  Created by apple on 2017/8/4.
//  Copyright © 2017年 Charly. All rights reserved.
//

#import <UIKit/UIKit.h>
@class VirtualObjectSelectionViewController;
@protocol VirtualObjectSelectionViewControllerDelegate<NSObject>
- (void)virtualObjectSelectionViewController:(VirtualObjectSelectionViewController *)controller DidSelectedObjectAtIndexPath:(NSInteger)indexpath;
- (void)virtualObjectSelectionViewControllerDidDeselectObject:(VirtualObjectSelectionViewController *)controller;

@end

@interface VirtualObjectSelectionViewController : UIViewController


@property (nonatomic,weak)id<VirtualObjectSelectionViewControllerDelegate>delegate;

- (instancetype)initWithSize:(CGSize)size;
@end
