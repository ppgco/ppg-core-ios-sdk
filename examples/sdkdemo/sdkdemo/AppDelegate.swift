//
//  AppDelegate.swift
//  sdkdemo
//
//  Created by Mateusz Worotyński on 18/05/2023.
//

import Foundation
import SwiftUI
import UserNotifications
import PpgCoreSDK

class AppDelegate: NSObject, UIApplicationDelegate {
  
    let ppgCoreClient: PpgCoreClient = PpgCoreClient()

    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        ppgCoreClient.initialize(actionLabels: ["Open", "Check more"])
        return true
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        ppgCoreClient.registerForNotifications(handler: {
            result in
            switch result {
            case .success:
                PpgCoreLogger.info("Granted")
                break
            case .error:
                PpgCoreLogger.error("Denied")
                break
            }
        })

        ppgCoreClient.resetBadge()
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // TODO: Save this in your database!
        PpgCoreLogger.info(Subscription(token: deviceToken).toJSONString())
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        ppgCoreClient.handleBackgroundRemoteNotification(userInfo: userInfo, completionHandler: completionHandler)
    }

    // Works only on UIKit on SwiftUI it can be done onChange()
    func applicationWillEnterForeground(_ application: UIApplication) {
        ppgCoreClient.resetBadge()
    }
    
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        ppgCoreClient.handleNotification(notification: notification, completionHandler: completionHandler)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
           didReceive response: UNNotificationResponse,
           withCompletionHandler completionHandler:
             @escaping () -> Void) {
        ppgCoreClient.handleNotificationResponse(response: response, completionHandler: completionHandler)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didDismissNotification notification: UNNotification) {
        ppgCoreClient.handleNotificationDismiss(notification: notification)
    }
}
