//
//  DataFetch.swift
//  Moments
//
//  Created by zhangchenglong01 on 2020/3/31.
//  Copyright © 2020 zhangchenglong01. All rights reserved.
//

import Foundation

protocol Fetchable {
    associatedtype Success
    associatedtype Failure: Error
    func refresh(completionHandler: @escaping (_ result: (Result<Success, Failure>)) -> Void)
    func loadMore(completionHandler: @escaping (_ result: (Result<Success, Failure>)) -> Void)
}

extension Result {
    var success: Success? {
        guard case let .success(value) = self else { return nil }
        return value
    }
    
    var failure: Failure? {
        guard case let .failure(error) = self else { return nil }
        return error
    }

    init(value: Success, error: Failure? = nil) {
        if let error = error {
            self = .failure(error)
        } else {
            self = .success(value)
        }
    }
}

extension Array where Element == StreamWrapper {
    func load(completionHandler: @escaping (Result<[String: [MomentTweetable]], StreamError>) -> Void) {
        let group = DispatchGroup()
        var templates = [String: [MomentTweetable]]()
        self.forEach { (element) in
            group.enter()
            element.stream.fetch { (result) in
                switch result {
                case .success(let list):
                    templates[element.stream.identifier] = list
                    break
                case .failure:
                    break
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            completionHandler(Result(value: templates))
        }
    }
}
