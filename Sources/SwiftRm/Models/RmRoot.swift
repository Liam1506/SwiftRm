//
//  File.swift
//  SwiftRm
//
//  Created by Liam Wittig on 07.04.26.
//

import Foundation


struct RmRoot: Codable {
    let hash: String
    let generation: Int
    let schemaVersion: Int?
}

struct RmRootPut: Codable {
    let hash: String
    let generation: Int
    let broadcast: Bool
}
