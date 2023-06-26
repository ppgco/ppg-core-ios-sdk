//
//  PpgCoreClient.swift
//  PpgCoreSDK
//
//  Created by Mateusz Worotyński on 30/03/2023.
//

import Foundation
import UserNotifications
import SwiftUI

public enum SubscriptionActionResult {
    case success
    case error(String)
}

public class PpgCoreClient: NSObject {
    let eventService: EventService = EventService(config: PpgCoreConfig.shared)
    var onExternalData: (_ data: String) -> Void = {
        result in
    }
    
    @available(iOSApplicationExtension, unavailable)
    private func setBadge(num: Int) {
        return UIApplication.shared.applicationIconBadgeNumber = num;
    }
  
    @available(iOSApplicationExtension, unavailable)
    private func getBadge() -> Int {
        return UIApplication.shared.applicationIconBadgeNumber
    }

    public func initialize(actionLabels: [String] = []) {
        UNUserNotificationCenter
          .current()
          .setNotificationCategories(PpgCoreConfig.shared.getCategories(actionLabels: actionLabels))
    }
    
    public func initialize(actionLabels: [String] = [], onExternalData: @escaping (_ data: String) -> Void) {
        self.onExternalData = onExternalData
        UNUserNotificationCenter
          .current()
          .setNotificationCategories(PpgCoreConfig.shared.getCategories(actionLabels: actionLabels))
    }
  
    @available(iOSApplicationExtension, unavailable)
    public func resetBadge() {
        PpgCoreLogger.info("Reset badge")
        return setBadge(num: -1);
    }
  
    @available(iOSApplicationExtension, unavailable)
    public func incrementBadge() {
        PpgCoreLogger.info("Incrementing badge")
        return setBadge(num: getBadge() + 1)
    }
  
    @available(iOSApplicationExtension, unavailable)
    public func decrementBadge() {
        PpgCoreLogger.info("Decrementing badge")
        return setBadge(num: getBadge() - 1)
    }
 
    /// Default notifications prompt
    @available(iOSApplicationExtension, unavailable)
    public func registerForNotifications(handler: @escaping (_ result: SubscriptionActionResult) -> Void) {
        UNUserNotificationCenter
            .current()
            .requestAuthorization(options: [.alert, .sound, .badge]) {
                granted, error in

                if let error = error {
                    PpgCoreLogger.info("Init Notifications error: \(error)")
                    handler(.error(error.localizedDescription))
                    return
                }
                
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
                
                PpgCoreLogger.info("Init Notifications success")

                handler(.success)
            }
    }
    
    /// Methods should be used for handle notifications "swipe" to inform about "closed" events
    public func handleNotificationDismiss(notification: UNNotification) {
      switch(NotificationFactory.detectType(content: notification.request.content)) {
        case .data:
          let dataNotification = NotificationFactory.createData(content: notification.request.content)
            eventService.send(closed: dataNotification.createClosedEvent())
            break;
        default:
            break;
        }
    }
    
    /// Trigger open default browser with provided URL
    @available(iOSApplicationExtension, unavailable)
    private func openUrl(url: URL?) {
        if (url == nil) {
            PpgCoreLogger.info("No url provided")
            return;
        }
        
        UIApplication.shared.open(url!)
    }
    
