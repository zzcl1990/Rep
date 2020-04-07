//
//  ImageDownloader.swift
//  Moments
//
//  Created by zhangchenglong01 on 2020/4/3.
//  Copyright © 2020 zhangchenglong01. All rights reserved.
//

import Foundation
import UIKit

typealias CompletionReslut<Success> = Result<Success, ImageCacheError>

class ImageDownloader {
    public static let `default` = ImageDownloader()
    
    open var downloadTimeout: TimeInterval = 60.0
    
    private let sessionDelegate = DownloadSessionDelegate()
    
    private lazy var session: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.waitsForConnectivity = true
        return URLSession(configuration: configuration,
                          delegate: sessionDelegate, delegateQueue: nil)
    }()
    
    init() {
      
    }
    
    @discardableResult
    func downloadImage(with url: URL, completionHandler: ((CompletionReslut<UIImage>) -> Void)? = nil) -> DownloadTask? {
        var rquest = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: downloadTimeout)
        rquest.httpShouldUsePipelining = false
        let sessionDataTask = session.dataTask(with: rquest)
        let downloadTask = DownloadTask(task: sessionDataTask)
        sessionDelegate.add(downloadTask, url: url)
        // tail closure
        downloadTask.onTaskDone.proxy(on: self) { (self, done) in
            DispatchQueue.main.async {
                 switch done {
                 case .success(let data):
                    // process imagedata
                    // let processor = ImageProcessor(data: data)
                    // processor.process()
                    guard let onCompleted = completionHandler else {
                        return
                    }
                    if let image = UIImage(data: data) {
                        onCompleted(CompletionReslut(value: image))
                    }
                    break
                case .failure:
                    guard let onCompleted = completionHandler else {
                        return
                    }
                    onCompleted(.failure(.downloadError))
                    break
                }
            }
        }
        downloadTask.sessionTask.resume()
        return downloadTask
    }
}
