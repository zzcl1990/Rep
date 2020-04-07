//
//  ImageView+Cache.swift
//  Moments
//
//  Created by zhangchenglong01 on 2020/4/1.
//  Copyright © 2020 zhangchenglong01. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView {
    public func setImage(with url: URL,
                         placeholder: UIImage? = nil,
                         completionHandler: ((Result<UIImage, ImageCacheError>) -> Void)? = nil)
    {
        
        self.image = placeholder
        ImageCacheManager.default.retrieveImage(with: url) { (result) in
            switch result {
            case .success(let image):
                self.image = image
                if let onCompleted = completionHandler {
                    onCompleted(CompletionReslut(value: image))
                }
                break
            case .failure:
                break
            }
        }
    }
}

