//
//  NotificationAction.swift
//  PpgCoreSDK
//
//  Created by Mateusz Worotyński on 30/03/2023.
//

import Foundation
import UserNotifications

struct DataNotification: Notification {
    var contextId: UUID
    var messageId: UUID
    var channelName: String
    var externalData: String
    var foreignId: String?
    var actions: [NotificationAction] = []
    var title: String? = nil
    var body: String? = nil
    var subtitle: String? = nil
    var icon: String? = nil
    var image: String? = nil
    var url: String? = nil
    
    init(content: UNNotificationContent) {
        self.contextId = UUID(uuidString: (content.userInfo["contextId"] as? String)!)!
        self.messageId = UUID(uuidString: (content.userInfo["messageId"] as? String)!)!
        self.foreignId = content.userInfo["foreignId"] as? String
        self.externalData = content.userInfo["externalData"] as? String ?? ""

        self.title = content.title
        self.subtitle = content.subtitle
        self.body = content.body
        self.channelName = content.userInfo["channelName"] as? String ?? "default"
        self.icon = content.userInfo["icon"] as? String
        self.image = content.userInfo["image"] as? String
        self.url = content.userInfo["url"] as? String
        
        if let serializedActions = content.userInfo["actions"] as? String {
            self.actions = NotificationAction.fromJson(json: serializedActions.data(using: .utf8)!)
        } else {
            self.actions = []
        }
    }
    
    func getRealActionIdentifier(fakeActionIdentifier: String) -> String {
        guard let index = Int(fakeActionIdentifier.components(separatedBy: "_").last!) else { return "default" }
        return self.actions[Int(index)].action
    }
    
    func getUNNotificationActions() -> [UNNotificationAction] {
        var actions: [UNNotificationAction] = []
    
        for actionItem in self.actions {
            actions.append(
                UNNotificationAction(
                    identifier: actionItem.action,
                    title: actionItem.title,
                    options: [.foreground]
                )
            )
        }
        
        return actions
    }
    
    func toUNNotificationMutableContent(markAsWrapped: Bool = false) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
      
        content.userInfo["_wrappedByNSE"] = markAsWrapped ? "1" : nil
        content.userInfo["externalData"] = self.externalData
        content.userInfo["messageId"] = self.messageId.uuidString
        content.userInfo["contextId"] = self.contextId.uuidString
        content.userInfo["foreignId"] = self.foreignId
        content.userInfo["url"] = self.url

        if (self.title != nil) {
            content.title = self.title!
        }
        
        if (self.subtitle != nil) {
            content.subtitle = self.subtitle!
        }
        
        if (self.body != nil) {
            content.body = self.body!
        }
               
        if (self.actions.count > 0) {
            content.userInfo["actions"] = self.serializeActions()
        }
        
        let channel = PpgCoreConfig.shared.getChannel(notification: self)
        content.categoryIdentifier = channel.name
        content.sound = channel.sound
                
        if let image = self.image {
            if let attachment = try? UNNotificationAttachment(url: image) {
                content.attachments.append(attachment)
            }
        }
    
        if let icon = self.icon {
            if let attachment = try? UNNotificationAttachment(url: icon) {
                content.attachments.append(attachment)
            }
        }
        
        return content
    }
    
    func getUrlForAction(action: String) -> URL? {
        let firstAction: NotificationAction? = self.actions.first(where: {$0.action == action})
        let url = firstAction?.url ?? self.url ?? nil
                
        if (url == nil) {
            return nil
        }
        
        return URL(string: url!)
    }
    
    func serializeActions() -> String {
        let encoder = JSONEncoder()

        guard let json = try? encoder.encode(self.actions) else {
            fatalError("Failed to encode notification action to JSON")
        }

        return String(data: json, encoding: .utf8)!
    }
    
    func createDeliveredEvent() -> NotificationDelivered {
        return NotificationDelivered(notification: self)
    }
    
    func createClosedEvent() -> NotificationClosed {
        return NotificationClosed(notification: self)
    }
    
    func createClickedEvent(action: String?) -> NotificationClicked {
        return NotificationClicked(notification: self, action: action)
    }
}
