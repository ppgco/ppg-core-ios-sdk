//
//  PpgCoreNotificationServiceExtension.swift
//  ppg-core-example
//
//  Created by Mateusz Worotyński on 30/03/2023.
//

import Foundation
import UserNotifications

open class PpgCoreNotificationServiceExtension: UNNotificationServiceExtension {
  
    let eventService: EventService = EventService(config: PpgCoreConfig.shared)
  
    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
    
    /// This method should be handled in notification service extension
    /// By this method should only go "content-mutable" events ie. data events in ppg-core
    public func handleRemoteNotification(request: UNNotificationRequest, contentHandler: @escaping (UNNotificationContent) -> Void) -> UNMutableNotificationContent {
        switch(NotificationFactory.detectType(content: request.content)) {
        case .data:
            PpgCoreLogger.info("Got data message from remote notifications")
            let dataNotification = NotificationFactory.createData(content: request.content)
            let newContent = dataNotification.toUNNotificationMutableContent(markAsWrapped: true)
            eventService.send(delivered: dataNotification.createDeliveredEvent())
            onExternalData(data: dataNotification.externalData)
            contentHandler(newContent);
            return newContent
            
        case .silent:
            PpgCoreLogger.info("Got silent message as normal remote notification");
            let silentNotification = NotificationFactory.createSilent(content: request.content)
            eventService.send(delivered: silentNotification.createDeliveredEvent())
            onExternalData(data: silentNotification.externalData)
            let newContent = silentNotification.toUNNotificationMutableContent()
            return newContent
            
        case .unknown:
            PpgCoreLogger.info("Message unsupported")
            contentHandler(request.content)
            return request.content.mutableCopy() as! UNMutableNotificationContent;
        }
    }

    open override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = handleRemoteNotification(request: request, contentHandler: contentHandler)
    }

    open override func serviceExtensionTimeWillExpire() {
        if let contentHandler = contentHandler, let bestAttemptContent = bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
  
    open func onExternalData(data: String) -> Void {
      
    }

}
