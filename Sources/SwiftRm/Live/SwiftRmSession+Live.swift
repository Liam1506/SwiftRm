//
//  File.swift
//  SwiftRm
//
//  Created by Liam Wittig on 05.04.26.
//

import Foundation


extension SwiftRmSession {
    
    
    public static func connect() async throws-> SwiftRmSession {
        let userToken = try await SwiftRmToken()
        
        let rootHash = try await getRootHash(userToken: userToken)
        
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
            fetchItem:  { entry in
                return try await fetchItem(entry: entry, userToken: userToken)
            }
            
            
        )
    }
    
    
    private static func fetchMetadata(hash: String, userToken: SwiftRmToken) async throws -> RmItem {
        let item: RmItem = try await SwiftRmNetwork.request(RemarkableConfig.blobUrl + hash, userToken: userToken)
        return item
    }
    
    private static func fetchIndex(hash: String, userToken: SwiftRmToken) async throws -> [RmIndexEntry] {
        
        let text: String = try await SwiftRmNetwork.requestText(RemarkableConfig.blobUrl + hash, userToken: userToken)
        
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
    
    private static func loadItems(userToken: SwiftRmToken) async throws -> [RmItem] {
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

    private static func fetchItem(entry: RmIndexEntry, userToken: SwiftRmToken) async throws -> RmItem? {
        let subIndex = try await fetchIndex(hash: entry.hash, userToken: userToken)
        guard let metaFile = subIndex.first(where: { $0.filename.hasSuffix(".metadata") }) else {
            return nil
        }
        var metadata = try await fetchMetadata(hash: metaFile.hash, userToken: userToken)
        let uuid = metaFile.filename.replacingOccurrences(of: ".metadata", with: "")
        metadata.hash = uuid
        return metadata
    }
    
    private static func getRootHash(userToken: SwiftRmToken) async throws -> String {
        let root: RmRoot = try await SwiftRmNetwork.request(RemarkableConfig.rootGet, userToken: userToken)
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
        return try await SwiftRmNetwork.registerDevice(token: token)
    }
}


