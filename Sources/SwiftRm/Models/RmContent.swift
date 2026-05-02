//
//  RmContent.swift
//  SwiftRm
//

import Foundation

struct RmContent: Codable {
    var coverPageNumber: Int = -1
    var dummyDocument: Bool = false
    var extraMetadata: ExtraMetadataContent = ExtraMetadataContent()
    var fileType: String
    var fontName: String = ""
    var formatVersion: Int = 2
    var lastOpenedPage: Int = 0
    var lineHeight: Int = -1
    var margins: Int = 180
    var orientation: String = "portrait"
    var originalPageCount: Int = -1
    var pageCount: Int = 0
    var pages: [String] = []
    var pageTags: [RmPageTag] = []
    var redirectionPageMap: [Int] = []
    var sizeInBytes: Int = 0
    var tags: [RmTag] = []
    var textAlignment: String = "justify"
    var textScale: Float = 1
    var zoomMode: String = "bestFit"
}

struct ExtraMetadataContent: Codable {
    var LastBrushColor: String = ""
    var LastBrushThicknessScale: String = ""
    var LastColor: String = ""
    var LastEraserThicknessScale: String = ""
    var LastEraserTool: String = ""
    var LastPen: String = "Finelinerv2"
    var LastPenColor: String = ""
    var LastPenThicknessScale: String = ""
    var LastPencil: String = ""
    var LastPencilColor: String = ""
    var LastPencilThicknessScale: String = ""
    var LastTool: String = "Finelinerv2"
    var ThicknessScale: String = ""
    var LastFinelinerv2Size: String = "1"
}

struct RmPageTag: Codable {
    var name: String
    var pageId: String
    var timestamp: Int64
}

struct RmTag: Codable {
    var name: String
}
