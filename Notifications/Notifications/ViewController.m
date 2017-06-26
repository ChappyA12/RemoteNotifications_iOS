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
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.textInput.delegate = self;
    self.handler = [RNUserHandler sharedInstance];
    self.handler.delegate = self;
    [self.textInput becomeFirstResponder];
    self.addButton.enabled = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - tableView dataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self.handler userDataIsEmpty]) return 0;
    return self.handler.user.data.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

#pragma mark - tableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.handler removeUserDataAtIndex:(int)(self.handler.user.data.count-indexPath.row-1)];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"cellID"];
    if (cell == nil) cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellID"];
    cell.textLabel.text = self.handler.user.data[self.handler.user.data.count-indexPath.row-1];
    return cell;
}

#pragma mark - textInput delegate

- (IBAction)addButtonPressed:(UIButton *)sender {
    [self.handler addUserDataString:self.textInput.text];
    self.textInput.text = @"";
    self.addButton.enabled = NO;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (newString.length == 0) self.addButton.enabled = NO;
    else self.addButton.enabled = YES;
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.textInput resignFirstResponder];
    return YES;
}

#pragma mark - RNUserHandler delegate

- (void)handler:(RNUserHandler *)handler loadedUser:(RNUser *)user {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (void)handler:(RNUserHandler *)handler finishedSavingUser:(RNUser *)user {
    
}

@end
