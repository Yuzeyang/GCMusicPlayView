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
#import "GCPlayButton.h"

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
#define kPlayButtonWidth 40

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
@property (nonatomic, strong) GCPlayButton *playButton;

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
    
    self.musicTitle = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMinY(self.playBar.frame), DeviceWidth/2, kMusicTitleFromHeight)];
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
    
    self.playButton = [[GCPlayButton alloc] initWithFrame:CGRectMake(DeviceWidth - kPlayButtonWidth - 15, CGRectGetMaxY(self.playBar.frame) - kPlayButtonWidth/2, kPlayButtonWidth, kPlayButtonWidth)];
    __weak __typeof(self)weakSelf = self;
    self.playButton.playHanlder = ^() {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf startPlay];
    };
    self.playButton.suspendedHanlder = ^() {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf stopPlay];
    };
    [self.view addSubview:self.playButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)startPlay {
    [self coverAnimationWithPositionY:DeviceHeight/2 bounds:CGRectMake(0, 0, kCoverHeight, kCoverHeight) cornerRadius:kCoverHeight/2 keyValue:@"coverPlayAnimation"];
    [self playBarOpacityAnimationWithStatus:hide];
    [self musicTitleAnimationWithPosition:CGPointMake(DeviceWidth/2, kMusicTitleToHeight/2 + 44) height:kMusicTitleToHeight bounds:CGRectMake(0, 0, DeviceWidth/2, kMusicTitleToHeight) fromFontSize:12 toFontSize:20 textAlignment:NSTextAlignmentCenter];
    CGFloat xOffset = kPlayTimeMarginXToCenter + CGRectGetWidth(self.currentPlayTime.frame)/2;
    [self playTimeLabel:self.currentPlayTime addAnimationWithPosition:CGPointMake(DeviceWidth/2 - xOffset, DeviceHeight/2 + kCoverHeight/2 + kPlayTimeMarginYToCenter)];
    [self playTimeLabel:self.musicPlayTime addAnimationWithPosition:CGPointMake(DeviceWidth/2 + xOffset, DeviceHeight/2 + kCoverHeight/2 + kPlayTimeMarginYToCenter)];
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(DeviceWidth/2, DeviceHeight/2) radius:kCoverHeight/2 + 20 startAngle:M_PI*2/3 endAngle:M_PI/3 clockwise:YES];
    [self progressAnimationWithPath:path];
    self.playProgress.fillColor = [UIColor clearColor].CGColor;
    [self playButtonAnimationToCenter:CGPointMake(DeviceWidth/2, DeviceHeight/2)];
}

- (void)stopPlay {
    
    NSLog(@"%lf",[(NSNumber *)[self.musicCover.layer valueForKeyPath:@"transform.rotation.z"] floatValue]);
    [self coverAnimationWithPositionY:kCoverHeight/2 bounds:CGRectMake(0, 0, DeviceWidth, kCoverHeight) cornerRadius:0 keyValue:@"coverSuspendedAnimation"];
//    [self.musicCover.layer convertTime:CACurrentMediaTime() fromLayer:nil];
    [self coverRotatedToAngle:0 duration:0.3];
    [self playBarOpacityAnimationWithStatus:show];
    [self musicTitleAnimationWithPosition:CGPointMake(DeviceWidth/4 + 20, CGRectGetMinY(self.playBar.frame) + kMusicTitleFromHeight/2) height:kMusicTitleFromHeight bounds:CGRectMake(0, 0, DeviceWidth/2, kMusicTitleFromHeight) fromFontSize:20 toFontSize:12 textAlignment:NSTextAlignmentLeft];
    [self playTimeLabel:self.currentPlayTime addAnimationWithPosition:self.currentPlayTime.layer.position];
    [self playTimeLabel:self.musicPlayTime addAnimationWithPosition:self.musicPlayTime.layer.position];
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectMake(CGRectGetMaxX(self.currentPlayTime.frame) + 10, CGRectGetMaxY(self.musicTitle.frame) + kPlayTimeHeight/2, DeviceWidth/2, 1)];
    [self progressAnimationWithPath:path];
    self.playProgress.fillColor = [UIColor lightGrayColor].CGColor;//[UIColor colorWithRed:255.0/255.0 green:80.0/255.0 blue:80.0/255.0 alpha:1].CGColor;
    self.playProgress.strokeColor = [UIColor lightGrayColor].CGColor;
    [self playButtonAnimationToCenter:CGPointMake(DeviceWidth - kPlayButtonWidth/2 - 15, CGRectGetMaxY(self.playBar.frame))];
}

