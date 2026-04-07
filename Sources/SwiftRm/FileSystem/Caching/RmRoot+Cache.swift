//
//  File.swift
//  SwiftRm
//
//  Created by Liam Wittig on 07.04.26.
//

import Foundation
import SwiftData

struct RmRootCache{
    public static func getRootHashCache() -> String {
        return UserDefaults.standard.string(forKey: "rmRootHash") ?? ""
    }
    public static func setRootHashCache(hash: String) {
        UserDefaults.standard.set(hash, forKey: "rmRootHash")
    }
}
