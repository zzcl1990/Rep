//
//  ImageCacheError.swift
//  Moments
//
//  Created by zhangchenglong01 on 2020/4/1.
//  Copyright © 2020 zhangchenglong01. All rights reserved.
//

import Foundation

public enum ImageCacheError: Error {
    case cacheError
    case downloadError
    case retriveDataFromDiskError
}
