//
//  CALayer+GCMusicPlayView.m
//  GCMusicPlayView
//
//  Created by 宫城 on 2016/11/10.
//  Copyright © 2016年 宫城. All rights reserved.
//

#import "CALayer+GCMusicPlayView.h"

@implementation CALayer (GCMusicPlayView)

- (void)gc_addAnimation:(CAAnimation *)anim forKey:(NSString *)key {
    anim.beginTime = 0;
    anim.duration = 0.3;
    anim.removedOnCompletion = NO;
    anim.fillMode = kCAFillModeForwards;
    
    [self addAnimation:anim forKey:key];
}

@end
