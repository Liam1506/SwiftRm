//
//  File.swift
//  SwiftRm
//
//  Created by Liam Wittig on 05.04.26.
//

import Foundation

public enum SwiftRmError: Error, LocalizedError {
    case invalidResponse
    case notFound
    case unauthorized
    case notRegistered
    
    public var errorDescription: String? {
        switch self {
        case .invalidResponse: "The server returned an invalid response"
        case .notFound:        "The requested resource was not found"
        case .unauthorized:    "You are not authorized to perform this action"
        case .notRegistered:   "The device is not registerd"
        }
    }
}
