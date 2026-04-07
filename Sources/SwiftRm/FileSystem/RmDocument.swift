//
//  File.swift
//  SwiftRm
//
//  Created by Liam Wittig on 07.04.26.
//

import Foundation

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
