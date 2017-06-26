//
//  ViewController.h
//  Notifications
//
//  Created by Chappy Asel on 6/24/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RNUserHandler.h"

@interface ViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, RNUserHandlerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *textInput;
@property (weak, nonatomic) IBOutlet UIButton *addButton;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

