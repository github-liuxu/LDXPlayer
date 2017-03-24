//
//  LDXPlayerViewController.m
//  LDXPlayer
//
//  Created by bmd on 2017/3/23.
//  Copyright © 2017年 刘东旭. All rights reserved.
//

@import Foundation;
@import AVFoundation;
@import CoreMedia.CMTime;
#import "LDXPlayerViewController.h"
#import "AAPLPlayerView.h"
#import "LDXPlayerBottom.h"


// Private properties
@interface LDXPlayerViewController ()
{
    AVPlayer *_player;
    AVURLAsset *_asset;
    id<NSObject> _timeObserverToken;
    AVPlayerItem *_playerItem;
    
    UIButton *playOrPauseButton;
    UIButton *fullButton;
    
    CGFloat windowLevel;
    BOOL isHiden;//导航栏是否显示
}

@property AVPlayerItem *playerItem;
@property (weak, nonatomic) IBOutlet AAPLPlayerView *playerView;

@property (readonly) AVPlayerLayer *playerLayer;
@property (nonatomic, strong) LDXPlayerBottom *playerBottom;

@end

@implementation LDXPlayerViewController

/*
	KVO context used to differentiate KVO callbacks for this class versus other
	classes in its class hierarchy.
 */
static int AAPLPlayerViewControllerKVOContext = 0;

+ (instancetype)playerController {
    return [[LDXPlayerViewController alloc] initWithNibName:@"LDXPlayerViewController" bundle:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.playerBottom = [[LDXPlayerBottom alloc] init];
    [self.view addSubview:self.playerBottom];
    playOrPauseButton = [self.playerBottom valueForKey:@"playOrButton"];
    [playOrPauseButton addTarget:self action:@selector(playPauseButtonWasPressed:) forControlEvents:UIControlEventTouchUpInside];
    fullButton = [self.playerBottom valueForKey:@"fullButton"];
    [fullButton addTarget:self action:@selector(fullClick:) forControlEvents:UIControlEventTouchUpInside];
    UISlider *slider = [self.playerBottom valueForKey:@"slider"];
    [slider addTarget:self action:@selector(timeSliderDidChange:) forControlEvents:UIControlEventValueChanged];
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    windowLevel = window.windowLevel;
    isHiden = self.navigationController.isNavigationBarHidden;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    /*
     Update the UI when these player properties change.
     
     Use the context parameter to distinguish KVO for our particular observers and not
     those destined for a subclass that also happens to be observing these properties.
     */
    [self addObserver:self forKeyPath:@"asset" options:NSKeyValueObservingOptionNew context:&AAPLPlayerViewControllerKVOContext];
    [self addObserver:self forKeyPath:@"player.currentItem.duration" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial context:&AAPLPlayerViewControllerKVOContext];
    [self addObserver:self forKeyPath:@"player.rate" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial context:&AAPLPlayerViewControllerKVOContext];
    [self addObserver:self forKeyPath:@"player.currentItem.status" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial context:&AAPLPlayerViewControllerKVOContext];
    
    self.playerView.playerLayer.player = self.player;
    
    self.asset = [AVURLAsset assetWithURL:self.movieURL];
    
    // Use a weak self variable to avoid a retain cycle in the block.
    LDXPlayerViewController __weak *weakSelf = self;
    _timeObserverToken = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 30) queue:dispatch_get_main_queue() usingBlock:
                          ^(CMTime time) {
                              if ([weakSelf.playerBottom respondsToSelector:@selector(ldxPlayer: timeSliderValue:)]) {
                                  [weakSelf.playerBottom ldxPlayer:weakSelf timeSliderValue:CMTimeGetSeconds(time)];
                              }
                          }];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    if (_timeObserverToken) {
        [self.player removeTimeObserver:_timeObserverToken];
        _timeObserverToken = nil;
    }
    
    [self.player pause];
    
    [self removeObserver:self forKeyPath:@"asset" context:&AAPLPlayerViewControllerKVOContext];
    [self removeObserver:self forKeyPath:@"player.currentItem.duration" context:&AAPLPlayerViewControllerKVOContext];
    [self removeObserver:self forKeyPath:@"player.rate" context:&AAPLPlayerViewControllerKVOContext];
    [self removeObserver:self forKeyPath:@"player.currentItem.status" context:&AAPLPlayerViewControllerKVOContext];
}


// layoutSubviews

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.playerView.frame = self.view.bounds;
    self.playerBottom.frame = CGRectMake(0, self.view.bounds.size.height-44, self.view.bounds.size.width, 44);
}

// MARK: - Properties

