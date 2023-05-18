//
//  EventService.swift
//  PpgCoreSDK
//
//  Created by Mateusz Worotyński on 29/03/2023.
//

import Foundation

enum EventType {
    case clicked
    case closed
    case delivered
}

class EventService {
    
    let endpoint: String
    
    init(endpoint: String) {
        self.endpoint = endpoint
    }
    
    init(config: PpgCoreConfig) {
        self.endpoint = config.endpoint
    }
  
    func getActionByType(type: EventType) -> String {
        switch type {
        case .clicked:
            return "clicked"
        case .delivered:
            return "delivered"
        case .closed:
            return "closed"
        }
    }
    
    func internalSend(data: Data, contextId: String, type: EventType, completionHandler: @escaping () -> Void) {
        var request = URLRequest(
            url: URL(string: "\(endpoint)/context/\(contextId.lowercased())/events/\(getActionByType(type: type))")!
        )
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = data

        URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil {
                PpgCoreLogger.info(error?.localizedDescription ?? "Unknown error")
                completionHandler()
                return
            }
            completionHandler()
            PpgCoreLogger.info("Send event success")
        }.resume()
    }
    
    func send(clicked: NotificationClicked, completionHandler: @escaping () -> Void = {}) {
        return internalSend(
            data: clicked.toJSON(),
            contextId: clicked.contextId.uuidString,
            type: .clicked,
            completionHandler: completionHandler
        )
    }
    
    func send(closed: NotificationClosed, completionHandler: @escaping () -> Void = {}) {
        return internalSend(
            data: closed.toJSON(),
            contextId: closed.contextId.uuidString,
            type: .closed,
            completionHandler: completionHandler
        )
    }
    
    func send(delivered: NotificationDelivered, completionHandler: @escaping () -> Void = {}) {
        return internalSend(
            data: delivered.toJSON(),
            contextId: delivered.contextId.uuidString,
            type: .delivered,
            completionHandler: completionHandler
        )
    }
}
