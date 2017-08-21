//
//  NSMutableArray+Extension.m
//  ARDemo
//
//  Created by apple on 2017/7/27.
//  Copyright © 2017年 Charly. All rights reserved.
//

#import "NSMutableArray+Extension.h"

@implementation NSMutableArray (Extension)

- (void)keepLastWithElements:(NSInteger)elementsToKeep{
    if (self.count>elementsToKeep) {
        for (int i= 0 ; i<self.count-elementsToKeep; i++) {
            [self removeObjectAtIndex:0];
        }
    }
}
@end
