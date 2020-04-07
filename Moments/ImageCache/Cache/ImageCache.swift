//
//  ImageCache.swift
//  Moments
//
//  Created by zhangchenglong01 on 2020/4/1.
//  Copyright © 2020 zhangchenglong01. All rights reserved.
//

import Foundation

#if os(macOS)
import AppKit
#else
import UIKit
#endif

public enum CacheType {
    case none
    case memory
    case disk
    public var cached: Bool {
        switch self {
        case .memory, .disk: return true
        case .none: return false
        }
    }
}

public struct CacheStoreResult {
    public let memoryCacheResult: Result<(), Never>
    public let diskCacheResult: Result<(), ImageCacheError>
}

public enum CacheResult {
    case disk(UIImage)
    case memory(UIImage)
    case none
    
    public var image: UIImage? {
        switch self {
        case .disk(let image): return image
        case .memory(let image): return image
        case .none: return nil
        }
    }
    
    public var cacheType: CacheType {
        switch self {
        case .disk: return .disk
        case .memory: return .memory
        case .none: return .none
        }
    }
}

extension UIImage: Storageable {
    
}

extension Data: DataTransformable {
    public func toData() throws -> Data {
        return self
    }
    
    public static func fromData(_ data: Data) throws -> Data {
        return data
    }
    
    public static let empty = Data()
}

// accessable not subclassable
public class ImageCache {
    public static let `default` = ImageCache(name: "default")
    public let memoryStorage: MemoryStorage.Backend<UIImage>
    public let diskStorage: DiskStorage.Backend<Data>
    
    private let ioQueue: DispatchQueue
    
    /// Closure that defines the disk cache path from a given path and cacheName.
    public typealias DiskCachePathClosure = (URL, String) -> URL

