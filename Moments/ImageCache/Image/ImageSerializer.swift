//
//  ImageSerializer.swift
//  Moments
//
//  Created by zhangchenglong01 on 2020/4/1.
//  Copyright © 2020 zhangchenglong01. All rights reserved.
//

import Foundation
import UIKit

protocol ImageDataConvertable {
    func data(with image: UIImage) -> Data?
    func image(with data: Data) -> UIImage?
}

class ImageSerializer: ImageDataConvertable {
    public static let `default` = ImageSerializer()
    
    func data(with image: UIImage) -> Data? {
        let data = image.jpegData(compressionQuality: 1)
        return data
    }
    func image(with data: Data) -> UIImage? {
        let image = UIImage(data: data)
        return image
    }
}
