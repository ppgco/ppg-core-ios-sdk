//
//  PpgCoreLogger.swift
//  PpgCoreSDK
//
//  Created by Mateusz Worotyński on 30/03/2023.
//

import Foundation
import os.log

public class PpgCoreLogger {
  
    public static var _enabled: Bool = true;
  
    public static func disable() -> Void {
        PpgCoreLogger._enabled = false;
    }
    
    public static func enable() -> Void {
        PpgCoreLogger._enabled = true;
    }
  
    public static func error(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message: message, level: .error, file: file, function: function, line: line)
    }
    
    public static func info(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message: message, level: .info, file: file, function: function, line: line)
    }
    
    private static func log(message: String, level: OSLogType, file: String, function: String, line: Int) {
        if (PpgCoreLogger._enabled == false) {
          return;
        }
      
        let fileName = (file as NSString).lastPathComponent
        let log = OSLog(subsystem: Bundle.main.bundleIdentifier ?? "NA", category: fileName)
        os_log("[%{public}@:%{public}@:%d] %{public}@", log: log, type: level, fileName, function, line, message)
    }
}
