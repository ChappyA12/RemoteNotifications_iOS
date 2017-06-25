//
//  NotificationService.swift
//  NotificationImage
//
//  Created by Chappy Asel on 6/24/17.
//  Copyright © 2017 CD. All rights reserved.
//

import UserNotifications
import UIKit

final class NotificationService: UNNotificationServiceExtension {
    
    private var contentHandler: ((UNNotificationContent) -&gt; Void)?
    private var bestAttemptContent: UNMutableNotificationContent?
    
    override internal func didReceiveNotificationRequest(request: UNNotificationRequest, withContentHandler contentHandler: (UNNotificationContent) -&gt; Void){
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        func failEarly() {
            contentHandler(request.content)
        }
        
        guard let content = (request.content.mutableCopy() as? UNMutableNotificationContent) else {
            return failEarly()
        }
        
        guard let attachmentURL = content.userInfo["attachment-url"] as? String else {
            return failEarly()
        }
        
        guard let imageData = NSData(contentsOfURL:NSURL(string: attachmentURL)!) else { return failEarly() }
        guard let attachment = UNNotificationAttachment.create("image.gif", data: imageData, options: nil) else { return failEarly() }
        
        content.attachments = [attachment]
        contentHandler(content.copy() as! UNNotificationContent)
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent = bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
    
}

extension UNNotificationAttachment {
    
    /// Save the image to disk
    static func create(imageFileIdentifier: String, data: NSData, options: [NSObject : AnyObject]?) -&gt; UNNotificationAttachment? {
    let fileManager = NSFileManager.defaultManager()
    let tmpSubFolderName = NSProcessInfo.processInfo().globallyUniqueString
    let tmpSubFolderURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).URLByAppendingPathComponent(tmpSubFolderName, isDirectory: true)
    
    do {
    try fileManager.createDirectoryAtURL(tmpSubFolderURL!, withIntermediateDirectories: true, attributes: nil)
    let fileURL = tmpSubFolderURL?.URLByAppendingPathComponent(imageFileIdentifier)
    try data.writeToURL(fileURL!, options: [])
    let imageAttachment = try UNNotificationAttachment.init(identifier: imageFileIdentifier, URL: fileURL!, options: options)
    return imageAttachment
    } catch let error {
    print("error \(error)")
    }
    
    return nil
    }
}
