//
//  LDXPlayerProtocol.h
//  LDXPlayer
//
//  Created by bmd on 2017/3/23.
//  Copyright © 2017年 刘东旭. All rights reserved.
//

#ifndef LDXPlayerProtocol_h
#define LDXPlayerProtocol_h
@class LDXPlayerViewController;

@protocol LDXPlayerDelegate <NSObject>

@optional
//要有这三个控件，来控制播放、暂停、进度、全屏
@property (nonatomic, strong) UISlider *slider;
@property (nonatomic, strong) UIButton *playOrButton;
@property (nonatomic, strong) UIButton *fullButton;

/**
 *  slider的值(0~总秒数),每秒调用30次,也是当前播放的秒数
 */
- (void)ldxPlayer:(LDXPlayerViewController *)player timeSliderValue:(CGFloat)value;
/**
 *  视频总长度
 */
- (void)ldxPlayer:(LDXPlayerViewController *)player durationSeconds:(double)seconds;

@end

#endif /* LDXPlayerProtocol_h */
