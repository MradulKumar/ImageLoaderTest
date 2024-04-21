//
//  ImageCache.swift
//  ImageLoaderApp
//
//  Created by Mradul Kumar on 20/04/24.
//

import UIKit
import Foundation

final class ImageCache: NSObject {
    static let shared = ImageCache()
    override private init() { }
}

extension ImageCache {
    
    func setImage(_ image: UIImage?, urlString: String) {
        guard let image = image else {
            self.removeImage(urlString: urlString)
            return
        }
        InMemoryCahce.shared.setImage(image, for: urlString)
        DiskCahce.shared.setImage(image, urlString: urlString)
    }
    
    func getImage(urlString: String) -> UIImage? {
        if let image = InMemoryCahce.shared.getImage(for: urlString) {
            return image
        }
        if let image = DiskCahce.shared.getImage(urlString: urlString) {
            InMemoryCahce.shared.setImage(image, for: urlString)
            return image
        }
        return nil
    }
    
    @discardableResult func removeImage(urlString: String) -> UIImage? {
        let memoryImage = InMemoryCahce.shared.removeImage(for: urlString)
        let diskImage = DiskCahce.shared.removeImage(urlString: urlString)
        return (memoryImage != nil) ? memoryImage : diskImage
    }
}


//MARK: - Disk Cache
final class DiskCahce: NSObject {
    static let shared = DiskCahce()
    private var imageCache: NSCache<AnyObject, AnyObject>
    override private init() {
        imageCache = NSCache<AnyObject, AnyObject>()
    }
}

extension DiskCahce {
    
    fileprivate func setImage(_ image: UIImage, urlString: String) {
        let path = NSTemporaryDirectory().appending(UUID().uuidString)
        let url = URL(fileURLWithPath: path)
        let data = image.pngData()
        try? data?.write(to: url)
        
        var dict = UserDefaults.standard.object(forKey: "ImageCache") as? [String: String]
        if dict == nil { dict = [String: String]() }
        dict![urlString] = path
        UserDefaults.standard.set(dict, forKey: "ImageCache")
        UserDefaults.standard.synchronize()
    }
    
    fileprivate func getImage(urlString: String) -> UIImage? {
        if let dict = UserDefaults.standard.object(forKey: "ImageCache") as? [String: String] {
            if let path = dict[urlString] {
                if let data = try? Data(contentsOf: URL(fileURLWithPath: path)) {
                    let img = UIImage(data: data)
                    return img
                }
            }
        }
        return nil
    }
    
    @discardableResult fileprivate func removeImage(urlString: String) -> UIImage? {
        if var dict = UserDefaults.standard.object(forKey: "ImageCache") as? [String: String] {
            if let path = dict[urlString] {
                let dataPath = URL(fileURLWithPath: path)
                try? FileManager.default.removeItem(at: dataPath)
            }
            dict.removeValue(forKey: urlString)
            UserDefaults.standard.set(dict, forKey: "ImageCache")
            UserDefaults.standard.synchronize()
        }
        return nil
    }
}

//MARK: - IN Memory Cache
final class InMemoryCahce: NSObject {
    static let shared = InMemoryCahce()
    private var imageCache: NSCache<AnyObject, AnyObject>
    override private init() {
        imageCache = NSCache<AnyObject, AnyObject>()
        imageCache.countLimit = 20
    }
}

extension InMemoryCahce {
    
    fileprivate func setImage(_ image: UIImage, for urlString: String) {
        guard let url = URL(string: urlString) else { return }
        imageCache.setObject(image, forKey: url as AnyObject)
    }
    
    fileprivate func getImage(for urlString: String) -> UIImage? {
        guard let url = URL(string: urlString) else { return nil }
        return imageCache.object(forKey: url as AnyObject) as? UIImage
    }
    
    @discardableResult fileprivate func removeImage(for urlString: String) -> UIImage? {
        guard let url = URL(string: urlString) else { return nil }
        let image = self.getImage(for: urlString)
        imageCache.removeObject(forKey: url as AnyObject)
        return image
    }
}
