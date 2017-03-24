//
//  LDXPlayerBottom.m
//  LDXPlayer
//
//  Created by bmd on 2017/3/23.
//  Copyright © 2017年 刘东旭. All rights reserved.
//

#import "LDXPlayerBottom.h"
#import <AVFoundation/AVFoundation.h>
#import "LDXPlayerViewController.h"

@interface LDXPlayerBottom ()

@end

@implementation LDXPlayerBottom

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1];
        self.slider = [[UISlider alloc] initWithFrame:CGRectZero];
        [self addSubview:self.slider];
        self.playOrButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [self.playOrButton setImage:[UIImage imageNamed:@"PauseButton"] forState:UIControlStateNormal];
        [self.playOrButton setImage:[UIImage imageNamed:@"PlayButton"] forState:UIControlStateSelected];
        [self addSubview:self.playOrButton];
        self.fullButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [self.fullButton setImage:[UIImage imageNamed:@"player_half"] forState:UIControlStateNormal];
        [self.fullButton setImage:[UIImage imageNamed:@"player_full"] forState:UIControlStateSelected];
        [self addSubview:self.fullButton];
        self.curentTime = [[UILabel alloc] initWithFrame:CGRectZero];
        self.curentTime.textColor = [UIColor whiteColor];
        self.curentTime.textAlignment = NSTextAlignmentCenter;
        self.curentTime.font = [UIFont systemFontOfSize:11.0f];
        self.curentTime.text = @"00:00";
        [self addSubview:self.curentTime];
        self.totalTime = [[UILabel alloc] initWithFrame:CGRectZero];
        self.totalTime.textColor = [UIColor whiteColor];
        self.totalTime.textAlignment = NSTextAlignmentCenter;
        self.totalTime.font = [UIFont systemFontOfSize:11.0f];
        [self addSubview:self.totalTime];
    }
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    self.playOrButton.frame = CGRectMake(0, 0, 44, 44);
    self.curentTime.frame = CGRectMake(52, 0, 44, 44);
    self.slider.frame = CGRectMake(52+44+8, 15, self.frame.size.width-104-88-32, 14);
    self.totalTime.frame = CGRectMake(self.frame.size.width-44-8-44-8, 0, 44, 44);
    self.fullButton.frame = CGRectMake(self.frame.size.width-44, 0, 44, 44);
}

- (void)ldxPlayer:(LDXPlayerViewController *)player timeSliderValue:(CGFloat)value {
    self.slider.value = value;
    int wholeMinutes = (int)trunc(value / 60);
    self.curentTime.text = [NSString stringWithFormat:@"%d:%02d", wholeMinutes, (int)trunc(value) - wholeMinutes * 60];
}
- (void)ldxPlayer:(LDXPlayerViewController *)player durationSeconds:(double)seconds {
    self.slider.maximumValue =seconds;
    int wholeMinutes = (int)trunc(seconds / 60);
    self.totalTime.text = [NSString stringWithFormat:@"%d:%02d", wholeMinutes, (int)trunc(seconds) - wholeMinutes * 60];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