#pragma mark - Cover Animation
- (void)coverAnimationWithPositionY:(CGFloat)positionY bounds:(CGRect)bounds cornerRadius:(CGFloat)cornerRadius keyValue:(NSString *)value {
    CABasicAnimation *positionDownAni = [CABasicAnimation animationWithKeyPath:@"position.y"];
    positionDownAni.toValue = @(positionY);
    
    CABasicAnimation *frameAni = [CABasicAnimation animationWithKeyPath:@"bounds"];
    frameAni.toValue = [NSValue valueWithCGRect:bounds];
    
    CABasicAnimation *radiusAni = [CABasicAnimation animationWithKeyPath:@"cornerRadius"];
    radiusAni.toValue = @(cornerRadius);
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.animations = @[positionDownAni, frameAni, radiusAni];
    group.delegate = self;
    [group setValue:value forKey:@"ani"];
    
    [self.musicCover.layer gc_addAnimation:group forKey:nil];
}

- (void)coverRotatedToAngle:(CGFloat)angle duration:(CGFloat)duration {
    CABasicAnimation *rotateAni = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotateAni.toValue = @(angle);
    if (angle == M_PI*2) {
        rotateAni.delegate = self;
        [rotateAni setValue:@"coverRotated" forKey:@"ani"];
    } else if (angle != 0) {
        rotateAni.repeatCount = HUGE_VALF;
        
    }
    rotateAni.beginTime = 0;
    rotateAni.duration = duration;
    
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
- (void)musicTitleAnimationWithPosition:(CGPoint)position height:(CGFloat)height bounds:(CGRect)bounds fromFontSize:(CGFloat)fromFontSize toFontSize:(CGFloat)toFontSize textAlignment:(NSTextAlignment)textAlignment {
    CABasicAnimation *positionAni = [CABasicAnimation animationWithKeyPath:@"position"];
    positionAni.toValue = [NSValue valueWithCGPoint:position];
    
    CABasicAnimation *frameAni = [CABasicAnimation animationWithKeyPath:@"bounds.size.height"];
    frameAni.toValue = @(height);
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.animations = @[positionAni, frameAni];
    
    [self.musicTitle.layer gc_addAnimation:group forKey:nil];
    self.musicTitle.layer.bounds = bounds;
    
    [UIView animateWithDuration:0.3 animations:^{
        if (fromFontSize <= toFontSize) {
            for (NSInteger i = fromFontSize; i <= toFontSize; i++) {
                self.musicTitle.font = [UIFont systemFontOfSize:i];
            }
        } else {
            for (NSInteger i = fromFontSize; i >= toFontSize; i--) {
                self.musicTitle.font = [UIFont systemFontOfSize:i];
            }
        }
        self.musicTitle.textAlignment = textAlignment;
    }];
}

#pragma mark - Music Play Time Aniamtion
- (void)playTimeLabel:(UILabel *)label addAnimationWithPosition:(CGPoint)position {
    CABasicAnimation *positionAni = [CABasicAnimation animationWithKeyPath:@"position"];
    positionAni.toValue = [NSValue valueWithCGPoint:position];
    [label.layer gc_addAnimation:positionAni forKey:nil];
}

#pragma mark - Play Progress Aniamtion
- (void)progressAnimationWithPath:(UIBezierPath *)path {
    CABasicAnimation *pathAni = [CABasicAnimation animationWithKeyPath:@"path"];
    pathAni.toValue = (__bridge id _Nullable)(path.CGPath);
    [self.playProgress gc_addAnimation:pathAni forKey:nil];
}

#pragma mark - Play Button Animation
- (void)playButtonAnimationToCenter:(CGPoint)center {
    [UIView animateWithDuration:0.3 animations:^{
        [self.playButton setCenter:center];
    }];
}

- (void)animationDidStop:(CAAnimation *)animation finished:(BOOL)flag {
    NSString *ani = [animation valueForKey:@"ani"];
    if ([ani isEqualToString:@"coverPlayAnimation"]) {
        [self coverRotatedToAngle:M_PI*2 duration:5];
    } else if ([ani isEqualToString:@"coverSuspendedAnimation"]) {
//        [self.musicCover.layer removeAllAnimations];
//        self.musicCover.layer.transform = CATransform3DIdentity;
//        [self coverRotatedToAngle:0 duration:0.3];
        [self.musicCover.layer removeAllAnimations];
    } else if ([ani isEqualToString:@"coverRotated"]) {
        
        [self.musicCover.layer removeAllAnimations];
    }
}

@end
