//
//  ViewController.m
//  LDXPlayer
//
//  Created by bmd on 2017/3/23.
//  Copyright © 2017年 刘东旭. All rights reserved.
//

#import "ViewController.h"
#import "TestViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (IBAction)click:(id)sender {
    TestViewController *test = [[TestViewController alloc] init];
    [self.navigationController pushViewController:test animated:YES];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
