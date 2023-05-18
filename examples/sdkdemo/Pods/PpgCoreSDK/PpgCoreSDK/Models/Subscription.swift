//
//  Subscription.swift
//  PpgCoreSDK
//
//  Created by Mateusz Worotyński on 29/03/2023.
//

import Foundation

public struct Subscription: Codable {
    public init(token: Data) {
        self.token = token.map { String(format: "%02.2hhx", $0) }.joined()
    }
    
    public var token: String
    public var type: String = "apns/ios"
    public var appBundleId: String = Bundle.main.bundleIdentifier ?? "NA"
    
    public func toJSON() -> Data {
        let encoder = JSONEncoder()

        guard let json = try? encoder.encode(self) else {
            fatalError("Failed to encode subscription to JSON")
        }

        return json
    }
    
    public func toJSONString() -> String {
        return String(data: self.toJSON(), encoding: .utf8)!
    }
}
