//
//  NotificationFactory.swift
//  PpgCoreSDK
//
//  Created by Mateusz Worotyński on 17/05/2023.
//

import Foundation
import UserNotifications

class NotificationFactory {
  
  static func detectType(userInfo: [AnyHashable : Any]) -> NotificationType {
      // Check if contains our metadata
      if let _ = userInfo["messageId"] as? String {
          // If yes check if is marked as silent message
          if let silent = userInfo["silent"] as? String? {
              if (silent != nil) {
                  return .silent
              }
          }
          
          return .data
      }
      
      return .unknown
  }
  
  static func detectType(content: UNNotificationContent) -> NotificationType {
      return detectType(userInfo: content.userInfo)
  }
  
  static public func createSilent(userInfo: [AnyHashable : Any]) -> SilentNotification {
      return SilentNotification(userInfo: userInfo);
  }
  
  static public func createSilent(content: UNNotificationContent) -> SilentNotification {
      return SilentNotification(content: content)
  }
  
  static public func createData(content: UNNotificationContent) -> DataNotification {
      return DataNotification(content: content)
  }
  
}
