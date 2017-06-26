//
//  RNUserHandler.h
//  Notifications
//
//  Created by Chappy Asel on 6/25/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RNUser.h"

@class RNUserHandler;

@protocol RNUserHandlerDelegate <NSObject>

- (void)handler: (RNUserHandler *)handler loadedUser: (RNUser *)user;

- (void)handler: (RNUserHandler *)handler finishedSavingUser: (RNUser *)user;

@end

@interface RNUserHandler : NSObject

@property (nonatomic) __block RNUser *user;

@property id<RNUserHandlerDelegate> delegate;

+ (id)sharedInstance;

- (id)init;

- (void)loadUserWithToken: (NSString *)token;

- (void)addUserDataString: (NSString *)string;

- (void)removeUserDataString: (NSString *)string;

- (void)removeUserDataAtIndex: (int)index;

- (BOOL)userDataIsEmpty;

@end
