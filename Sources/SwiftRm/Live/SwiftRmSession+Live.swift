//
//  File.swift
//  SwiftRm
//
//  Created by Liam Wittig on 05.04.26.
//

import Foundation


extension SwiftRmSession {
    
    
    public static func connect() async throws-> SwiftRmSession {
        guard let deviceToken = SwiftRmKeychain.load("remarkableDeviceToken") else {
            throw SwiftRmError.notRegistered
        }
        let userToken = try await renewUserToken(deviceToken: deviceToken)
        
        print(userToken)
        
        let rootHash = try await getRootHash(userToken: userToken)
        
        print("Root Hash: \(rootHash)")
        
       /* let index = try await fetchIndex(hash: rootHash, userToken: userToken)
         
         // each entry in index → another plain text index per document
         // that sub-index contains the .metadata file hash
         for entry in index {
             let docIndex = try await fetchIndex(hash: entry.hash, userToken: userToken)
             print("Document Index: \(docIndex)")
             for file in docIndex {
                 print("File: \(file)")
                 if file.filename.hasSuffix(".metadata") {
                     // NOW this is safe to decode as JSON
                     let metadata = try await fetchMetadata(hash: file.hash, userToken: userToken)
                     print("Item: \(metadata.visibleName) isFolder: \(metadata.isFolder)")
                 }
             }
         }*/
        return SwiftRmSession (
            fetchMetadata: { hash in
                let metaData = try await fetchMetadata(hash: hash, userToken: userToken)
                return metaData
            },
            fetchIndex: { hash in
                            
              let index = try await fetchIndex(hash: hash, userToken: userToken)
                return index;
            },
        
            deleteSomething: { id in
                
            },
            getRootHash: {
                let rootHash = try await getRootHash(userToken: userToken)
                return rootHash
            },
            loadItems: {
                            
                            return try await loadItems(userToken: userToken)
                        },
            
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
        print("Successfully fetched metadata")
      
        
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
        
        print("Fetched")
        print(text)
        let lines = text.split(separator: "\n").dropFirst()
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
    
    private static func loadItems(userToken: String) async throws -> [RmItem] {
        let rootHash = try await getRootHash(userToken: userToken)
        let rootIndex = try await fetchIndex(hash: rootHash, userToken: userToken)
        
        return try await withThrowingTaskGroup(of: RmItem?.self) { group in
            var active = 0
            var iterator = rootIndex.makeIterator()
            var results: [RmItem] = []
            
            while active < 20, let entry = iterator.next() {
                group.addTask { try await fetchItem(entry: entry, userToken: userToken) }
                active += 1
            }
            
            for try await result in group {
                if let result { results.append(result) }
                if let entry = iterator.next() {
                    group.addTask { try await fetchItem(entry: entry, userToken: userToken) }
                }
            }
            
            return results
        }
    }

    private static func fetchItem(entry: RmIndexEntry, userToken: String) async throws -> RmItem? {
        let subIndex = try await fetchIndex(hash: entry.hash, userToken: userToken)
        guard let metaFile = subIndex.first(where: { $0.filename.hasSuffix(".metadata") }) else {
            return nil
        }
        var metadata = try await fetchMetadata(hash: metaFile.hash, userToken: userToken)
        let uuid = metaFile.filename.replacingOccurrences(of: ".metadata", with: "")
        metadata.hash = uuid
        return metadata
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



extension SwiftRm {
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


