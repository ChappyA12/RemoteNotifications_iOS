//
//  RNUser.h
//  Notifications
//
//  Created by Chappy Asel on 6/25/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import <AWSDynamoDB/AWSDynamoDB.h>

@interface RNUser : AWSDynamoDBObjectModel <AWSDynamoDBModeling>

@property (nonatomic, strong) NSString *pushToken;
@property                     BOOL update;
@property (nonatomic, strong) NSMutableArray <NSString *> *data;

@end
