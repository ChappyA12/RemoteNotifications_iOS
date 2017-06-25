//
//  ViewController.m
//  Notifications
//
//  Created by Chappy Asel on 6/24/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property RNUserHandler *handler;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.handler = [RNUserHandler sharedInstance];
    self.handler.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - RNUserHandler delegate

- (void)handler:(RNUserHandler *)handler loadedUser:(RNUser *)user {
    NSLog(@"%@",self.handler.user);
    [self.handler addUserDataString:@"Trea Turner"];
}

- (void)handler:(RNUserHandler *)handler finishedSavingUser:(RNUser *)user {
    
}

@end
