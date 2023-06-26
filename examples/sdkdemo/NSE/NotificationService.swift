//
//  NotificationService.swift
//  NSE
//
//  Created by Mateusz Worotyński on 18/05/2023.
//

import UserNotifications
import PpgCoreSDK

class NotificationService: PpgCoreNotificationServiceExtension {
  override func onExternalData(data: String) {
    PpgCoreLogger.error("NSE RECEIVED EXTERNAL DATA" + data)
  }
}
