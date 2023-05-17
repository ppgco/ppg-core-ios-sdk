//
//  SilentNotification.swift
//  ppg-core-example
//
//  Created by Mateusz Worotyński on 30/03/2023.
//

import Foundation
import UserNotifications

struct SilentNotification: Notification {
    var contextId: UUID
    var messageId: UUID
    var foreignId: String?
    
    init(userInfo: [AnyHashable : Any]) {
        self.contextId = UUID(uuidString: (userInfo["contextId"] as? String)!)!
        self.messageId = UUID(uuidString: (userInfo["messageId"] as? String)!)!
        self.foreignId = userInfo["foreignId"] as? String
    }
    
    init(content: UNNotificationContent) {
        self.contextId = UUID(uuidString: (content.userInfo["contextId"] as? String)!)!
        self.messageId = UUID(uuidString: (content.userInfo["messageId"] as? String)!)!
        self.foreignId = content.userInfo["foreignId"] as? String
    }
    
    func toUNLocalNotificationMutableContent() -> UNMutableNotificationContent {
        let content = self.toUNNotificationMutableContent();
        content.title = "silent local notification"
        return content;
    }
    
    func toUNNotificationMutableContent() -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.userInfo["messageId"] = self.messageId.uuidString
        content.userInfo["contextId"] = self.contextId.uuidString
        content.userInfo["foreignId"] = self.foreignId
        content.userInfo["silent"] = "1"
        return content;
    }
    
    func createDeliveredEvent() -> NotificationDelivered {
        return NotificationDelivered(notification: self)
    }
}

