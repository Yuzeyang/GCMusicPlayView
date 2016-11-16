//
//  CALayer+GCMusicPlayView.m
//  GCMusicPlayView
//
//  Created by 宫城 on 2016/11/10.
//  Copyright © 2016年 宫城. All rights reserved.
//

#import "CALayer+GCMusicPlayView.h"

@implementation CALayer (GCMusicPlayView)

- (void)gc_addAnimation:(CAAnimation *)anim forKey:(NSString *)key withDuration:(CGFloat)duration {
    anim.beginTime = 0;
    anim.duration = duration;
    anim.removedOnCompletion = NO;
    anim.fillMode = kCAFillModeForwards;
    
    [self addAnimation:anim forKey:key];
}

- (void)gc_addAnimation:(CAAnimation *)anim forKey:(NSString *)key {
    [self gc_addAnimation:anim forKey:key withDuration:0.3];
}

@end
