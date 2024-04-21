//
//  NetworkManager.swift
//  ImageLoaderApp
//
//  Created by Mradul Kumar on 19/04/2024.
//

import Foundation

enum ApiError: Error {
    case noData
}

extension Error {
    
    var displayMessage: String {
        if let error = self as? ApiError {
            switch error {
            case .noData:
                return "No More Images To Show"
            }
        }
        
        return "Data Fetch Error"
    }
}

final class NetworkManager {
    
    var dataModels: [MediaCoverageData]? = nil
    
    private static var sharedNetworkManager: NetworkManager = {
        let networkManager = NetworkManager()
        return networkManager
    }()
    
    class func shared() -> NetworkManager {
        return sharedNetworkManager
    }
}

private extension NetworkManager {
    
    func getTestDataModels() -> [MediaCoverageData]? {
        if dataModels != nil  { return dataModels }
        
        let json = JsonUtility.shared.getTestJsonData()
        let dataModel = DataModel(json)
        let models = dataModel.data
        
        self.dataModels = models
        
        return models
    }
}

extension NetworkManager {
    
    public func getImageDataFor(page: Int, limit: Int) -> Result<[ImageData], ApiError> {
        
        guard let models = self.getTestDataModels() else { return .failure(ApiError.noData) }
        let count = models.count
        guard count > 0 else { return .failure(ApiError.noData) }
        
        let start = (page-1)*limit
        guard start < count else { return .failure(ApiError.noData) }

        let end = ((start + limit - 1) < (count - 1)) ? (start + limit - 1) : (count - 1)
        let resultModels = Array(models[start...end])
        let imageData = resultModels.compactMap({ data in
            return data.thumbnail
        })
        
        return Result.success(imageData)
    }
    
    public func getMediaCoverageData(at index: Int) -> MediaCoverageData? {
        guard let dataModels = self.dataModels else { return nil }
        guard dataModels.count > index else { return nil }
        return dataModels[index]
    }
}
