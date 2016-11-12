//
//  ViewController.m
//  GCMusicPlayView
//
//  Created by 宫城 on 16/11/2.
//  Copyright © 2016年 宫城. All rights reserved.
//

#import "ViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "NSString+GCMusicPlayView.h"
#import "CALayer+GCMusicPlayView.h"

#define DeviceWidth CGRectGetWidth([UIScreen mainScreen].bounds)
#define DeviceHeight CGRectGetHeight([UIScreen mainScreen].bounds)

#define kCoverHeight DeviceHeight*1/3
#define kPlayBarHeight 50
#define kMusicTitleFromHeight 25
#define kMusicTitleToHeight 50
#define kPlayTimeWidth 50
#define kPlayTimeHeight 25
#define kPlayTimeMarginXToCenter 45
#define kPlayTimeMarginYToCenter 15

typedef NS_ENUM(NSUInteger, playBarStatus) {
    show,
    hide
};

@interface ViewController () <CAAnimationDelegate>

@property (nonatomic, strong) UIImageView *musicCover;
@property (nonatomic, strong) UIView *playBar;
@property (nonatomic, strong) UILabel *musicTitle;
@property (nonatomic, strong) UILabel *currentPlayTime;
@property (nonatomic, strong) UILabel *musicPlayTime;
@property (nonatomic, strong) CAShapeLayer *playProgress;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUp];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)setUp {
    self.view.backgroundColor = [UIColor colorWithRed:30.0/255.0 green:32.0/255.0 blue:32.0/255.0 alpha:1.0];
    
    self.musicCover = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, DeviceWidth, kCoverHeight)];
    self.musicCover.image = [UIImage imageNamed:@"Maps"];
    self.musicCover.layer.masksToBounds = YES;
    [self.view addSubview:self.musicCover];
    
    self.playBar = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.musicCover.frame) - kPlayBarHeight, DeviceWidth, kPlayBarHeight)];
    self.playBar.backgroundColor = [[UIColor darkGrayColor] colorWithAlphaComponent:0.5];
    [self.view addSubview:self.playBar];
    
    self.musicTitle = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(self.playBar.frame) - kMusicTitleToHeight, DeviceWidth - 40, kMusicTitleFromHeight)];
    NSMutableAttributedString *song = [[NSMutableAttributedString alloc] initWithString:@"Maps" attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor], NSFontAttributeName: [UIFont systemFontOfSize:12]}];
    NSMutableAttributedString *author = [[NSMutableAttributedString alloc] initWithString:@" - Bruno Mars" attributes:@{NSForegroundColorAttributeName: [UIColor lightGrayColor], NSFontAttributeName: [UIFont systemFontOfSize:12]}];
    self.musicTitle.lineBreakMode = NSLineBreakByTruncatingTail;
    [song appendAttributedString:author];
    self.musicTitle.attributedText = song;
    [self.view addSubview:self.musicTitle];
    
    self.currentPlayTime = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(self.musicTitle.frame), [@"0:00" stringWidthWithFontSize:12], kPlayTimeHeight)];
    self.currentPlayTime.text = @"0:00";
    self.currentPlayTime.textColor = [UIColor lightGrayColor];
    self.currentPlayTime.font = [UIFont systemFontOfSize:12];
    [self.view addSubview:self.currentPlayTime];
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectMake(CGRectGetMaxX(self.currentPlayTime.frame) + 10, CGRectGetMaxY(self.musicTitle.frame) + kPlayTimeHeight/2, DeviceWidth/2, 1)];
    self.playProgress = [CAShapeLayer layer];
    self.playProgress.path = path.CGPath;
    self.playProgress.fillColor = [UIColor lightGrayColor].CGColor;//[UIColor colorWithRed:255.0/255.0 green:80.0/255.0 blue:80.0/255.0 alpha:1].CGColor;
    self.playProgress.strokeColor = [UIColor lightGrayColor].CGColor;
    self.playProgress.lineWidth = 1;
    [self.view.layer addSublayer:self.playProgress];
    
    self.musicPlayTime = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.currentPlayTime.frame) + 20 + DeviceWidth/2, CGRectGetMaxY(self.musicTitle.frame), [@"4:30" stringWidthWithFontSize:12], kPlayTimeHeight)];
    self.musicPlayTime.text = @"4:30";
    self.musicPlayTime.textColor = [UIColor lightGrayColor];
    self.musicPlayTime.font = [UIFont systemFontOfSize:12];
    [self.view addSubview:self.musicPlayTime];
    
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
    [self musicTitleAnimation];
    CGFloat xOffset = kPlayTimeMarginXToCenter + CGRectGetWidth(self.currentPlayTime.frame)/2;
    [self playTimeLabel:self.currentPlayTime addAnimationWithPositionXOffset:-xOffset];
    [self playTimeLabel:self.musicPlayTime addAnimationWithPositionXOffset:xOffset];
    [self progressAnimation];
}

