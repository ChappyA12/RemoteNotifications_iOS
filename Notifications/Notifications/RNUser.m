//
//  RNUser.m
//  Notifications
//
//  Created by Chappy Asel on 6/25/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "RNUser.h"

@implementation RNUser

+ (NSString *)dynamoDBTableName {
    return @"remoteNotificationsUsers";
}

+ (NSString *)hashKeyAttribute {
    return @"pushToken";
}

@end
