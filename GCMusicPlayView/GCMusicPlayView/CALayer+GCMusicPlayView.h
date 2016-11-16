//
//  CALayer+GCMusicPlayView.h
//  GCMusicPlayView
//
//  Created by 宫城 on 2016/11/10.
//  Copyright © 2016年 宫城. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface CALayer (GCMusicPlayView)

- (void)gc_addAnimation:(CAAnimation *)anim forKey:(NSString *)key withDuration:(CGFloat)duration;
- (void)gc_addAnimation:(CAAnimation *)anim forKey:(NSString *)key;

@end
