# **CORE** _by PushPushGo_ SDK for iOS

![GitHub tag (latest)](https://img.shields.io/github/v/tag/ppgco/ppg-core-ios-sdk?style=flat-square)
[![Discord](https://img.shields.io/discord/1108358192339095662?color=%237289DA&label=Discord&style=flat-square)](https://discord.gg/NVpUWvreZa)

## Product Info

**CORE** _by PushPushGo_ is a hassle-free building block for all your web and mobile push needs.

Send your transactional and bulk messages, and we'll take care of the rest.

#### What we offer:
 - Ready SDK for client/server integration - we have SDK for the most popular platforms.
 - Mobile and WebPush implementation (APNS, FCM, VAPID).
 - Transactional and bulk push notifications through API.
 - Hassle-free usage. Our servers handle traffic peaks and store images.
 - Event aggregation in bulk sent to your webhook for easy analysis or running your business logic.
 - GDPR-ready solution protecting private data in accordance with EU regulations.
 - No vendor lock-in - build and own your subscriber base (stateless solution).

#### What you get:
 - Cost-effective solution: pay for sent pushes, not for infrastructure, traffic, and storage.
 - Save time and effort on developing the sender and infrastructure.
 - Simple API interface for all channels with bulk support.
 - Support on our [Discord Server](https://discord.gg/NVpUWvreZa).
 - You can implement notification features your way.

#### Try it if:
 - You want to control the flow in your transactional messages and add a push notification channel.
 - You're looking for an easy push notifications tool for your organization, whether it's finance, e-commerce, online publishing, or any other sector.
 - You work in a software house and build solutions for your clients.
 - You want a hassle-free solution to focus on other tasks at hand.
 - You want to implement an on-premise solution for sending notifications.
 - You have issues with an in-house solution.
 - You're looking for a reliable provider and cooperation based on your needs.

## How it works

When client register for notifications you will get object with:
 - Credentials
 - Token/endpoint
 - Type of provider
 - Identifier of provider

We call this **Recipient** - it's your subscription data, store it in your database.

When you try to send message you will prepare:

 - **Bucket** - your temporary credentials bucket - this bucket can be reused any time, or recreated when credentials changed,

 - **Context** - your message - this context can be reused to send bulk messages or just used once when you send transactional message then is context is **temporary**

When you send message you will _authorize_ via **bucket** data, prepare message with **context** and send to **recipients** that can be bulked up to 1000 per request.

On the server side:
 - We validate and prepare the message body.
 - Then, we upload and resize images to our CDN.
 - Next, we connect and send to different providers.

On the client side:
 - Get notifications via our SDK in your App/Website.
 - When interacting with a notification, we collect events with our API.

On the server side:
 - We aggregate events and deliver them in bulk to your webhook endpoint.

### Architecture

![image](https://i.ibb.co/tst39rS/architecture.png "Architecture")

When a message is delivered to the device and interacts with the user, we collect events and pass them to our API. The collected events are resent to your webhook endpoint.

#### Webhooks events
During the journey of push we will trigger webhook events.

| Push Type    | Event      | Foreground | Background |
|---------|------------|------------|------------|
| Data    |            |            |            |
|         | delivered  | ✓          | ✓          |
|         | clicked    | ✓          | ✓          |
|         | sent       | ✓          | ✓          |
|         | close      | ✓          | ✓          |
| Silent<sup>1</sup>  |            |            |            |
|         | delivered  | ✓          | ✓          |
|         | sent       | ✓          | ✓          |

<small><sup>1</sup> - webpush doesn't support silent messages due to Push API implementation</small>

If `foreignId` field was passed with `receiver` then it will also be included in event in message.

Example events package:

```json
{
    "messages": [
        {
            "messageId": "8e3075f1-6b21-425a-bb4f-eeaf0eac93a2",
            "foreignId": "my_id",
            "result": {
                "kind": "delivered"
            },
            "ts": 1685009020243
        }
    ]
}
```

## Pricing

We charge $0.50 USD for every 1000 sent notifications.

## Support & Sales

Join our [Discord](https://discord.gg/NVpUWvreZa) to get support, your api key, talk or just keep an eye on it.

<sub>**CORE** _by PushPushGo_ is not the same as our main **PushPushGo** product - are you looking for [PushPushGo - Push Notifications Management Platform?](https://pushpushgo.com)</sub>

## Client side SDK - supported platforms / providers

| Platform | Provider | SDK        |
|----------|----------|------------|
| Android / Huawei  | FCM / HMS      | [CORE Android SDK](https://github.com/ppgco/ppg-core-android-sdk) |
| iOS | APNS      | [CORE iOS SDK](https://github.com/ppgco/ppg-core-ios-sdk) |
| Flutter | FCM / HMS / APNS      | [CORE Flutter SDK](https://github.com/ppgco/ppg-core-flutter-sdk) |
| Web | Vapid (WebPush)     | [CORE JS SDK](https://github.com/ppgco/ppg-core-js-sdk) |

## Server side SDK (sending notifications)
| Platform | SDK      |
|----------|----------|
| JavaScript / TypeScript  | [CORE JS SDK](https://github.com/ppgco/ppg-core-js-sdk) | 
| .NET  | [WIP - ask](https://discord.gg/NVpUWvreZa) | 
| Java  | [WIP - ask](https://discord.gg/NVpUWvreZa) | 

# SDK Integration instructions

## Requirements:
Access to Apple Developer Account.

## Environment setup
Initialize Podfile if already is not initialized

```bash
$ cd your_project_name
$ pod init
```

Open XCode Workspace instead of Project

## 1. Add dependencies to your project

Add to your target our library:

```sh
target 'your_project_name' do
  use_frameworks!
  pod 'PpgCoreSDK', '~> 0.0.11'
end
```

Then install pods and open xcode with workspace env

```sh
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
```sh
target 'NSE' do
  use_frameworks!
  pod 'PpgCoreSDK', '~> 0.0.11'
end
```
5. Install pods
```sh
$ pod install
```

### 3.1 Configure Notification Service Extension
1. Open file NotificationService.swift
2. Paste this code:
```swift
import UserNotifications
import PpgCoreSDK

class NotificationService: PpgCoreNotificationServiceExtension {
  override func onExternalData(data: String) {
    PpgCoreLogger.info("NSE RECEIVED EXTERNAL DATA" + data)
  }
}
```

## 4. If you do not have AppDelegate.swift create new one (SwiftUI).
1. Create AppDelegate.swift
```swift
import Foundation
import SwiftUI

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

/// Handles data "externalData" from notification (silent, data)
func onPpgCoreExternalData(data: String) -> Void {
    PpgCoreLogger.info("EXTERNAL DATA RECEIVED: " + data);
}

func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    UNUserNotificationCenter.current().delegate = self
    ppgCoreClient.initialize(actionLabels: ["Open", "Check more"], onExternalData: self.onPpgCoreExternalData)
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

7. (optional) If you need to overwrite endpoint or prepare channels (with customized actions) create PpgCore.plist

> Important: Select target for your **app and notification service extension**!

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>PpgCoreSDKEndpoint</key>
	<string>https://api-core.pushpushgo.com/v1</string>
	<key>PpgCoreChannels</key>
	<array>
		<dict>
			<key>name</key>
			<string>testing_channel</string>
			<key>sound</key>
			<string>Submarine.aiff</string>
			<key>actions</key>
			<array>
				<string>Reply</string>
			</array>
		</dict>
		<dict>
			<key>name</key>
			<string>testing_channel_nowy</string>
			<key>sound</key>
			<string>sub.caf</string>
			<key>actions</key>
			<array>
				<string>Open</string>
				<string>Show more</string>
			</array>
		</dict>
	</array>
</dict>
</plist>
```

# Sending notifications

## 1. Prepare certificates
 1. Go to [Apple Developer Portal - Identities](https://developer.apple.com/account/resources/identifiers/list) and go to **Identifiers** section
 2. Select from list your appBundleId like `com.example.your_project_name`
 3. Look for PushNotifications and click "**Configure**" button
 4. Select your __Certificate Singing Request__ file
 5. Download Certificates and open in KeyChain Access (double click in macos)
 6. Find this certificate in list select then in context menu (right click) select export and export to .p12 format file with password.

## 2. Prepare configuration
 1. Wrap exported certficates with Base64 with command
 ```sh
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

# Support & production run
All API keys available in this documentation allows you to test service with very low rate-limits.
If you need production credentials or just help with integration please visit us in [discord](https://discord.gg/NVpUWvreZa) or just mail to [support+core@pushpushgo.com](mailto:support+core@pushpushgo.com)
