//
//  Item.swift
//  SwiftRm
//
//  Created by Liam Wittig on 05.04.26.
//

// Sources/SwiftRm/Models/Item.swift
import Foundation

struct RmRoot: Codable {
    let hash: String
    let generation: Int
    let schemaVersion: Int
}

public struct RmIndexEntry: Sendable {
    let hash: String
    let filename: String  // e.g. "uuid.metadata", "uuid.content", "uuid/page.rm"
    let size: Int
}

public struct RmItem: Codable, Sendable {
    public var hash: String?
    public let visibleName: String
    public let type: String        // "CollectionType" or "DocumentType"
    public let parent: String?
    public let lastModified: String?
    
    public var isFolder: Bool { type == "CollectionType" }
    public var isDocument: Bool { type == "DocumentType" }
}

@Observable
public class RmDocument: Identifiable {
    public let hash: String
    public let visibleName: String
    public let parent: String?
    public let lastModified: String?
    
    init(hash: String, visibleName: String, parent: String?, lastModified: String?) {
        self.hash = hash
        self.visibleName = visibleName
        self.parent = parent
        self.lastModified = lastModified
    }
}

@Observable
public class RmFolder: Identifiable, Equatable, Hashable {
    public static func == (lhs: RmFolder, rhs: RmFolder) -> Bool {
        lhs.hash == rhs.hash
    }
    public func hash(into hasher: inout Hasher) {
            hasher.combine(id)
    }
    
    public let hash: String
    public let visibleName: String
    public let parent: String?
    public var documents: [RmDocument] = []
    public var folders: [RmFolder] = []
    
    init(hash: String, visibleName: String, parent: String?) {
        self.hash = hash
        self.visibleName = visibleName
        self.parent = parent
    }
}



public enum RmNodeType {
    case folder
    case document
}

