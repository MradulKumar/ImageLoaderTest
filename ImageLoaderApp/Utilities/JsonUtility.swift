//
//  JsonUtility.swift
//  ImageLoaderApp
//
//  Created by Mradul Kumar on 19/04/24.
//

import Foundation

final class JsonUtility: NSObject {
    static let shared = JsonUtility()
    override private init() { }

    public func getTestJsonData() -> [Dictionary<String, Any>]? {
        guard let url = Bundle.main.url(forResource: "media-coverages", withExtension: "json") else { return nil }
        guard let jsonData = try? Data.init(contentsOf: url, options: Data.ReadingOptions.mappedIfSafe) else { return nil }
        return try? JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.mutableContainers) as? [Dictionary<String, Any>]
    }
}
