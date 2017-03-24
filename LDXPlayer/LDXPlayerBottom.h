//
//  LDXPlayerBottom.h
//  LDXPlayer
//
//  Created by bmd on 2017/3/23.
//  Copyright © 2017年 刘东旭. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LDXPlayerProtocol.h"

@interface LDXPlayerBottom : UIView <LDXPlayerDelegate>

@property (nonatomic, strong) UISlider *slider;
@property (nonatomic, strong) UIButton *playOrButton;
@property (nonatomic, strong) UIButton *fullButton;
@property (nonatomic, strong) UILabel *curentTime;
@property (nonatomic, strong) UILabel *totalTime;

@end
