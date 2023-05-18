//
//  sdkdemoApp.swift
//  sdkdemo
//
//  Created by Mateusz Worotyński on 18/05/2023.
//

import SwiftUI

@main
struct sdkdemoApp: App {
  
  @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

  var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
