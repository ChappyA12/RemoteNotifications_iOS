//
//  NotificationService.m
//  NotificationImage
//
//  Created by Chappy Asel on 6/24/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "NotificationService.h"

@interface NotificationService ()

@property (nonatomic, strong) void (^contentHandler)(UNNotificationContent *contentToDeliver);
@property (nonatomic, strong) UNMutableNotificationContent *bestAttemptContent;
@property (nonatomic, strong) NSURLSession *session;

@end

@implementation NotificationService

- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent *_Nonnull))contentHandler {
    self.contentHandler = contentHandler;
    self.bestAttemptContent = [request.content mutableCopy];
    
    // Modify the notification content here...
    // self.bestAttemptContent.body = [NSString stringWithFormat:@"%@ [modified]", self.bestAttemptContent.body];
    
    // check for media attachment, example here uses custom payload keys mediaUrl and mediaType
    NSDictionary *userInfo = request.content.userInfo;
    if (userInfo == nil) {
        [self contentComplete];
        return;
    }
    if ([userInfo objectForKey:@"pic_url"]) {
        [self loadAttachmentForUrlString:[userInfo objectForKey:@"pic_url"]
                       completionHandler: ^(UNNotificationAttachment *attachment) {
                           self.bestAttemptContent.attachments = [NSArray arrayWithObjects:attachment, nil];
                       }];
    }
}

- (void)serviceExtensionTimeWillExpire {
    // Called just before the extension will be terminated by the system.
    // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
    [self contentComplete];
}

- (void)loadAttachmentForUrlString:(NSString *)urlString completionHandler:(void (^)(UNNotificationAttachment *))completionHandler {
    __block UNNotificationAttachment *attachment = nil;
    __block NSURL *attachmentURL = [NSURL URLWithString:urlString];
    
    NSString *fileExt = [@"." stringByAppendingString:[urlString pathExtension]];
    
    
    self.session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSURLSessionDownloadTask *task = [self.session downloadTaskWithURL:attachmentURL
                                                completionHandler: ^(NSURL *temporaryFileLocation, NSURLResponse *response, NSError *error) {
                                                    if (error != nil)
                                                    {
                                                        NSLog(@"%@", error.localizedDescription);
                                                    }
                                                    else
                                                    {
                                                        NSFileManager *fileManager = [NSFileManager defaultManager];
                                                        NSURL *localURL = [NSURL fileURLWithPath:[temporaryFileLocation.path
                                                                                                  stringByAppendingString:fileExt]];
                                                        [fileManager moveItemAtURL:temporaryFileLocation
                                                                             toURL:localURL
                                                                             error:&error];
                                                        
                                                        NSError *attachmentError = nil;
                                                        attachment = [UNNotificationAttachment attachmentWithIdentifier:[attachmentURL lastPathComponent]
                                                                                                                    URL:localURL
                                                                                                                options:nil
                                                                                                                  error:&attachmentError];
                                                        if (attachmentError)
                                                        {
                                                            NSLog(@"%@", attachmentError.localizedDescription);
                                                        }
                                                    }
                                                    completionHandler(attachment);
                                                }];
    
    [task resume];
}

- (void)contentComplete {
    [self.session invalidateAndCancel];
    self.contentHandler(self.bestAttemptContent);
}

@end
