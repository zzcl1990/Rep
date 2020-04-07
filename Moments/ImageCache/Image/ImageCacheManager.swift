//
//  ImageCacheManager.swift
//  Moments
//
//  Created by zhangchenglong01 on 2020/4/3.
//  Copyright © 2020 zhangchenglong01. All rights reserved.
//

import Foundation
import UIKit

typealias CompletionClosure = (CompletionReslut<UIImage>) -> Void

class ImageCacheManager {
    public static let `default` = ImageCacheManager()
    public var cache: ImageCache = .default
    public var downloader: ImageDownloader = .default
    
    init() {
        
    }
    
    func retrieveImage(with url: URL, completionHanler: @escaping CompletionClosure) {
        let loadedFromCache = retriveFromCache(with: url, completionHanler: completionHanler)
        if loadedFromCache {
            return
        }
        downloadImage(with: url, completionHanler: completionHanler)
    }
    
    func retriveFromCache(with url: URL, completionHanler: @escaping CompletionClosure) -> Bool{
        let key = url.absoluteString
        let cached = cache.imageCachedType(forKey: key).cached
        if cached {
            cache.retrieveImage(forKey: key, options: ImageCacheOptions()) { (result) in
                switch result {
                case .success(let image):
                    completionHanler(CompletionReslut(value: image))
                    break
                case .failure:
                    completionHanler(.failure(.retriveDataFromDiskError))
                    break
                }
            }
            return true
        }
        return false
    }
    
    func downloadImage(with url: URL, completionHanler: @escaping CompletionClosure) {
        let onCompleted = completionHanler
        func _cacheImage(result: CompletionReslut<UIImage>) {
            switch result {
            case .success(let image):
                self.cache.store(image, forKey: url.absoluteString, options: ImageCacheOptions())
                onCompleted(CompletionReslut.init(value: image))
                break
            case .failure(let error):
                onCompleted(.failure(error))
                break
            }
        }
        downloader.downloadImage(with: url, completionHandler: _cacheImage)
    }
    
    func storeToMemory() {
        
    }
    
    func storeToDisk() {
        
    }
}
