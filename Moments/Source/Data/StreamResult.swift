//
//  StreamResult.swift
//  Moments
//
//  Created by zhangchenglong01 on 2020/3/30.
//  Copyright © 2020 zhangchenglong01. All rights reserved.
//

import Foundation

public typealias ServiceErrorCode = Int
public typealias NetErrorCode = Int

public enum StreamError: Error {
    case requestInvalid(at: URL)
    case serviceUnavaiable(with: ServiceErrorCode)
    case netError(with: NetErrorCode)
    case noMoreData
}

public typealias StreamResult<Success> = Result<Success, StreamError>


