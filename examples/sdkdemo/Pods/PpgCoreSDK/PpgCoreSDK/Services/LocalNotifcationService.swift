//
//  LocalNotifcationService.swift
//  PpgCoreSDK
//
//  Created by Mateusz Worotyński on 29/03/2023.
//

import Foundation
import UserNotifications
import SwiftUI

// Request permission to show notifications
public class LocalNotificationService {
    
    public init() {
        
    }
    
    public func showNotificationAsync(content: UNMutableNotificationContent) {
        DispatchQueue.global(qos: .userInitiated).async {
            self.showNotification(content: content)
        }
    }
    
    func showNotification(content: UNMutableNotificationContent) {
        var request: UNNotificationRequest
        
        switch NotificationFactory.detectType(content: content) {
        case .silent:
            let silentNotification = SilentNotification(content: content)
            request = UNNotificationRequest(
                identifier: silentNotification.messageId.uuidString,
                content: silentNotification.toUNLocalNotificationMutableContent(),
                trigger: nil
            )
            break;
        case .data:
            let dataNotification = DataNotification(content: content)
            request = UNNotificationRequest(
                identifier: dataNotification.messageId.uuidString,
                content: dataNotification.toUNNotificationMutableContent(),
                trigger: nil
            )
            break;
        case .unknown:
            PpgCoreLogger.info("Unknown notification")
            return
        }
        
        // Add the notification request to the notification center
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                PpgCoreLogger.info("Error adding notification: \(error.localizedDescription)")
            } else {
                PpgCoreLogger.info("Notification added successfully.")
            }
        }
    }
}
