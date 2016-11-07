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

@interface ViewController () <CAAnimationDelegate>

@property (nonatomic, strong) UIImageView *musicCover;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUp];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)setUp {
    self.view.backgroundColor = [UIColor lightGrayColor];
//    [UIScreen mainScreen].bounds
    
    self.musicCover = [[UIImageView alloc] initWithFrame:CGRectMake(0, 20, DeviceWidth, kCoverHeight)];
//    self.musicCover.backgroundColor = [UIColor orangeColor];
    self.musicCover.image = [UIImage imageNamed:@"Maps"];
    self.musicCover.layer.masksToBounds = YES;
    [self.view addSubview:self.musicCover];

    UIButton *aniBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [aniBtn setFrame:CGRectMake(20, 300, 30, 30)];
    [aniBtn addTarget:self action:@selector(coverAnimation) forControlEvents:UIControlEventTouchUpInside];
    aniBtn.backgroundColor = [UIColor redColor];
    [self.view addSubview:aniBtn];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)coverAnimation {
    NSLog(@"%s",__func__);
    CABasicAnimation *positionDownAni = [CABasicAnimation animationWithKeyPath:@"position.y"];
    positionDownAni.toValue = @(self.musicCover.layer.position.y + kCoverHeight - 50);
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

- (void)animationDidStop:(CAAnimation *)animation finished:(BOOL)flag {
    NSString *ani = [animation valueForKey:@"ani"];
    if ([ani isEqualToString:@"coverAnimation"]) {
        [self coverRotated];
    }
}

@end
