//
//  NotificationDelivered.swift
//  PpgCoreSDK
//
//  Created by Mateusz Worotyński on 29/03/2023.
//

import Foundation

struct NotificationDelivered: Notification, Codable {
    internal init(notification: Notification) {
        self.contextId = notification.contextId
        self.messageId = notification.messageId
        self.foreignId = notification.foreignId
        self.ts = Date()
    }
    var contextId: UUID
    var messageId: UUID
    var foreignId: String?
    var ts: Date
    
    enum CodingKeys: String, CodingKey {
        case contextId
        case messageId
        case foreignId
        case ts
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(contextId.uuidString.lowercased(), forKey: .contextId)
        try container.encode(messageId.uuidString.lowercased(), forKey: .messageId)
        try container.encode(foreignId, forKey: .foreignId)
        try container.encode(ISO8601DateFormatter().string(from: ts), forKey: .ts)
    }
    
    func toJSON() -> Data {
        let encoder = JSONEncoder()

        guard let json = try? encoder.encode(self) else {
            fatalError("Failed to encode notification event to JSON")
        }

        return json
    }
}
