//
//  NotificationService.m
//  NotificationImage
//
//  Created by Chappy Asel on 6/24/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "NotificationService.h"
#import <AWSCore/AWSCore.h>
#import <AWSCognito/AWSCognito.h>
#import <AWSS3/AWSS3.h>
#import "NotificationKeys.h"

@interface NotificationService ()

@property (nonatomic, strong) AWSS3TransferManager *manager;
@property (nonatomic, strong) void (^contentHandler)(UNNotificationContent *contentToDeliver);
@property (nonatomic, strong) UNMutableNotificationContent *bestAttemptContent;

@end

@implementation NotificationService

- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent *_Nonnull))contentHandler {
    self.contentHandler = contentHandler;
    self.bestAttemptContent = [request.content mutableCopy];
    NSDictionary *userInfo = request.content.userInfo;
    if (userInfo == nil) {  
        [self contentComplete];
        return;
    }
    if ([userInfo objectForKey:@"S3Link"]) {
        [self loadImageWithLink:[userInfo objectForKey:@"S3Link"] completionHandler: ^(UNNotificationAttachment *attachment) {
            self.bestAttemptContent.attachments = [NSArray arrayWithObjects:attachment, nil];
            [self contentComplete];
        }];
    }
}

- (void)serviceExtensionTimeWillExpire { // Called just before the extension will be terminated by the system.
    [self contentComplete];
}

- (void)loadImageWithLink:(NSString *)urlString completionHandler:(void (^)(UNNotificationAttachment *))completionHandler {
    //COGNITO HANDLING
    AWSCognitoCredentialsProvider *credentialsProvider = [[AWSCognitoCredentialsProvider alloc]
                                                          initWithRegionType:AWSRegionUSEast1
                                                          identityPoolId:AWS_POOL_ID];
    AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSEast1 credentialsProvider:credentialsProvider];
    [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
    //IMAGE DOWNLOAD
    self.manager = [AWSS3TransferManager defaultS3TransferManager];
    NSString *downloadingFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:urlString];
    NSURL *downloadingFileURL = [NSURL fileURLWithPath:downloadingFilePath];
    AWSS3TransferManagerDownloadRequest *downloadRequest = [AWSS3TransferManagerDownloadRequest new];
    downloadRequest.bucket = AWS_BUCKET_NAME;
    downloadRequest.key = urlString;
    downloadRequest.downloadingFileURL = downloadingFileURL;
    [[self.manager download:downloadRequest] continueWithExecutor:[AWSExecutor mainThreadExecutor] withBlock:^id(AWSTask *task) {
        if (task.error){
            if ([task.error.domain isEqualToString:AWSS3TransferManagerErrorDomain]) {
                switch (task.error.code) {
                    case AWSS3TransferManagerErrorCancelled:
                    case AWSS3TransferManagerErrorPaused:
                        break;
                    default:
                        NSLog(@"Error: %@", task.error);
                        break;
                }
            }
            else NSLog(@"Error: %@", task.error);
        }
        if (task.result) {
            //AWSS3TransferManagerDownloadOutput *downloadOutput = task.result;
            //DELETE IMAGE
            AWSS3 *S3 = [AWSS3 defaultS3];
            AWSS3DeleteObjectRequest *deleteRequest = [AWSS3DeleteObjectRequest new];
            deleteRequest.bucket = AWS_BUCKET_NAME;
            deleteRequest.key = urlString;
            [S3 deleteObject:deleteRequest];
            UNNotificationAttachment *attachment =
                [UNNotificationAttachment attachmentWithIdentifier:[downloadingFileURL lastPathComponent]
                                                               URL:downloadingFileURL
                                                           options:nil error:nil];
            completionHandler(attachment);
        }
        return nil;
    }];
}

- (void)contentComplete {
    self.contentHandler(self.bestAttemptContent);
}

@end
