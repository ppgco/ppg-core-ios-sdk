//
//  UNNotificationAttachment.swift
//  PpgCoreSDK
//
//  Created by Mateusz Worotyński on 29/03/2023.
//

import Foundation
import UserNotifications

extension UNNotificationAttachment {
    
    static func downloadFromUrl(url: String) throws -> TemporaryImage? {
        let fileManager = FileManager.default
        let temporaryFolderName = ProcessInfo.processInfo.globallyUniqueString
        let temporaryFolderURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(temporaryFolderName, isDirectory: true)

        try fileManager.createDirectory(at: temporaryFolderURL, withIntermediateDirectories: true, attributes: nil)

        guard let imageData = try? Data(contentsOf: URL(string: url)!) else {
            return nil
        }
                
        let imageFileIdentifier = UUID().uuidString + imageData.imageExtension
        let fileURL = temporaryFolderURL.appendingPathComponent(imageFileIdentifier)
        
        return TemporaryImage(
          data: imageData, path: fileURL, id: imageFileIdentifier
        )
    }
    
    convenience init?(url: String) throws {
        guard let image = try? UNNotificationAttachment.downloadFromUrl(url: url) else {
            return nil
        }
        
        try image.data.write(to: image.path)
        try self.init(identifier: image.id, url: image.path, options: [:])
    }
}