    public init(memoryStorage: MemoryStorage.Backend<UIImage>, diskStorage: DiskStorage.Backend<Data>) {
        self.memoryStorage = memoryStorage
        self.diskStorage = diskStorage
        ioQueue = DispatchQueue(label: "com.Alex.ImageCache.ioQueue.\(UUID().uuidString)")

        let notifications: [(Notification.Name, Selector)] = [
            (UIApplication.didReceiveMemoryWarningNotification, #selector(clearMemoryCache)),
            (UIApplication.willTerminateNotification, #selector(cleanExpiredDiskCache))]
      
        notifications.forEach {
            NotificationCenter.default.addObserver(self, selector: $0.1, name: $0.0, object: nil)
        }
    }

    public convenience init(name: String) {
        try! self.init(name: name, cacheDirectoryURL: nil, diskCachePathClosure: nil)
    }

    public convenience init(name: String,
                            cacheDirectoryURL: URL?,
                            diskCachePathClosure: DiskCachePathClosure? = nil) throws
    {
        if name.isEmpty {
            fatalError("[] You should specify a name for the cache. A cache with empty name is not permitted.")
        }

        let totalMemory = ProcessInfo.processInfo.physicalMemory
        let costLimit = totalMemory / 4
        let memoryStorage = MemoryStorage.Backend<UIImage>(config:
            .init(totalCostLimit: (costLimit > Int.max) ? Int.max : Int(costLimit)))

        var diskConfig = DiskStorage.Config(
            name: name,
            sizeLimit: 0,
            directory: cacheDirectoryURL
        )
        if let closure = diskCachePathClosure {
            diskConfig.cachePathBlock = closure
        }
        let diskStorage = try DiskStorage.Backend<Data>(config: diskConfig)
        diskConfig.cachePathBlock = nil

        self.init(memoryStorage: memoryStorage, diskStorage: diskStorage)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func imageCachedType(forKey key: String) -> CacheType {
        if memoryStorage.isCached(forKey: key) { return .memory }
        if diskStorage.isCached(forKey: key) { return .disk }
        return .none
    }
    
    // MARK: Storing Images

    func store(_ image: UIImage,
               original: Data? = nil,
               forKey key: String,
               options: ImageCacheOptions,
               toDisk: Bool = true,
               completionHandler: ((CacheStoreResult) -> Void)? = nil)
    {
        // Memory storage should not throw.
        memoryStorage.storeNoThrow(value: image, forKey: key, expiration: options.memoryCacheExpiration)
        
        guard toDisk else {
            if let completionHandler = completionHandler {
                let result = CacheStoreResult(memoryCacheResult: .success(()), diskCacheResult: .success(()))
                DispatchQueue.main.async {
                    completionHandler(result)
                }
            }
            return
        }
        
        ioQueue.async {
            if let data = ImageSerializer.default.data(with: image) {
                self.syncStoreToDisk(
                    data,
                    forKey: key,
                    expiration: options.diskCacheExpiration,
                    completionHandler: completionHandler)
            } else {
                // guard let completionHandler = completionHandler else { return }
                // error
            }
        }
    }
    
    private func syncStoreToDisk(
        _ data: Data,
        forKey key: String,
        expiration: StorageExpiration? = nil,
        completionHandler: ((CacheStoreResult) -> Void)? = nil)
    {
        //let result: CacheStoreResult
        do {
            try self.diskStorage.store(value: data, forKey: key, expiration: expiration)
            //result = CacheStoreResult(memoryCacheResult: .success(()), diskCacheResult: .success(()))
        } catch {
            
        }
        //if let completionHandler = completionHandler {
            //callbackQueue.execute { completionHandler(result) }
        //}
    }

    public func removeImage(forKey key: String,
                          fromMemory: Bool = true,
                          fromDisk: Bool = true,
                          completionHandler: (() -> Void)? = nil)
    {

        if fromMemory {
            try? memoryStorage.remove(forKey: key)
        }
        
        if fromDisk {
            ioQueue.async{
                try? self.diskStorage.remove(forKey: key)
                //if let completionHandler = completionHandler {
                    //callbackQueue.execute { completionHandler() }
                //}
            }
        } else {
            //if let completionHandler = completionHandler {
                //callbackQueue.execute { completionHandler() }
            //}
        }
    }

    func retrieveImage(forKey key: String,
                       options: ImageCacheOptions,
                       completionHandler: ((Result<UIImage, ImageCacheError>) -> Void)?)
    {
        guard let completionHandler = completionHandler else { return }

        if let image = retrieveImageInMemoryCache(forKey: key, options: options) {
            DispatchQueue.main.async {
                completionHandler(.success(image))
            }
        } else {
            // Begin to disk search.
            self.retrieveImageInDiskCache(forKey: key, options: options) {
                result in
                switch result {
                case .success(let image):
                    guard let image = image else {
                        return
                    }
                    DispatchQueue.main.async {
                        completionHandler(.success(image))
                    }
                    break
                case .failure:
                    DispatchQueue.main.async {
                        completionHandler(.failure(.retriveDataFromDiskError))
                    }
                    break
        
                }
            }
        }
    }

    func retrieveImageInMemoryCache(
        forKey key: String,
        options: ImageCacheOptions) -> UIImage?
    {
        return memoryStorage.value(forKey: key, extendingExpiration: options.memoryCacheAccessExtendingExpiration)
    }

    func retrieveImageInDiskCache(
        forKey key: String,
        options: ImageCacheOptions,
        completionHandler: @escaping (Result<UIImage?, ImageCacheError>) -> Void)
    {
        var image: UIImage? = nil
        //do {
            if let data = try? self.diskStorage.value(forKey: key, extendingExpiration: .cacheTime) {
                image = ImageSerializer.default.image(with: data)
            } else {
                DispatchQueue.main.async {
                    completionHandler(.success(nil))
                }
            }
        //} catch {
            
        //}
       
        DispatchQueue.main.async {
            completionHandler(.success(image))
        }
    }
    
    @objc public func clearMemoryCache() {
        try? memoryStorage.removeAll()
    }

    open func clearDiskCache(completion handler: (()->())? = nil) {
        ioQueue.async {
            do {
                try self.diskStorage.removeAll()
            } catch _ { }
            if let handler = handler {
                DispatchQueue.main.async { handler() }
            }
        }
    }

    open func cleanExpiredMemoryCache() {
        memoryStorage.removeExpired()
    }
    
    @objc func cleanExpiredDiskCache() {
        cleanExpiredDiskCache(completion: nil)
    }

    open func cleanExpiredDiskCache(completion handler: (() -> Void)? = nil) {
        
    }
}

extension Dictionary {
    func keysSortedByValue(_ isOrderedBefore: (Value, Value) -> Bool) -> [Key] {
        return Array(self).sorted{ isOrderedBefore($0.1, $1.1) }.map{ $0.0 }
    }
}


