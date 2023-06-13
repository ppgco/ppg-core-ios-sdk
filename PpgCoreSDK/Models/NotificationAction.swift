//
//  NotificationAction.swift
//  PpgCoreSDK
//
//  Created by Mateusz Worotyński on 13/06/2023.
//

import Foundation

struct NotificationAction: Codable {
    let icon: String?
    let action: String
    let title: String
    let url: String

    static func fromJson(json: Data) -> [NotificationAction] {
        let decoder = JSONDecoder()

        guard let deserialized = try? decoder.decode([NotificationAction].self, from: json) else {
            fatalError("Failed to decode notification action from JSON")
        }

        return deserialized
    }
}
