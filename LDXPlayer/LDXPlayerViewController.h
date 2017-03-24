//
//  LDXPlayerViewController.h
//  LDXPlayer
//
//  Created by bmd on 2017/3/23.
//  Copyright © 2017年 刘东旭. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "AAPLPlayerView.h"

@interface LDXPlayerViewController : UIViewController

@property (readonly) AVPlayer *player;
@property AVURLAsset *asset;

@property CMTime currentTime;
@property (readonly) CMTime duration;
@property float rate;
@property (nonatomic, strong) NSURL *movieURL;
@property (nonatomic, strong) UIView *superView;
@property (nonatomic, assign) CGRect originRect;


+ (instancetype) playerController;

@end
