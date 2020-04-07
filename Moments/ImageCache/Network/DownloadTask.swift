//
//  DownloadTask.swift
//  Moments
//
//  Created by zhangchenglong01 on 2020/4/3.
//  Copyright © 2020 zhangchenglong01. All rights reserved.
//

import Foundation

typealias DownloadTaskDone<T> = Result<T, ImageCacheError>

class DownloadTask: NSObject {
    public let sessionTask: URLSessionDataTask
    public private(set) var mutableData: Data
    
    let onTaskDone = WeakProxy<DownloadTaskDone<Data>, Void>()
    
    init(task: URLSessionDataTask) {
        sessionTask = task
        mutableData = Data()
    }
    
    func didReceiveData(_ data: Data) {
        mutableData.append(data)
    }
}
