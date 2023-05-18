//
//  Data.swift
//  PpgCoreSDK
//
//  Created by Mateusz Worotyński on 29/03/2023.
//

import Foundation

extension Data {
    var imageExtension: String {
        switch self[0] {
        case 0x89:
            return ".png"
        case 0xFF:
            return ".jpg"
        case 0x47:
            return ".gif"
        default:
            break
        }
        return ".unknown"
    }
}