// Will attempt load and test these asset keys before playing
+ (NSArray *)assetKeysRequiredToPlay {
    return @[ @"playable", @"hasProtectedContent" ];
}

- (AVPlayer *)player {
    if (!_player) {
        _player = [[AVPlayer alloc] init];
    }
    return _player;
}

- (CMTime)currentTime {
    return self.player.currentTime;
}
- (void)setCurrentTime:(CMTime)newCurrentTime {
    [self.player seekToTime:newCurrentTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}

- (CMTime)duration {
    return self.player.currentItem ? self.player.currentItem.duration : kCMTimeZero;
}

- (float)rate {
    return self.player.rate;
}
- (void)setRate:(float)newRate {
    self.player.rate = newRate;
}

- (AVPlayerLayer *)playerLayer {
    return self.playerView.playerLayer;
}

- (AVPlayerItem *)playerItem {
    return _playerItem;
}

- (void)setPlayerItem:(AVPlayerItem *)newPlayerItem {
    if (_playerItem != newPlayerItem) {
        
        _playerItem = newPlayerItem;
        
        // If needed, configure player item here before associating it with a player
        // (example: adding outputs, setting text style rules, selecting media options)
        [self.player replaceCurrentItemWithPlayerItem:_playerItem];
    }
}

// MARK: - Asset Loading

- (void)asynchronouslyLoadURLAsset:(AVURLAsset *)newAsset {
    
    /*
     Using AVAsset now runs the risk of blocking the current thread
     (the main UI thread) whilst I/O happens to populate the
     properties. It's prudent to defer our work until the properties
     we need have been loaded.
     */
    [newAsset loadValuesAsynchronouslyForKeys:LDXPlayerViewController.assetKeysRequiredToPlay completionHandler:^{
        
        /*
         The asset invokes its completion handler on an arbitrary queue.
         To avoid multiple threads using our internal state at the same time
         we'll elect to use the main thread at all times, let's dispatch
         our handler to the main queue.
         */
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (newAsset != self.asset) {
                /*
                 self.asset has already changed! No point continuing because
                 another newAsset will come along in a moment.
                 */
                return;
            }
            
            /*
             Test whether the values of each of the keys we need have been
             successfully loaded.
             */
            for (NSString *key in self.class.assetKeysRequiredToPlay) {
                NSError *error = nil;
                if ([newAsset statusOfValueForKey:key error:&error] == AVKeyValueStatusFailed) {
                    
                    NSString *message = [NSString localizedStringWithFormat:NSLocalizedString(@"error.asset_key_%@_failed.description", @"Can't use this AVAsset because one of it's keys failed to load"), key];
                    
                    [self handleErrorWithMessage:message error:error];
                    
                    return;
                }
            }
            
            // We can't play this asset.
            if (!newAsset.playable || newAsset.hasProtectedContent) {
                NSString *message = NSLocalizedString(@"error.asset_not_playable.description", @"Can't use this AVAsset because it isn't playable or has protected content");
                
                [self handleErrorWithMessage:message error:nil];
                
                return;
            }
            
            /*
             We can play this asset. Create a new AVPlayerItem and make it
             our player's current item.
             */
            self.playerItem = [AVPlayerItem playerItemWithAsset:newAsset];
        });
    }];
}

// MARK: - KV Observation

