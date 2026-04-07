//
//  File.swift
//  SwiftRm
//
//  Created by Liam Wittig on 07.04.26.
//

import Foundation

struct SwiftRmNetwork{
    public static func request<T: Decodable>(_ path: String, userToken: SwiftRmToken, method: String = "GET") async throws -> T {
            let token = try await userToken.validToken()
            var request = URLRequest(url: URL(string: path)!)
            request.httpMethod = method
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
    
            let (data, response) = try await URLSession.shared.data(for: request)
            // Centralized status code check
            guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                throw SwiftRmError.invalidResponse
            }
            return try JSONDecoder().decode(T.self, from: data)
        }
    
    public static func requestText(_ path: String, userToken: SwiftRmToken, method: String = "GET") async throws -> String {
        let token =  try await userToken.validToken()
            var request = URLRequest(url: URL(string: path)!)
            request.httpMethod = method
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            let (data, response) = try await URLSession.shared.data(for: request)
            // Centralized status code check
            guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                throw SwiftRmError.invalidResponse
            }
            return try String(data: data, encoding: .utf8)!
        }
    
    
    public static func renewUserToken(deviceToken: String) async throws -> String {
        let url = URL(string: RemarkableConfig.userTokenURL)!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(deviceToken)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let http = response as? HTTPURLResponse,
              (200...299).contains(http.statusCode) else {
            throw SwiftRmError.invalidResponse
        }
        
        return String(data: data, encoding: .utf8) ?? ""
    }
    
    
    public static func registerDevice(token: String) async throws -> String {
        let uuid = UUID().uuidString.lowercased()
        let payload: [String: String] = [
            "code": token,
            "deviceDesc": RemarkableConfig.defaultDeviceDesc,
            "deviceID": uuid
        ]
        let body = try JSONEncoder().encode(payload)
        let url = URL(string: RemarkableConfig.deviceTokenURL)!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = body
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let http = response as? HTTPURLResponse,
              (200...299).contains(http.statusCode) else {
            throw SwiftRmError.invalidResponse
        }
        
        let deviceToken = String(data: data, encoding: .utf8) ?? ""
        
        // Save to Keychain
        SwiftRmKeychain.save("remarkableDeviceToken", deviceToken)
        
        return deviceToken
    }
}
