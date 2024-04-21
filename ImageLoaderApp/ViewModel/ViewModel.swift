//
//  ViewModel.swift
//  ImageLoaderApp
//
//  Created by Mradul Kumar on 19/04/24.
//

import Foundation

protocol ViewModelInput: NSObject {
    func loadData()
    func fetchMoreData()
    func showDetailsForArticle(at index: Int)
}

protocol ViewModelOutput: NSObject {
    func reloadData(_ imageData: [ImageData])
    func updateData(_ newImageData: [ImageData])
    func error(_ error: ApiError)
    func showSafariControllerFor(urlToOpen: String)
}

class ViewModel: NSObject {
    var fetching = false
    var page = 1
    var limit = 20
    var imagesData: [ImageData] = []
    weak var output: ViewModelOutput?
}

private extension ViewModel {
    
    func getImageData() -> Result<[ImageData], ApiError> {
        page = 1
        return NetworkManager.shared().getImageDataFor(page: page, limit: limit)
    }
    
    func getMoreImageData() -> Result<[ImageData], ApiError> {
        page = page + 1
        return NetworkManager.shared().getImageDataFor(page: page, limit: limit)
    }
}

extension ViewModel: ViewModelInput {
    
    func loadData() {
        guard fetching == false else { return }
        fetching = true
        let result = self.getImageData()
        switch result {
        case .success(let result):
            self.imagesData = result
            self.output?.reloadData(self.imagesData)
            fetching = false
        case .failure(let error):
            self.output?.error(error)
            fetching = false
        }
    }
    
    func fetchMoreData() {
        guard fetching == false else { return }
        fetching = true
        let result = self.getMoreImageData()
        switch result {
        case .success(let result):
            self.imagesData.append(contentsOf: result)
            self.output?.updateData(self.imagesData)
            fetching = false
        case .failure(let error):
            self.output?.error(error)
            fetching = false
        }
    }
    
    func showDetailsForArticle(at index: Int) {
        guard let data = NetworkManager.shared().getMediaCoverageData(at: index) else { return }
        guard let urlToOpen = data.urlToOpen else { return }
        self.output?.showSafariControllerFor(urlToOpen: urlToOpen)
    }
}
