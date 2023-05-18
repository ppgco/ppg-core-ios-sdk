//
//  Notification.swift
//  PpgCoreSDK
//
//  Created by Mateusz Worotyński on 29/03/2023.
//

import Foundation

enum NotificationType {
    case silent
    case data
    case unknown
}

protocol Notification {
    var foreignId: String? {get set}
    var contextId: UUID {get set}
    var messageId: UUID {get set}
}