#pragma mark - Cover Animation
- (void)coverAnimation {
    CABasicAnimation *positionDownAni = [CABasicAnimation animationWithKeyPath:@"position.y"];
    positionDownAni.toValue = @(DeviceHeight/2);

    CABasicAnimation *frameAni = [CABasicAnimation animationWithKeyPath:@"bounds"];
    frameAni.toValue = [NSValue valueWithCGRect:CGRectMake(0, 0, kCoverHeight, kCoverHeight)];
    
    CABasicAnimation *radiusAni = [CABasicAnimation animationWithKeyPath:@"cornerRadius"];
    radiusAni.fromValue = @(0);
    radiusAni.toValue = @(kCoverHeight/2);
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.animations = @[positionDownAni, frameAni, radiusAni];
    group.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    group.delegate = self;
    [group setValue:@"coverAnimation" forKey:@"ani"];
    
    [self.musicCover.layer gc_addAnimation:group forKey:nil];
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
        CGFloat opacity = status == show ? 0.5 : 0.0;
        self.playBar.backgroundColor = [[UIColor darkGrayColor] colorWithAlphaComponent:opacity];
    }];
}

#pragma mark - Music Title Aniamtion
- (void)musicTitleAnimation {
    CABasicAnimation *positionUpAni = [CABasicAnimation animationWithKeyPath:@"position.y"];
    positionUpAni.toValue = @(kMusicTitleToHeight/2 + 44);
    
    CABasicAnimation *frameAni = [CABasicAnimation animationWithKeyPath:@"bounds.size.height"];
    frameAni.toValue = @(kMusicTitleToHeight);
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.animations = @[positionUpAni, frameAni];

    [self.musicTitle.layer gc_addAnimation:group forKey:nil];
    self.musicTitle.layer.bounds = CGRectMake(0, 0, DeviceWidth - 40, kMusicTitleToHeight);
    
    [UIView animateWithDuration:0.3 animations:^{
        for (NSInteger i = 12; i <= 20; i++) {
            self.musicTitle.font = [UIFont systemFontOfSize:i];
        }
        self.musicTitle.textAlignment = NSTextAlignmentCenter;
    }];
}

#pragma mark - Music Play Time Aniamtion
- (void)playTimeLabel:(UILabel *)label addAnimationWithPositionXOffset:(CGFloat)positionXOffset {
    CABasicAnimation *positionAni = [CABasicAnimation animationWithKeyPath:@"position"];
    positionAni.toValue = [NSValue valueWithCGPoint:CGPointMake(DeviceWidth/2 + positionXOffset, DeviceHeight/2 + kCoverHeight/2 + kPlayTimeMarginYToCenter)];
    [label.layer gc_addAnimation:positionAni forKey:nil];
}

#pragma mark - Play Progress Aniamtion
- (void)progressAnimation {
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(DeviceWidth/2, DeviceHeight/2) radius:kCoverHeight/2 + 20 startAngle:M_PI*2/3 endAngle:M_PI/3 clockwise:YES];
    CABasicAnimation *pathAni = [CABasicAnimation animationWithKeyPath:@"path"];
    pathAni.toValue = (__bridge id _Nullable)(path.CGPath);
    [self.playProgress gc_addAnimation:pathAni forKey:nil];
    
    self.playProgress.fillColor = [UIColor clearColor].CGColor;
}

- (void)animationDidStop:(CAAnimation *)animation finished:(BOOL)flag {
    NSString *ani = [animation valueForKey:@"ani"];
    if ([ani isEqualToString:@"coverAnimation"]) {
        [self coverRotated];
    }
}

@end
