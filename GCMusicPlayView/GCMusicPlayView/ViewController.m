//
//  ViewController.m
//  GCMusicPlayView
//
//  Created by 宫城 on 16/11/2.
//  Copyright © 2016年 宫城. All rights reserved.
//

#import "ViewController.h"
#import <QuartzCore/QuartzCore.h>

#define DeviceWidth CGRectGetWidth([UIScreen mainScreen].bounds)
#define DeviceHeight CGRectGetHeight([UIScreen mainScreen].bounds)

#define kCoverHeight DeviceHeight*1/3
#define kPlayBarHeight 50

typedef NS_ENUM(NSUInteger, playBarStatus) {
    show,
    hide
};

@interface ViewController () <CAAnimationDelegate>

@property (nonatomic, strong) UIImageView *musicCover;
@property (nonatomic, strong) UIView *playBar;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUp];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)setUp {
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    self.musicCover = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, DeviceWidth, kCoverHeight)];
    self.musicCover.image = [UIImage imageNamed:@"Maps"];
    self.musicCover.layer.masksToBounds = YES;
    [self.view addSubview:self.musicCover];
    
    self.playBar = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.musicCover.frame) - kPlayBarHeight, DeviceWidth, kPlayBarHeight)];
    self.playBar.backgroundColor = [UIColor darkGrayColor];
    self.playBar.layer.opacity = 0.5;
    [self.view addSubview:self.playBar];

    UIButton *aniBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [aniBtn setFrame:CGRectMake(20, 300, 30, 30)];
    [aniBtn addTarget:self action:@selector(startPlay) forControlEvents:UIControlEventTouchUpInside];
    aniBtn.backgroundColor = [UIColor redColor];
    [self.view addSubview:aniBtn];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)startPlay {
    [self coverAnimation];
    [self playBarOpacityAnimationWithStatus:hide];
}

#pragma mark - Cover Animation
- (void)coverAnimation {
    NSLog(@"%s",__func__);
    CABasicAnimation *positionDownAni = [CABasicAnimation animationWithKeyPath:@"position.y"];
    positionDownAni.toValue = @(self.musicCover.layer.position.y + kCoverHeight - 30);
    positionDownAni.beginTime = 0;
    positionDownAni.duration = 0.3;

    CABasicAnimation *frameAni = [CABasicAnimation animationWithKeyPath:@"bounds"];
    frameAni.toValue = [NSValue valueWithCGRect:CGRectMake(0, 0, kCoverHeight, kCoverHeight)];
    frameAni.beginTime = 0;
    frameAni.duration = 0.3;
    
    CABasicAnimation *radiusAni = [CABasicAnimation animationWithKeyPath:@"cornerRadius"];
    radiusAni.fromValue = @(0);
    radiusAni.toValue = @(kCoverHeight/2);
    radiusAni.beginTime = 0;
    radiusAni.duration = 0.3;
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.animations = @[positionDownAni, frameAni, radiusAni];
    group.duration = radiusAni.beginTime + radiusAni.duration;
    group.removedOnCompletion = NO;
    group.fillMode = kCAFillModeForwards;
    group.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    group.delegate = self;
    [group setValue:@"coverAnimation" forKey:@"ani"];
    
    [self.musicCover.layer addAnimation:group forKey:nil];
}

- (void)coverRotated {
    CABasicAnimation *rotateAni = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotateAni.toValue = @(M_PI*2);
    rotateAni.repeatCount = HUGE_VALF;
    rotateAni.beginTime = 0;
    rotateAni.duration = 5;
    [self.musicCover.layer addAnimation:rotateAni forKey:nil];
}

#pragma mark - Play Bar Aniamtion
- (void)playBarOpacityAnimationWithStatus:(playBarStatus)status {
    [UIView animateWithDuration:0.1 animations:^{
        CGFloat opacity = status == show ? 1.0 : 0.0;
        self.playBar.layer.opacity = opacity;
    }];
}

- (void)animationDidStop:(CAAnimation *)animation finished:(BOOL)flag {
    NSString *ani = [animation valueForKey:@"ani"];
    if ([ani isEqualToString:@"coverAnimation"]) {
        [self coverRotated];
    }
}

@end
