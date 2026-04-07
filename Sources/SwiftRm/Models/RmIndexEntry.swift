//
//  File.swift
//  SwiftRm
//
//  Created by Liam Wittig on 07.04.26.
//

import Foundation


public struct RmIndexEntry: Sendable {
    let hash: String
    let filename: String  // e.g. "uuid.metadata", "uuid.content", "uuid/page.rm"
    let size: Int
}
