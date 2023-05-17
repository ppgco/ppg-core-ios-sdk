//
//  NotificationFactory.swift
//  ppg-core-example
//
//  Created by Mateusz Worotyński on 30/03/2023.
//

import Foundation
import UserNotifications

public class PpgCoreNotificationServiceExtension: UNNotificationServiceExtension {
    let eventService: EventService

    public init(endpoint: String = "https://api-core.pushpushgo.com/v1") {
        self.eventService = EventService(endpoint: endpoint)
    }
    
    /// This method should be handled in notification service extension
    /// By this method should only go "content-mutable" events ie. data events in ppg-core
    public func handleRemoteNotification(request: UNNotificationRequest, contentHandler: @escaping (UNNotificationContent) -> Void) -> UNMutableNotificationContent {

      switch(NotificationFactory.detectType(content: request.content)) {
        case .data:
            PpgCoreLogger.info("Got data message from remote notifications")
            let dataNotification = NotificationFactory.createData(content: request.content)
            let newContent = dataNotification.toUNNotificationMutableContent()
            eventService.send(delivered: dataNotification.createDeliveredEvent())
            contentHandler(newContent);
            return newContent
            
        case .silent:
            PpgCoreLogger.info("Got silent message as normal remote notification");
            let silentNotification = NotificationFactory.createSilent(content: request.content)
            eventService.send(delivered: silentNotification.createDeliveredEvent())
            let newContent = silentNotification.toUNNotificationMutableContent()
            return newContent
            
        case .unknown:
            PpgCoreLogger.info("Message unsupported")
            contentHandler(request.content)
            return request.content.mutableCopy() as! UNMutableNotificationContent;
        }
    }
}
