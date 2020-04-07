//
//  MomentsStream.swift
//  Moments
//
//  Created by zhangchenglong01 on 2020/3/28.
//  Copyright © 2020 zhangchenglong01. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import UIKit

let userInfoUrl = "https://thoughtworks-mobile-2018.herokuapp.com/user/jsmith"
let tweetsUrl = "https://thoughtworks-mobile-2018.herokuapp.com/user/jsmith/tweets"

protocol Streamable: MomentIdentifiable {
    func fetch(completionHandler: @escaping ((StreamResult<Array<MomentTweetable>>)) -> Void)
}

struct StreamWrapper {
    let stream: Streamable
    init(stream: Streamable) {
        self.stream = stream
    }
}

struct MomentTweetsFetcher: Fetchable {
    typealias Success = Array<MomentTweetable>
    typealias Failure = StreamError
        
    func refresh(completionHandler: @escaping ((StreamResult<Success>)) -> Void) {
        AF.request(tweetsUrl).responseJSON { (response) in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                var tweets: Array<MomentTweetable?> = []
                for (_, subJson) in json {
                    if subJson["error"].stringValue.count > 0 || subJson["unknown error"].stringValue.count > 0 {
                        continue
                    }
                    let tweet = MomentTextImage(json: subJson)
                    tweets.append(tweet)
                }
                let result = tweets.compactMap { $0 }
                completionHandler(StreamResult<Success>(value: result))
                break
            case .failure( _):// let error
                completionHandler(.failure(.netError(with: 404)))
                break
            }
        }
    }
    
    func loadMore(completionHandler: @escaping (_ result: (Result<Success, Failure>)) -> Void) {
        
    }
}

public enum MomentTweetsStreamStragety {
    case memory(total: Int)
    case net
    case disk
    
    mutating func change() {
        switch self {
        case .net:
            self = .memory(total: 5)
            break
        default:
            break
        }
    }
}

final class MomentTweetsStream: NSObject, Streamable {
    var fetcher = MomentTweetsFetcher()
    var streamStragety: MomentTweetsStreamStragety = .net
    private var dataList: Array<MomentTweetable> = []
    
    var completionHandler: ((Result<Array<MomentTweetable>, StreamError>) -> Void)?
    
    var onCompleted = WeakProxy<Array<MomentTweetable>, Void>()
    
    func fetch(completionHandler: @escaping ((StreamResult<Array<MomentTweetable>>)) -> Void) {
        self.completionHandler = completionHandler
        switch streamStragety {
        case .net:
            fetchfromNet { (result) in
                switch result {
                case .success(let list):
                    self.dataList.append(contentsOf: list)
                    if let onCompleted = self.completionHandler {
                        let slice = self.dataList.prefix(upTo: 5)
                        onCompleted(StreamResult(value: Array(slice)))
                    }
                    self.streamStragety.change()
                    break
                case .failure(let error):
                    if let onCompleted = self.completionHandler {
                       onCompleted(.failure(error))
                    }
                    break
                }
            }
            break
        case let .memory(total: total):
            let list = self.fetchfromMemory(total: total)
            if let onCompleted = self.completionHandler {
                onCompleted(StreamResult(value: list))
            }
            break
        default:
            break
        }
    }
    
    func loadMore(_ count: Int, offset: Int, completionHandler: @escaping ((StreamResult<Array<MomentTweetable>>)) -> Void) {
        self.completionHandler = completionHandler
        if offset >= self.dataList.count || self.dataList.count == 0 {
            if let onCompleted = self.completionHandler {
                onCompleted(.failure(.noMoreData))
            }
            return
        }
        if let onCompleted = self.completionHandler {
            let last = min(self.dataList.count - 1, (count + offset - 1))
            let slice = self.dataList[offset...last]
            onCompleted(StreamResult(value: Array(slice)))
        }
    }
    
    private func fetchfromNet(completionHandler: @escaping ((StreamResult<Array<MomentTweetable>>)) -> Void) {
        self.fetcher.refresh { (result) in
            completionHandler(result)
        }
    }
    
    private func fetchfromMemory(total: Int) -> Array<MomentTweetable> {
        let slice = self.dataList.prefix(upTo: 5)
        return Array(slice)
    }
}

final class MomentUserInfoStream:NSObject, Streamable {
    func fetch(completionHandler: @escaping ((StreamResult<Array<MomentTweetable>>)) -> Void) {
        AF.request(userInfoUrl).responseJSON { (response) in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                var tweets: Array<MomentTweetable?> = []
                for (_, subJson) in json {
                    if subJson["error"].stringValue.count > 0 || subJson["unknown error"].stringValue.count > 0 {
                        continue
                    }
                    let tweet = User(json: json)
                    tweets.append(tweet)
                }
                let result = tweets.compactMap { $0 }
                completionHandler(StreamResult(value: result))
                break
            case .failure( _):// let error
                completionHandler(.failure(.netError(with: 404)))
                break
            }
        }
    }
}




