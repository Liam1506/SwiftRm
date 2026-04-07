// The Swift Programming Language
// https://docs.swift.org/swift-book


@MainActor
public class SwiftRm {
    private let session: SwiftRmSession
    public let fileSystem: SwiftRmFileSystem

    private init(session: SwiftRmSession) throws {
        self.session = session
        self.fileSystem = try SwiftRmFileSystem(session: session)
    }

    public static func connect() async throws -> SwiftRm {
        let session = try await SwiftRmSession.connect()
        return try SwiftRm(session: session)
    }
    
    public static func refreshSession() async throws{
        let session = try await SwiftRmSession.connect()
    }
}

public struct SwiftRmSession {
    public var fetchMetadata: (String) async throws -> RmItem
    public var fetchIndex: (String) async throws -> [RmIndexEntry]
    public var deleteSomething: (String) async throws -> Void
    public var getRootHash: () async throws -> String
    public var loadItems: () async throws -> [RmItem]
    public var fetchItem: (RmIndexEntry) async throws -> RmItem?
    
    public init(
        fetchMetadata: @escaping (String) async throws -> RmItem,//[Item],
        fetchIndex: @escaping (String) async throws -> [RmIndexEntry],
        deleteSomething: @escaping (String) async throws -> Void,
        getRootHash: @escaping () async throws -> String,
        loadItems: @escaping () async throws -> [RmItem],
        fetchItem: @escaping (RmIndexEntry) async throws -> RmItem?,
        
    ) {
        self.fetchMetadata = fetchMetadata
        self.fetchIndex = fetchIndex
        self.deleteSomething = deleteSomething
        self.getRootHash = getRootHash
        self.loadItems = loadItems
        self.fetchItem = fetchItem
    }
}

