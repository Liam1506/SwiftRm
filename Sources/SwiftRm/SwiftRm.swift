// The Swift Programming Language
// https://docs.swift.org/swift-book

import os
import Foundation

@MainActor
public class SwiftRm {
    private let session: SwiftRmSession
    public let fileSystem: SwiftRmFileSystem

    private init(session: SwiftRmSession) throws {
        self.session = session
        self.fileSystem = try SwiftRmFileSystem(session: session)
    }

    public static func connect(config: RemarkableConfig = .remarkableCloud) async throws -> SwiftRm {
        let session = try await SwiftRmSession.connect(config: config)
        return try SwiftRm(session: session)
    }

    public static func isRegistered(for config: RemarkableConfig = .remarkableCloud) -> Bool {
        SwiftRmKeychain.has(config.keychainKey)
    }
}

public struct SwiftRmSession: @unchecked Sendable {
    public var fetchMetadata: (String) async throws -> RmItem
    public var fetchIndex: (String) async throws -> [RmIndexEntry]
    public var fetchBlobText: (String) async throws -> String
    public var downloadBlob: (String) async throws -> Data
    public var deleteSomething: (String) async throws -> Void
    public var moveItem: (String, String) async throws -> Void
    public var uploadDocument: (String, Data, String) async throws -> Void
    public var createFolder: (String, String) async throws -> Void
    public var getRootHash: () async throws -> String
    public var loadItems: () async throws -> [RmItem]
    public var fetchItem: (RmIndexEntry) async throws -> RmItem?

    public init(
        fetchMetadata: @escaping (String) async throws -> RmItem,
        fetchIndex: @escaping (String) async throws -> [RmIndexEntry],
        fetchBlobText: @escaping (String) async throws -> String,
        downloadBlob: @escaping (String) async throws -> Data,
        deleteSomething: @escaping (String) async throws -> Void,
        moveItem: @escaping (String, String) async throws -> Void,
        uploadDocument: @escaping (String, Data, String) async throws -> Void,
        createFolder: @escaping (String, String) async throws -> Void,
        getRootHash: @escaping () async throws -> String,
        loadItems: @escaping () async throws -> [RmItem],
        fetchItem: @escaping (RmIndexEntry) async throws -> RmItem?,

    ) {
        self.fetchMetadata = fetchMetadata
        self.fetchIndex = fetchIndex
        self.fetchBlobText = fetchBlobText
        self.downloadBlob = downloadBlob
        self.deleteSomething = deleteSomething
        self.moveItem = moveItem
        self.uploadDocument = uploadDocument
        self.createFolder = createFolder
        self.getRootHash = getRootHash
        self.loadItems = loadItems
        self.fetchItem = fetchItem
    }
}

