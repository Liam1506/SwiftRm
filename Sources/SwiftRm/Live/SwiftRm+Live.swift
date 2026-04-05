//
//  File.swift
//  SwiftRm
//
//  Created by Liam Wittig on 05.04.26.
//

import Foundation


extension SwiftRm {
    
    
    public static func connect() async throws-> SwiftRm {
        guard let deviceToken = SwiftRmKeychain.load("remarkableDeviceToken") else {
            throw SwiftRmError.notRegistered
        }
        let userToken = try await renewUserToken(deviceToken: deviceToken)
        
        print(userToken)
        
        let rootHash = try await getRootHash(userToken: userToken)
        
        print("Root Hash: \(rootHash)")
        
        let index = try await fetchIndex(hash: rootHash, userToken: userToken)
         
         // each entry in index → another plain text index per document
         // that sub-index contains the .metadata file hash
         for entry in index {
             let docIndex = try await fetchIndex(hash: entry.hash, userToken: userToken)
             for file in docIndex {
                 if file.filename.hasSuffix(".metadata") {
                     // NOW this is safe to decode as JSON
                     let metadata = try await fetchMetadata(hash: file.hash, userToken: userToken)
                     print("Item: \(metadata.visibleName) isFolder: \(metadata.isFolder)")
                 }
             }
         }
        return SwiftRm (
            fetchSomething: { hash in
                let metaData = try await fetchMetadata(hash: hash, userToken: userToken)
                return metaData
            },
            deleteSomething: { id in
                
            }
        )
    }
    
    
    private static func renewUserToken(deviceToken: String) async throws -> String {
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
    
    private static func fetchMetadata(hash: String, userToken: String) async throws -> RmItem {
        var request = URLRequest(url: URL(string: RemarkableConfig.blobUrl + hash)!)
        request.httpMethod = "GET"
        request.setValue("Bearer \(userToken)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse,
              (200...299).contains(http.statusCode) else {
            throw SwiftRmError.invalidResponse
        }
        print(data)
        
        return try JSONDecoder().decode(RmItem.self, from: data)
    }
    
    private static func fetchIndex(hash: String, userToken: String) async throws -> [RmIndexEntry] {
        var request = URLRequest(url: URL(string: RemarkableConfig.blobUrl + hash)!)
        request.httpMethod = "GET"
        request.setValue("Bearer \(userToken)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse,
              (200...299).contains(http.statusCode) else {
            throw SwiftRmError.invalidResponse
        }

        let text = String(data: data, encoding: .utf8) ?? ""
        let lines = text.split(separator: "\n").dropFirst() // skip schema version line
        return lines.compactMap { line -> RmIndexEntry? in
            let parts = line.split(separator: ":")
            guard parts.count == 5 else { return nil }
            return RmIndexEntry(
                hash: String(parts[0]),
                filename: String(parts[2]),
                size: Int(parts[4]) ?? 0
            )
        }
    }
    
    private static func getRootHash(userToken: String) async throws -> String {
        var request = URLRequest(url: URL(string: RemarkableConfig.rootGet)!)
        request.httpMethod = "GET"
        request.setValue("Bearer \(userToken)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse,
              (200...299).contains(http.statusCode) else {
            throw SwiftRmError.invalidResponse
        }
        
        let root = try JSONDecoder().decode(RmRoot.self, from: data)
        return root.hash
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


struct RemarkableConfig {
    static let defaultDeviceDesc = "desktop-windows"
    
    // Auth
    static let deviceTokenURL = "https://webapp-prod.cloud.remarkable.engineering/token/json/2/device/new"
    static let userTokenURL   = "https://webapp-prod.cloud.remarkable.engineering/token/json/2/user/new"
    
    // Documents
    static let docHost = "https://document-storage-production-dot-remarkable-production.appspot.com"
    static let listDocs     = docHost + "/document-storage/json/2/docs"
    static let updateStatus = docHost + "/document-storage/json/2/upload/update-status"
    static let uploadRequest = docHost + "/document-storage/json/2/upload/request"
    static let deleteEntry  = docHost + "/document-storage/json/2/delete"
    
    // Sync
    static let syncHost = "https://internal.cloud.remarkable.com"
    static let uploadBlob   = syncHost + "/sync/v2/signed-urls/uploads"
    static let downloadBlob = syncHost + "/sync/v2/signed-urls/downloads"
    static let syncComplete = syncHost + "/sync/v2/sync-complete"
    
    // v3/v4
    static let blobUrl  = syncHost + "/sync/v3/files/"
    static let rootGet  = syncHost + "/sync/v4/root"
    static let rootPut  = syncHost + "/sync/v3/root"
}