// Update our UI when player or player.currentItem changes
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if (context != &AAPLPlayerViewControllerKVOContext) {
        // KVO isn't for us.
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        return;
    }
    
    if ([keyPath isEqualToString:@"asset"]) {
        if (self.asset) {
            [self asynchronouslyLoadURLAsset:self.asset];
        }
    }
    else if ([keyPath isEqualToString:@"player.currentItem.duration"]) {
        
        // Update timeSlider and enable/disable controls when duration > 0.0
        
        // Handle NSNull value for NSKeyValueChangeNewKey, i.e. when player.currentItem is nil
        NSValue *newDurationAsValue = change[NSKeyValueChangeNewKey];
        CMTime newDuration = [newDurationAsValue isKindOfClass:[NSValue class]] ? newDurationAsValue.CMTimeValue : kCMTimeZero;
        BOOL hasValidDuration = CMTIME_IS_NUMERIC(newDuration) && newDuration.value != 0;
        double newDurationSeconds = hasValidDuration ? CMTimeGetSeconds(newDuration) : 0.0;

        if ([self.playerBottom respondsToSelector:@selector(ldxPlayer:durationSeconds:)]) {
            [self.playerBottom performSelector:@selector(ldxPlayer:durationSeconds:) withObject:self withObject:@(newDurationSeconds)];
        }
        
    }
    else if ([keyPath isEqualToString:@"player.rate"]) {
        // Update playPauseButton image
        
        double newRate = [change[NSKeyValueChangeNewKey] doubleValue];
        if (newRate == 1.0) {
            playOrPauseButton.selected = NO;
        } else {
            playOrPauseButton.selected = YES;
        }
        
    }
    else if ([keyPath isEqualToString:@"player.currentItem.status"]) {
        // Display an error if status becomes Failed
        
        // Handle NSNull value for NSKeyValueChangeNewKey, i.e. when player.currentItem is nil
        NSNumber *newStatusAsNumber = change[NSKeyValueChangeNewKey];
        AVPlayerItemStatus newStatus = [newStatusAsNumber isKindOfClass:[NSNumber class]] ? newStatusAsNumber.integerValue : AVPlayerItemStatusUnknown;
        
        if (newStatus == AVPlayerItemStatusFailed) {
            [self handleErrorWithMessage:self.player.currentItem.error.localizedDescription error:self.player.currentItem.error];
        }
        
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)fullClick:(UIButton *)button {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    if (button.selected) {
        self.navigationController.navigationBarHidden = isHiden;
        window.windowLevel = windowLevel;
        [window sendSubviewToBack:self.superView];
        //创建一个CGAffineTransform  transform对象
        CGAffineTransform  transform;
        //设置旋转度数
        transform = CGAffineTransformRotate(self.view.transform,-M_PI/2.0);
        //动画开始
        [UIView beginAnimations:@"rotate" context:nil];
        //动画时常
        [UIView setAnimationDuration:0.5];
        //获取transform的值
        [self.view setTransform:transform];
        //关闭动画
        [UIView commitAnimations];
        self.view.frame = self.originRect;
        
    } else {
        if (!isHiden) {
            self.navigationController.navigationBarHidden = YES;
        }
        window.windowLevel = UIWindowLevelStatusBar+1;
        [window bringSubviewToFront:self.view];
        //创建一个CGAffineTransform  transform对象
        CGAffineTransform  transform;
        //设置旋转度数
        transform = CGAffineTransformRotate(self.view.transform,M_PI/2.0);
        //动画开始
        [UIView beginAnimations:@"rotate" context:nil];
        //动画时常
        [UIView setAnimationDuration:0.5];
        //获取transform的值
        [self.view setTransform:transform];
        //关闭动画
        [UIView commitAnimations];
        self.view.frame = [UIScreen mainScreen].bounds;
        
    }
    button.selected = !button.selected;
}

- (void)playPauseButtonWasPressed:(UIButton *)sender {
    if (self.player.rate != 1.0) {
        // not playing foward so play
        if (CMTIME_COMPARE_INLINE(self.currentTime, ==, self.duration)) {
            // at end so got back to begining
            self.currentTime = kCMTimeZero;
        }
        [self.player play];
    } else {
        // playing so pause
        [self.player pause];
    }
}

- (void)timeSliderDidChange:(UISlider *)sender {
    [self.player pause];
    self.currentTime = CMTimeMakeWithSeconds(sender.value, 1000);
}

// Trigger KVO for anyone observing our properties affected by player and player.currentItem
+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
    if ([key isEqualToString:@"duration"]) {
        return [NSSet setWithArray:@[ @"player.currentItem.duration" ]];
    } else if ([key isEqualToString:@"currentTime"]) {
        return [NSSet setWithArray:@[ @"player.currentItem.currentTime" ]];
    } else if ([key isEqualToString:@"rate"]) {
        return [NSSet setWithArray:@[ @"player.rate" ]];
    } else {
        return [super keyPathsForValuesAffectingValueForKey:key];
    }
}

// MARK: - Error Handling

- (void)handleErrorWithMessage:(NSString *)message error:(NSError *)error {
    NSLog(@"Error occured with message: %@, error: %@.", message, error);
    
    NSString *alertTitle = NSLocalizedString(@"alert.error.title", @"Alert title for errors");
    NSString *defaultAlertMesssage = NSLocalizedString(@"error.default.description", @"Default error message when no NSError provided");
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:alertTitle message:message ?: defaultAlertMesssage preferredStyle:UIAlertControllerStyleAlert];
    
    NSString *alertActionTitle = NSLocalizedString(@"alert.error.actions.OK", @"OK on error alert");
    UIAlertAction *action = [UIAlertAction actionWithTitle:alertActionTitle style:UIAlertActionStyleDefault handler:nil];
    [controller addAction:action];
    
    [self presentViewController:controller animated:YES completion:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
