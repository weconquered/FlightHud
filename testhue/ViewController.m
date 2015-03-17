//
//  ViewController.m
//  testhue
//
//  Created by apple on 3/17/15.
//  Copyright (c) 2015 liu. All rights reserved.
//

#import "ViewController.h"
#import "BLMInstrumentViewController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    BLMInstrumentViewController* hueController = [BLMInstrumentViewController shared];
    [hueController.instrumentView setCenter:self.view.center];
    [self.view addSubview:hueController.instrumentView];
    [hueController setHeight:4.5];
    [hueController setSpeed:3];
    [hueController setYawAngle:150];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
