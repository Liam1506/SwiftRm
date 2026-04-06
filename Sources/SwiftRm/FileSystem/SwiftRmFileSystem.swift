//
//  File.swift
//  SwiftRm
//
//  Created by Liam Wittig on 06.04.26.
//

import Foundation


@Observable
@MainActor
public class SwiftRmFileSystem{
    public let session: SwiftRmSession
    public var items: [RmItem] = []
    public let root =  RmFolder(hash: "", visibleName: "Root", parent: nil)
    
    init(session: SwiftRmSession) throws{
        self.session = session
        Task{
            
          try await loadFiles()
        }
    }
    
    public func loadFiles() async throws {
        print("Loading root")
        print("Root nodes fetched")
        self.items = try await session.loadItems()
    
        try await buildTree()
    }
    
    public func buildTree() async throws {
        var folderMap: [String: RmFolder] = ["": root]
        
        // Create all folders
        for item in items where item.isFolder {
            let folder = RmFolder(hash: item.hash ?? "", visibleName: item.visibleName, parent: item.parent)
            folderMap[item.hash ?? ""] = folder
        }
        
        // Attach documents to parent folders
        for item in items where item.isDocument {
            let doc = RmDocument(hash: item.hash ?? "", visibleName: item.visibleName, parent: item.parent, lastModified: item.lastModified)
            let parentFolder = folderMap[item.parent ?? ""] ?? root
            parentFolder.documents.append(doc)
        }
        
        // Attach folders to parent folders
        for folder in folderMap.values where folder.hash != "" {
            let parentFolder = folderMap[folder.parent ?? ""] ?? root
            parentFolder.folders.append(folder)
        }
        
        print("Root folders: \(root.folders.count)")
        print("Root documents: \(root.documents.count)")
    }
    
}



