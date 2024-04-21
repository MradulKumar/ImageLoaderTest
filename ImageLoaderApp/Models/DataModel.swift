//
//  DataModel.swift
//  ImageLoaderApp
//
//  Created by Mradul Kumar on 19/04/2024.
//

import Foundation
import UIKit

class DataModel {
    private (set) var data: [MediaCoverageData]? = nil
    
    init(_ jsonData: [Dictionary<String, Any>]?) {
        if let jsonData = jsonData {
            let decoder = JSONDecoder()
            if let dataObj = try? JSONSerialization.data(withJSONObject: jsonData, options: []) {
                self.data = try? decoder.decode([MediaCoverageData].self, from: dataObj)
            }
        }
    }
}

struct MediaCoverageData: Codable {
    var id: String?
    var title: String?
    var language: String?
    var thumbnail: ImageData?
    var mediaType: Int?
    var coverageURL: String?
    var publishedAt: String?
    var publishedBy: String?
    var backupDetails: BackupData?
    
    var urlToOpen: String? {
        if let pdfLink = backupDetails?.pdfLink, pdfLink.count > 0 { return pdfLink }
        return coverageURL
    }
}

struct ImageData: Codable {
    var id: String?
    var version: Int?
    var domain: String?
    var basePath: String?
    var key: String?
    var qualities: [Int]?
    var aspectRatio: Float?
    
    var thumbnailUrl: URL? {
        var url: String = ""
        if let domain = domain {
            url = url + domain
        }
        if let basePath = basePath {
            url = url + "/" + basePath
        }
        if let key = key {
            url = url + "/0/" + key
        }
        return URL(string: url)
    }
}

struct BackupData: Codable {
    var pdfLink: String?
    var screenshotURL: String?
}
