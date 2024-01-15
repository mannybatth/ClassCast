//
//  RootViewController.m
//  ClassCast
//
//  Created by Manny on 4/22/14.
//  Copyright (c) 2014 Manpreet. All rights reserved.
//

#import "RootViewController.h"
#import "StreamViewController.h"

@interface RootViewController ()

@end

@implementation RootViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    if (!self.presentedViewController) [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillDisappear:animated];
}

- (IBAction)onStartStreamBtnClick:(id)sender
{
    UINavigationController *streamViewNavigationController = (UINavigationController*)[self.storyboard instantiateViewControllerWithIdentifier:@"StreamViewNavigationController"];
    StreamViewController *streamViewController = (StreamViewController*)streamViewNavigationController.topViewController;
    streamViewController.isBroadcaster = YES;
    [self.navigationController presentViewController:streamViewNavigationController animated:YES completion:^{
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
