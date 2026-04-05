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

struct RmIndexEntry {
    let hash: String
    let filename: String  // e.g. "uuid.metadata", "uuid.content", "uuid/page.rm"
    let size: Int
}

public struct RmItem: Codable {
    public let visibleName: String
    public let type: String        // "CollectionType" or "DocumentType"
    public let parent: String?
    public let lastModified: String?
    
    public var isFolder: Bool { type == "CollectionType" }
    public var isDocument: Bool { type == "DocumentType" }
}