    /// Methods handles any notifications response and send statistics events to server
    @available(iOSApplicationExtension, unavailable)
    public func handleNotificationResponse(response: UNNotificationResponse, completionHandler: @escaping () -> Void) {
      switch(NotificationFactory.detectType(content: response.notification.request.content)) {
        case .data:
          let dataNotification = NotificationFactory.createData(content: response.notification.request.content)
            switch(response.actionIdentifier) {
            case "com.apple.UNNotificationDismissActionIdentifier":
                eventService.send(closed: dataNotification.createClosedEvent()) {
                    DispatchQueue.main.sync {
                       completionHandler()
                   }
                }
                break;
        
            case "com.apple.UNNotificationDefaultActionIdentifier":
                eventService.send(clicked: dataNotification.createClickedEvent(action: "default")) {
                    DispatchQueue.main.sync {
                       completionHandler()
                   }
                }
                openUrl(url: dataNotification.getUrlForAction(action: "default"))
                break;
                
            default:
                // Due to problems with dynamic actions, we need to use static and map fake action id to real action id
                let realActionIdentifier = dataNotification.getRealActionIdentifier(fakeActionIdentifier: response.actionIdentifier);
                eventService.send(clicked: dataNotification.createClickedEvent(action: realActionIdentifier)) {
                    DispatchQueue.main.sync {
                       completionHandler()
                   }
                }
                openUrl(url: dataNotification.getUrlForAction(action: realActionIdentifier))
                break;
            }
            break;
        default:
            completionHandler()
            break;
        }
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
            onExternalData(dataNotification.externalData)
            contentHandler(newContent);
            return newContent
            
        case .silent:
            PpgCoreLogger.info("Got silent message as normal remote notification");
            let silentNotification = NotificationFactory.createSilent(content: request.content)
            eventService.send(delivered: silentNotification.createDeliveredEvent())
            onExternalData(silentNotification.externalData)
            let newContent = silentNotification.toUNNotificationMutableContent()
            return newContent
            
        case .unknown:
            PpgCoreLogger.info("Message unsupported")
            contentHandler(request.content)
            return request.content.mutableCopy() as! UNMutableNotificationContent;
        }
    }
    
    /// This method should handle only "content-available" messages ie. silent messages
    public func handleBackgroundRemoteNotification(userInfo: [AnyHashable : Any], completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        switch(NotificationFactory.detectType(userInfo: userInfo)) {
        case .silent:
            PpgCoreLogger.info("Got background message as silent message try to register event");
            let silentNotification = NotificationFactory.createSilent(userInfo: userInfo)
            eventService.send(delivered: silentNotification.createDeliveredEvent())
            onExternalData(silentNotification.externalData)
            completionHandler(.newData)
            return;
        case .data:
            PpgCoreLogger.info("Got background message as data message omit registering event");
            completionHandler(.newData)
            return;
        case .unknown:
            PpgCoreLogger.error("Got background message as unknown message");
            completionHandler(.failed)
            return;
        }
    }
    
    private func getActionsFromJSON(jsonString: String?) -> [UNNotificationAction] {
        guard let serializedActions = jsonString else {return []}
        let actions = NotificationAction.fromJson(json: serializedActions.data(using: .utf8)!)
        
        return actions.map { actionItem in
            UNNotificationAction(
                identifier: actionItem.action,
                title: actionItem.title,
                options: [.foreground]
            )
        }
    }
    
    /// Local handling notification
    public func handleNotification(notification: UNNotification, completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
      switch(NotificationFactory.detectType(content: notification.request.content)) {
        case .data:
            PpgCoreLogger.info("Got data message from local notifications");
            let dataNotification = NotificationFactory.createData(content: notification.request.content)
          
            if (notification.request.content.userInfo["_wrappedByNSE"] != nil) {
               PpgCoreLogger.info("Omit, registering delivered event, wrapped by notification wrapped in NSE")
               break;
            }
          
            onExternalData(dataNotification.externalData)
            eventService.send(delivered: dataNotification.createDeliveredEvent())
            break;
        case .silent:
            PpgCoreLogger.info("Got silent message from local notifications");
            let silentNotification = NotificationFactory.createSilent(content: notification.request.content)
            onExternalData(silentNotification.externalData)
            eventService.send(delivered: silentNotification.createDeliveredEvent())
            return;
        case .unknown:
            PpgCoreLogger.info("Message unsupported")
            return;
        }
        
        if #available(iOS 14.0, *) {
            completionHandler([.banner, .sound])
        } else {
            completionHandler([.alert, .sound])
        }
    }
}
