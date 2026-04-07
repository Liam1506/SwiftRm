//
//  File.swift
//  SwiftRm
//
//  Created by Liam Wittig on 07.04.26.
//

import Foundation

actor SwiftRmToken {
    private var currentToken: String
    private let deviceToken: String
    
    init() async throws {
        guard let deviceToken = SwiftRmKeychain.load("remarkableDeviceToken") else {
            throw SwiftRmError.notRegistered
        }
        self.deviceToken = deviceToken
        self.currentToken = try await SwiftRmNetwork.renewUserToken(deviceToken: deviceToken)
    }
    
    public func validToken() async throws -> String {
        if isExpired(currentToken) {
            currentToken = try await SwiftRmNetwork.renewUserToken(deviceToken: deviceToken)
        }
        return currentToken
    }
    
    private func isExpired(_ token: String) -> Bool {
        let parts = token.split(separator: ".")
        guard parts.count == 3 else { return true }
        
        var base64 = String(parts[1])
        let remainder = base64.count % 4
        if remainder > 0 {
            base64 += String(repeating: "=", count: 4 - remainder)
        }
        
        guard let data = Data(base64Encoded: base64),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let exp = json["exp"] as? TimeInterval else {
            return true
        }
        
        return Date(timeIntervalSince1970: exp) < Date().addingTimeInterval(300)
    }
}
