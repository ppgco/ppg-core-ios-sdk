//
//  PpgCoreConfig.swift
//  PpgCoreSDK
//
//  Created by Mateusz Worotyński on 18/05/2023.
//

import Foundation

public struct PpgCoreConfig {
  var endpoint: String = "https://api-core.pushpushgo.com/v1";
  
  init() {
    
    guard let plistURL = Bundle.main.url(forResource: "Info", withExtension: "plist") else {
        PpgCoreLogger.error("Couldn't find Info.plist in the main bundle")
        return;
    }

    guard let plistData = try? Data(contentsOf: plistURL) else {
        PpgCoreLogger.error("Couldn't load plist data from \(plistURL)")
        return;
    }

    guard let plist = try? PropertyListSerialization.propertyList(from: plistData, options: [], format: nil) else {
        PpgCoreLogger.error("Couldn't deserialize plist data")
        return;
    }

    if let overridenEndpoint = (plist as? NSDictionary)?["PpgCoreSDKEndpoint"] as? String {
        self.endpoint = overridenEndpoint
    }
  }
}
