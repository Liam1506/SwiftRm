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
    public let root =  RmFolder(hash: "", visibleName: "My files", parent: nil)
    
    public let trash =  RmFolder(hash: "trash", visibleName: "Trash", parent: "")
    
    public var items: [RmItem] = []
    
    init(session: SwiftRmSession) throws{
        self.session = session
        Task{
            
          try await loadFiles()
        }
    }
    
    public func loadFiles() async throws {
        self.items = try await SwiftRmCache(session: session).loadItems()//session.loadItems()
    
        try await buildTree()
    }
    
    public func buildTree() async throws {
        var folderMap: [String: RmFolder] = [
              "": root,
              "trash": trash
          ]
        
        
        for item in items where item.isFolder {
            let folder = RmFolder(hash: item.hash ?? "", visibleName: item.visibleName, parent: item.parent)
            folderMap[item.hash ?? ""] = folder
        }
        
        for item in items where item.isDocument {
            let doc = RmDocument(hash: item.hash ?? "", visibleName: item.visibleName, parent: item.parent, lastModified: item.lastModified)
            let parentFolder = folderMap[item.parent ?? ""] ?? root
            parentFolder.documents.append(doc)
        }
        
        for folder in folderMap.values where folder.hash != "" {
            let parentFolder = folderMap[folder.parent ?? ""] ?? root
            if(folder.hash != "trash"){
                parentFolder.folders.append(folder)
            }
        }
        
    }
    
}



