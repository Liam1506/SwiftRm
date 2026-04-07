//
//  File.swift
//  SwiftRm
//
//  Created by Liam Wittig on 07.04.26.
//

import Foundation

public struct RmItem: Codable, Sendable {
    public var hash: String?
    public let visibleName: String
    public let type: String        // "CollectionType" or "DocumentType"
    public let parent: String?
    public let lastModified: String?
    
    public var isFolder: Bool { type == "CollectionType" }
    public var isDocument: Bool { type == "DocumentType" }
}
