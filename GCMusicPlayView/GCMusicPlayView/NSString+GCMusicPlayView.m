//
//  NSString+GCMusicPlayView.m
//  GCMusicPlayView
//
//  Created by 宫城 on 16/11/9.
//  Copyright © 2016年 宫城. All rights reserved.
//

#import "NSString+GCMusicPlayView.h"

@implementation NSString (GCMusicPlayView)

- (CGFloat)stringWidthWithFontSize:(CGFloat)fontSize {
    return [self boundingRectWithSize:CGSizeMake(MAXFLOAT, 20) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:fontSize]} context:nil].size.width;
}

- (CGFloat)stringHeightWithFontSize:(CGFloat)fontSize {
    return [self boundingRectWithSize:CGSizeMake(20, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:fontSize]} context:nil].size.height;
}

@end
