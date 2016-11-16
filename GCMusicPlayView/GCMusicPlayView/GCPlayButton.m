//
//  GCPlayButton.m
//  GCMusicPlayView
//
//  Created by 宫城 on 2016/11/12.
//  Copyright © 2016年 宫城. All rights reserved.
//

#import "GCPlayButton.h"
#import "CALayer+GCMusicPlayView.h"

#define kSideLength CGRectGetWidth(self.frame)/2

typedef NS_ENUM(NSUInteger, PlayState) {
    Play,
    Suspose,
};

@interface GCPlayButton () <CAAnimationDelegate>

@property (nonatomic, strong) CAShapeLayer *playShapeLayer;
@property (nonatomic, strong) CAShapeLayer *suspendedShapeLayer;
@property (nonatomic, assign) BOOL isPlaying;
@property (nonatomic, strong) UITapGestureRecognizer *tapGes;

@end

@implementation GCPlayButton

- (instancetype)initWithFrame:(CGRect)frame {
    CGFloat radius = CGRectGetHeight(frame) >= CGRectGetWidth(frame) ? CGRectGetWidth(frame) : CGRectGetHeight(frame);
    self = [super initWithFrame:CGRectMake(CGRectGetMinX(frame), CGRectGetMinY(frame), radius, radius)];
    if (self) {
        self.layer.cornerRadius = radius/2;
        self.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:80.0/255.0 blue:80.0/255.0 alpha:1];
        self.isPlaying = NO;
        [self setUpInitState];
        [self addTapGesture];
    }
    return self;
}

- (void)setUpInitState {
    self.playShapeLayer = [CAShapeLayer layer];
    self.playShapeLayer.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
    self.playShapeLayer.path = [self fromPath].CGPath;
    self.playShapeLayer.fillColor = [UIColor whiteColor].CGColor;
    
    [self.layer addSublayer:self.playShapeLayer];
    
    self.suspendedShapeLayer = [CAShapeLayer layer];
    self.suspendedShapeLayer.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
    self.suspendedShapeLayer.path = [self toPath].CGPath;
    self.suspendedShapeLayer.strokeColor = [UIColor whiteColor].CGColor;
    self.suspendedShapeLayer.lineWidth = 4;
    self.suspendedShapeLayer.opacity = 0.0;
    
    [self.layer addSublayer:self.suspendedShapeLayer];
}

- (void)addTapGesture {
    self.tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(buttonTapped)];
    [self addGestureRecognizer:self.tapGes];
}

- (void)buttonTapped {
    self.tapGes.enabled = NO;
    if (!self.isPlaying) {
        [self playAniOne];
    } else {
        [self suspendedAniOne];
    }
}

- (void)playAniOne {
    CABasicAnimation *rotateAni = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotateAni.toValue = @(M_PI/2);
    
    CABasicAnimation *opacityAni = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAni.toValue = @(0.0);
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.animations = @[rotateAni, opacityAni];
    group.delegate = self;
    [group setValue:@"playAniOne" forKey:@"ani"];
    [self.playShapeLayer gc_addAnimation:group forKey:nil withDuration:0.15];
}

- (void)playAniTwo {
    CABasicAnimation *opacityAni = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAni.toValue = @(1.0);
    opacityAni.delegate = self;
    [opacityAni setValue:@"playAniTwo" forKey:@"ani"];
    [self.suspendedShapeLayer gc_addAnimation:opacityAni forKey:nil withDuration:0.15];
}

- (void)suspendedAniOne {
    CABasicAnimation *opacityAni = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAni.toValue = @(0.0);
    opacityAni.delegate = self;
    [opacityAni setValue:@"suspendedAniOne" forKey:@"ani"];
    [self.suspendedShapeLayer gc_addAnimation:opacityAni forKey:nil withDuration:0.15];
}

- (void)suspendedAniTwo {
    CABasicAnimation *rotateAni = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotateAni.toValue = @(0);

    CABasicAnimation *opacityAni = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAni.toValue = @(1.0);

    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.animations = @[rotateAni, opacityAni];
    group.delegate = self;
    [group setValue:@"suspendedAniTwo" forKey:@"ani"];
    [self.playShapeLayer gc_addAnimation:group forKey:nil withDuration:0.15];
}

- (UIBezierPath *)fromPath {
    UIBezierPath *fromPath = [UIBezierPath bezierPath];
    [fromPath moveToPoint:CGPointMake(kSideLength - kSideLength/2/pow(3, 0.5), kSideLength/2)];
    [fromPath addLineToPoint:CGPointMake(kSideLength - kSideLength/2/pow(3, 0.5) + kSideLength/2*pow(3, 0.5), kSideLength)];
    [fromPath addLineToPoint:CGPointMake(kSideLength - kSideLength/2/pow(3, 0.5), kSideLength*3/2)];
    
    return fromPath;
}

- (UIBezierPath *)byPath {
    UIBezierPath *byPath = [UIBezierPath bezierPath];
    [byPath moveToPoint:CGPointMake(kSideLength/2, kSideLength - kSideLength/2/pow(3, 0.5))];
    [byPath addLineToPoint:CGPointMake(kSideLength, kSideLength + kSideLength/pow(3, 0.5))];
    [byPath addLineToPoint:CGPointMake(kSideLength*3/2, kSideLength - kSideLength/2/pow(3, 0.5))];
    
    return byPath;
}

- (UIBezierPath *)toPath {
    UIBezierPath *path1 = [UIBezierPath bezierPath];
    [path1 moveToPoint:CGPointMake(kSideLength - 5, kSideLength/2)];
    [path1 addLineToPoint:CGPointMake(kSideLength - 5, kSideLength*3/2)];
    
    UIBezierPath *path2 = [UIBezierPath bezierPath];
    [path2 moveToPoint:CGPointMake(kSideLength + 5, kSideLength/2)];
    [path2 addLineToPoint:CGPointMake(kSideLength + 5, kSideLength*3/2)];
    
    [path1 appendPath:path2];
    
    return path1;
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    NSString *ani = [anim valueForKey:@"ani"];
    if ([ani isEqualToString:@"playAniOne"]) {
        [self playAniTwo];
    } else if ([ani isEqualToString:@"playAniTwo"]) {
        self.isPlaying = YES;
        self.tapGes.enabled = YES;
    } else if ([ani isEqualToString:@"suspendedAniOne"]) {
        [self suspendedAniTwo];
    } else if ([ani isEqualToString:@"suspendedAniTwo"]) {
        self.isPlaying = NO;
        self.tapGes.enabled = YES;
    }
}

@end
