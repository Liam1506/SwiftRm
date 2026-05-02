//
//  RmIndexEntry.swift
//  SwiftRm
//

import Foundation

public struct RmIndexEntry: Sendable {
    let hash: String
    let type: String
    let filename: String
    let subfiles: Int
    let size: Int
}
