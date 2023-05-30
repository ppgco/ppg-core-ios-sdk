# PushPushGo Core SDK for iOS
![GitHub tag (latest)](https://img.shields.io/github/v/tag/ppgco/ppg-core-ios-sdk?style=flat-square)
![GitHub Workflow Status (main)](https://img.shields.io/github/actions/workflow/status/ppgco/ppg-core-ios-sdk/publish.yml?style=flat-square)
![Discord](https://img.shields.io/discord/1108358192339095662?color=%237289DA&label=Discord&style=flat-square)

Packages are published on CocoaPods

## Requirements:
Access to Apple Developer Account.

## Product Info
PushPushGo Core* is a building block for push notifications:
 - sender for push notifications - we handle batch requests, aggregate feedback events and inform your webhook
 - images storage & traffic - we handle, crop and serve your push images
 - fast implementation - we cover ios, iOS, Web with push notifications support
 - you own your database and credentials - no vendor lock-in - we provide infrastructure, sdk & support
 - simple API - we provide one API for all providers

Contact: support+core@pushpushgo.com or [Discord](https://discord.gg/NVpUWvreZa)

<sub>PushPushGo Core is not the same as PushPushGo product - if you are looking for [PushPushGo - Push Notifications Management Platform](https://pushpushgo.com)</sub>

## How it works

IMAGE HERE

When you send request to our API to send message, we prepare images and then connect to different providers. 

When message is delieverd to the device and interacts with user, we collect events and pass them to our API.

After a short time you will recieve package with events on your webhook:

```json
{
    "messages": [
        {
            "messageId": "8e3075f1-6b21-425a-bb4f-eeaf0eac93a2",
            "foreignId": "my_id",
            "result": {
                "kind": "sent"
            },
            "ts": 1685009020243
        },
        {
            "messageId": "8e3075f1-6b21-425a-bb4f-eeaf0eac93a2",
            "foreignId": "my_id",
            "result": {
                "kind": "delivered"
            },
            "ts": 1685009020564
        }
    ]
}
```

Using that data you can calculate statistics or do some of your business logic.

## Environment setup
Initialize Podfile if already is not initialized

```bash
$ cd your_project_name
$ pod init
```

Open XCode Workspace instead of Project

## 1. Add dependencies to your project

Add to your target our library:

```swift
target 'your_project_name' do
  use_frameworks!
  pod 'PpgCoreSDK', '~> 0.0.8'
end
```

Then install pods and open xcode with workspace env

```bash
$ pod install
$ xed your_project_name.xcworkspace
```

## 2. Enable Push Notification Capabilities in Project Target
1. Select your root item in files tree called "**your_project_name**" with blue icon and select **your_project_name** in **Target** section.
2. Go to Signing & Capabilities tab and click on "**+ Capability**" under tabs.
3. Select **Push Notifications** and **Background Modes**
4. On **Background Modes** select items:
 - Remote notifications
 - Background fetch

## 3. Add NotificationServiceExtension
1. Go to file -> New -> Target
2. Search for **Notification Service Extension** and choose product name may be for example **NSE**
3. Finish process and on prompt about __Activate “NSE” scheme?__ click **Cancel**
4. Add to previously used name **NSE** 
target to `Podfile`:
```
target 'NSE' do
  use_frameworks!
  pod 'PpgCoreSDK', '~> 0.0.8'
end
```
5. Install pods
```bash
$ pod install
```

### 3.1 Configure Notification Service Extension
1. Open file NotificationService.swift
2. Paste this code:
```swift
import UserNotifications
import PpgCoreSDK

class NotificationService: PpgCoreNotificationServiceExtension {
  
}
```

## 4. If you do not have AppDelegate.swift create new one (SwiftUI).
1. Create AppDelegate.swift
```swift
import Foundation
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
  
}
```

2. In your App file wrap delegate via decorator
```swift
struct your_project_nameApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
  ...
}
```

## 5. Override methods in `AppDelegate.swift`

1. Add imports and create instance
```swift
import Foundation
import SwiftUI
import UserNotifications
import PpgCoreSDK

class AppDelegate: NSObject, UIApplicationDelegate {
  
    let ppgCoreClient: PpgCoreClient = PpgCoreClient()
}
```

2. Add method for willFinishLaunchingWithOptions
```swift
func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        ppgCoreClient.initialize(actionLabels: ["Open", "Check more"])
        return true
    }
```

3. Add method for didFinishLaunchingWithOptions
```swift
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
```

4. Add method for didRegisterForRemoteNotificationsWithDeviceToken
```swift
func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // TODO: Save this in your database!
        PpgCoreLogger.info(Subscription(token: deviceToken).toJSONString())
    }
```

5. Add method for didReceiveRemoteNotification
```swift
func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        ppgCoreClient.handleBackgroundRemoteNotification(userInfo: userInfo, completionHandler: completionHandler)
    }
```

## 6. Add Extension in `AppDelegate.swift`

1. On the end of `AppDelegate.swift` add extension
```swift
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

```

7. (Optional) add to Info.plist file in case if you want to override endpoint (development, self-hosted instance) add to `<dict>`
```xml
    <key>PpgCoreSDKEndpoint</key>
    <string>https://api-core.pushpushgo.com/v1</string>
```

# Sending notifications

## 1. Prepare certificates
 1. Go to `https://developer.apple.com/account/resources/identifiers/list` and go to **Identifiers** section
 2. Select from list your appBundleId like `com.example.your_project_name`
 3. Look for PushNotifications and click "**Configure**" button
 4. Select your __Certificate Singing Request__ file
 5. Download Certificates and open in KeyChain Access (double click in macos)
 6. Find this certificate in list select then in context menu (right click) select export and export to .p12 format file with password.

## 2. Prepare configuration
 1. Wrap exported certficates with Base64 with command
 ```bash
 $ cat Certificate.p12 | base64
 ```
 2. Prepare JSON with provider configuration
 ```json
{
    "type": "apns_cert",
    "payload": {
    "p12": "encoded base64 Certficiate.p12",
    "passphrase": "PASSWORD",
    "production": false,
    "appBundleId": "com.example.your_product_name",
}
 ```

## 3. Go to example [SenderSDK](https://github.com/ppgco/ppg-core-js-sdk/tree/main/examples/sender) docs 
 In examples please use prepared "providerConfig" and token returned from SDK to send notifications.