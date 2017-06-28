//
//  RNUser.m
//  Notifications
//
//  Created by Chappy Asel on 6/25/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "RNUser.h"
#import "NotificationKeys.h"

@implementation RNUser

+ (NSString *)dynamoDBTableName {
    return AWS_TABLE_NAME;
}

+ (NSString *)hashKeyAttribute {
    return @"pushToken";
}

@end
