//
//  RmMetadata.swift
//  SwiftRm
//

import Foundation

struct RmMetadata: Codable {
    var visibleName: String
    var type: String
    var parent: String
    var lastModified: String
    var lastOpened: String
    var lastOpenedPage: Int
    var version: Int
    var metadataModified: Bool
    var pinned: Bool
    var synced: Bool
    var modified: Bool
    var deleted: Bool

    enum CodingKeys: String, CodingKey {
        case visibleName
        case type
        case parent
        case lastModified
        case lastOpened
        case lastOpenedPage
        case version
        case metadataModified = "metadatamodified"
        case pinned
        case synced
        case modified
        case deleted
    }
}
