//
//  TestViewController.m
//  LDXPlayer
//
//  Created by bmd on 2017/3/24.
//  Copyright © 2017年 刘东旭. All rights reserved.
//

#import "TestViewController.h"
#import "LDXPlayerViewController.h"

@interface TestViewController () {
    LDXPlayerViewController *ldxPlayerController;
}

@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view, typically from a nib.
    ldxPlayerController = [LDXPlayerViewController playerController];
    ldxPlayerController.movieURL = [NSURL URLWithString:@"https://tianmavideo.meishe-app.com/video/2017/03/23/task-1-79302969-BBC4-062E-001D-6FB6C0D6F0DD.mp4"];
    ldxPlayerController.superView = self.view;
    ldxPlayerController.view.frame = CGRectMake(0, 64, 375, 220);
    ldxPlayerController.originRect = ldxPlayerController.view.frame;
    [self addChildViewController:ldxPlayerController];
    [ldxPlayerController didMoveToParentViewController:self];
    [self.view addSubview:ldxPlayerController.view];
    [ldxPlayerController.player play];
}

-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];

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
