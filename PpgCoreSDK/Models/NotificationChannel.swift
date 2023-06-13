//
//  Channel.swift
//  PpgCoreSDK
//
//  Created by Mateusz Worotyński on 13/06/2023.
//

import Foundation
import UserNotifications

public enum NotificationChannelType: String {
    case DEFAULT
    case DEFAULT_WITH_ACTION
    case DEFAULT_WITH_ACTIONS
    case CUSTOM
}

struct NotificationChannel {
    var name: String
    var sound: UNNotificationSound
    var actions: [String]
}
