//
//  PpgCoreConfig.swift
//  PpgCoreSDK
//
//  Created by Mateusz Worotyński on 18/05/2023.
//

import Foundation
import UserNotifications

public struct PpgCoreConfig {
  
    static public var shared: PpgCoreConfig = PpgCoreConfig()
      
    var endpoint: String = "https://api-core.pushpushgo.com/v1";
    
    var channels: [String: NotificationChannel] = [:]
    
    init() {
        guard let plistURL = Bundle.main.url(forResource: "PpgCore", withExtension: "plist") else {
            PpgCoreLogger.error("Couldn't find PpgCore.plist in the main bundle")
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
                
        if let data = (plist as? NSDictionary)?["PpgCoreChannels"] as? [Any] {
          for item in data {
            if let channelData = item as? [String: Any],
               let actions = channelData["actions"] as? [String],
               let name = channelData["name"] as? String,
               let sound = channelData["sound"] as? String {
              
               PpgCoreLogger.info("Registering \(name) channel for notifications")
              
               if (self.channels[name] != nil) {
                   PpgCoreLogger.error("Duplicated channel name check PpgCoreChannels.name declaration for duplicates in Info.plist file")
                   continue;
               }
              
               let soundObject = UNNotificationSound(named: UNNotificationSoundName(rawValue: sound))
               self.channels[name] = NotificationChannel(name: name, sound: soundObject, actions: actions)
            }
          }
        }
    }
    
    private func createCategoryAction(label: String, index: Int) -> UNNotificationAction {
        return UNNotificationAction(
            identifier: "action_\(index)",
            title: label,
            options: [.foreground]
        )
    }
    
    private func createDefaultChannels(firstAction: String, secondAction: String) -> [String: NotificationChannel] {
        return [
            NotificationChannelType.DEFAULT_WITH_ACTIONS.rawValue: NotificationChannel(
                name: NotificationChannelType.DEFAULT_WITH_ACTIONS.rawValue, sound: .default, actions: [firstAction, secondAction]
            ),
            NotificationChannelType.DEFAULT_WITH_ACTION.rawValue: NotificationChannel(
                name: NotificationChannelType.DEFAULT_WITH_ACTION.rawValue, sound: .default, actions: [firstAction]
            ),
            NotificationChannelType.DEFAULT.rawValue: NotificationChannel(
                name: NotificationChannelType.DEFAULT.rawValue, sound: .default, actions: []
            )
        ]
    }
    
    public func getCategories(actionLabels: [String] = []) -> Set<UNNotificationCategory> {

        let firstAction = actionLabels.first ?? "Open"
        let secondAction = actionLabels.last ?? "Show more"
        
        let combinedChannels = self.channels.merging(createDefaultChannels(firstAction: firstAction, secondAction: secondAction)) { (_, new) in new }
        
        let categories = combinedChannels.reduce(into: Set<UNNotificationCategory>()) { (result, channel) in
            let (_, channelData) = channel
            let category = UNNotificationCategory(
                identifier: channelData.name,
                actions: channelData.actions.enumerated().map {( index, item ) in
                    createCategoryAction(label: item, index: index)
                },
                intentIdentifiers: [],
                hiddenPreviewsBodyPlaceholder: "",
                options: [.customDismissAction]
            )
            result.insert(category)
        }
        
        return categories
    }
    
    func getChannel(notification: DataNotification) -> NotificationChannel {
        if (notification.channelName.isEmpty || notification.channelName == "default") {
            
            PpgCoreLogger.error("Channel '\(notification.channelName)' not found - fallback to default channel");

            switch(notification.actions.count) {
            case 1:
                return NotificationChannel(name: NotificationChannelType.DEFAULT_WITH_ACTION.rawValue, sound: .default, actions: [])
            case 2:
                return NotificationChannel(name: NotificationChannelType.DEFAULT_WITH_ACTIONS.rawValue, sound: .default, actions: [])
            default:
                return NotificationChannel(name: NotificationChannelType.DEFAULT.rawValue, sound: .default, actions: [])
            }
        }

        let channel = self.channels[notification.channelName]
        
        if (channel == nil) {
            PpgCoreLogger.error("Channel '\(notification.channelName)' not found - fallback to default channel");
            return NotificationChannel(name: NotificationChannelType.DEFAULT.rawValue, sound: .default, actions: [])
        }
        
        PpgCoreLogger.error("Channel '\(notification.channelName)' found");
        
        return channel!;
    }
}
