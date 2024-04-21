//
//  ImageCell.swift
//  ImageLoaderApp
//
//  Created by Mradul Kumar on 19/04/2024.
//

import UIKit

class ImageCell: UICollectionViewCell {
    
    @IBOutlet weak var imgView:UIImageView!
    var imgData: ImageData?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.imgView.image = nil
        self.imgData = nil
        self.setUpUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.imgView.image = nil
    }
    
    func setUpUI() {
        self.backgroundColor = UIColor(red: 31, green: 31, blue: 31, alpha: 0.2)
        self.imgView.backgroundColor = .clear
        self.imgView.contentMode = .scaleAspectFill
        
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 4.0
    }
    
    func setDownloadingPriorityLow() {
        URLSession.shared.getAllTasks { (openTasks : [URLSessionTask]) in
            for task in openTasks {
                task.priority = URLSessionTask.lowPriority
            }
        }
    }
    
    func loadImage() {
        let imageUrl = self.imgData!.thumbnailUrl
        guard let imageUrl = imageUrl else {
            self.imgView.image = nil
            return
        }
        
        guard imageUrl.absoluteString.count > 0 else {
            self.imgView.image = nil
            return
        }
        
        if let image = ImageCache.shared.getImage(urlString: imageUrl.absoluteString) {
            self.imgView.image = image
            return
        }
        
        let request:URLRequest = URLRequest.init(url: imageUrl,
                                                 cachePolicy: URLRequest.CachePolicy.returnCacheDataElseLoad,
                                                 timeoutInterval: 600.0)
        let session = URLSession.shared
        let downloadTask = session.dataTask(with: request) { (data, response, error) in
            if let e = error {
                print("Error in downloading picture: \(e), url: \(imageUrl.absoluteString)")
            } else {
                if let resposne = response as? HTTPURLResponse {
                    if let imageData = data {
                        if let image = UIImage(data: imageData) {
                            ImageCache.shared.setImage(image, urlString: imageUrl.absoluteString)
                            DispatchQueue.main.async {
                                self.imgView.image = image
                            }
                        } else {
                            DispatchQueue.main.async {
                                self.imgView.image = nil
                            }
                        }
                    } else {
                        print("Image is nil, can't be created from data")
                    }
                } else {
                    print("Response error! Response is not HTTPURLResponse")
                }
            }
        }
        
        downloadTask.priority = URLSessionTask.highPriority
        downloadTask.resume()
    }
    
    func stopLoadingImage() {
        self.setDownloadingPriorityLow()
    }
}
