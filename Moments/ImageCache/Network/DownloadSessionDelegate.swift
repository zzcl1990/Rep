//
//  DownloadSessionDelegate.swift
//  Moments
//
//  Created by zhangchenglong01 on 2020/4/3.
//  Copyright © 2020 zhangchenglong01. All rights reserved.
//

import Foundation

class DownloadSessionDelegate: NSObject {
    private var tasks: [URL: DownloadTask] = [:]
    private let lock = NSLock()
    
    func add(_ downLoadTask: DownloadTask, url: URL) {
        lock.lock()
        defer { lock.unlock() }
        tasks[url] = downLoadTask
    }
    
    private func remove(_ task: DownloadTask) {
        guard let url = task.sessionTask.originalRequest?.url else {
            return
        }
        lock.lock()
        defer {lock.unlock()}
        tasks[url] = nil
    }
    
    func task(for task: URLSessionTask) -> DownloadTask? {
        guard let url = task.originalRequest?.url else {
            return nil
        }
        lock.lock()
        defer { lock.unlock() }
        guard let downLoadTask = tasks[url] else {
            return nil
        }
        guard downLoadTask.sessionTask.taskIdentifier == task.taskIdentifier else {
            return nil
        }
        return downLoadTask
    }
    
    func task(for url: URL) -> DownloadTask? {
        lock.lock()
        defer { lock.unlock() }
        return tasks[url]
    }
    
}

extension DownloadSessionDelegate: URLSessionDataDelegate {
    func urlSession(
           _ session: URLSession,
           dataTask: URLSessionDataTask,
           didReceive response: URLResponse,
           completionHandler: @escaping (URLSession.ResponseDisposition) -> Void)
    {
        completionHandler(.allow)
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        guard let task = self.task(for: dataTask) else {
            return
        }
        task.didReceiveData(data)
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let downLoadTask = self.task(for: task) else { return }
        let result = DownloadTaskDone(value: downLoadTask.mutableData)
        onCompleted(task: task, result: result)
    }
    
    private func onCompleted(task: URLSessionTask, result: DownloadTaskDone<Data>) {
        guard let downloadTask = self.task(for: task) else {
            return
        }
        remove(downloadTask)
        downloadTask.onTaskDone.invoke(result)
    }
}
