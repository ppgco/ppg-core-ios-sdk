//
//  Notification.swift
//  ppg-core-example
//
//  Created by Mateusz Worotyński on 29/03/2023.
//

import Foundation

protocol Notification {
    var foreignId: String? {get set}
    var contextId: UUID {get set}
    var messageId: UUID {get set}
}


