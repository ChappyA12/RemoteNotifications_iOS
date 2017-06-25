//
//  RNUserHandler.m
//  Notifications
//
//  Created by Chappy Asel on 6/25/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "RNUserHandler.h"
#import <AWSCore/AWSCore.h>
#import <AWSDynamoDB/AWSDynamoDB.h>

@interface RNUserHandler ()

@property (nonatomic) __block AWSDynamoDBObjectMapper *mapper;

@end

@implementation RNUserHandler

+ (id)sharedInstance {
    static dispatch_once_t p = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&p, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

- (id)init {
    if (self = [super init]) {
        
    }
    return self;
}

- (void)loadUserWithToken: (NSString *)token {
    self.mapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    //search for existing
    [[self.mapper load:[RNUser class] hashKey:token rangeKey:nil] continueWithBlock:^id(AWSTask *task) {
        if (task.error) NSLog(@"The request failed. Error: [%@]", task.error);
        else {
            if (task.result) { //user exists
                self.user = task.result;
            }
            else { //create new user
                self.user = [RNUser new];
                self.user.pushToken = token;
                self.user.update = YES;
                self.user.data = [[NSMutableArray alloc] initWithArray:@[@"Bryce Harper"]];
                [self saveUser];
            }
            [self.delegate handler:self loadedUser:self.user];
        }
        return nil;
    }];
}

- (void)addUserDataString: (NSString *)string {
    [self.user.data addObject:string];
    self.user.update = YES;
    [self saveUser];
}

- (void)removeUserDataString: (NSString *)string {
    [self.user.data removeObject:string];
    self.user.update = YES;
    [self saveUser];
}

- (void)saveUser {
    [[self.mapper save:self.user] continueWithBlock:^id(AWSTask *task) {
        if (task.error) NSLog(@"The request failed. Error: [%@]", task.error);
        else [self.delegate handler:self finishedSavingUser:self.user];
        return nil;
    }];
}

@end
