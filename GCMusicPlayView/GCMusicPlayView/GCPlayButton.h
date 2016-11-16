//
//  GCPlayButton.h
//  GCMusicPlayView
//
//  Created by 宫城 on 2016/11/12.
//  Copyright © 2016年 宫城. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GCPlayButton : UIView

@property (nonatomic, copy) void(^playHanlder)();
@property (nonatomic, copy) void(^suspendedHanlder)();

@end
