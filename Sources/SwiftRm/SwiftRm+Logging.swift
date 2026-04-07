//
//  File.swift
//  SwiftRm
//
//  Created by Liam Wittig on 07.04.26.
//

import Foundation
import os

struct Log {
    private static let logger = Logger(subsystem: "SwiftRm", category: "API")

    static func msg(_ message: String, level: OSLogType = .info) {
        switch level {
        case .debug: logger.debug("\(message)")
        case .error: logger.error("\(message)")
        case .fault: logger.fault("\(message)")
        default:     logger.info("\(message)")
        }
    }
}
