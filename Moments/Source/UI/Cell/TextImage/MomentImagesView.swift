//
//  MomentImagesView.swift
//  Moments
//
//  Created by zhangchenglong01 on 2020/3/29.
//  Copyright © 2020 zhangchenglong01. All rights reserved.
//

import UIKit
import SnapKit

// 布局信息
struct ImagesLayoutInfo {
    var width: CGFloat
    var height: CGFloat
    var rowNum = 3
    var colNum = 3
    init(width: CGFloat, height: CGFloat, rowNum: Int, colNum: Int) {
        self.width = width
        self.height = height
        self.rowNum = rowNum
        self.colNum = colNum
    }
}

class MomentImagesView: UIView {
    private(set) var imageUrls: [String]
    private(set) var images: [UIImage] = []
    private(set) var layout: ImagesLayoutInfo
    
    public static let space: CGFloat = 10.0
    
    init?(imageUrls: [String], layout: ImagesLayoutInfo) {
        guard imageUrls.count > 0 else {
            return nil
        }
        self.imageUrls = imageUrls
        self.layout = layout
        super.init(frame: CGRect.zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        guard imageUrls.count > 0 else { return }
        for (index, item) in self.imageUrls.enumerated() {
            let imageView = UIImageView()
            imageView.backgroundColor = UIColor(hexString: "#f2f2f2")
            imageView.setImage(with: URL(string: item)!, placeholder: nil, completionHandler: nil)
            self.addSubview(imageView)
            let leftMargin: CGFloat = CGFloat(index % layout.rowNum) * layout.width + CGFloat(index % layout.rowNum) * MomentImagesView.space
            let topMargin: CGFloat = CGFloat(index / layout.colNum) * layout.height + CGFloat(index / layout.colNum) * MomentImagesView.space
            imageView.snp.makeConstraints { (make) in
                make.width.equalTo(self.layout.width)
                make.height.equalTo(self.layout.height)
                make.left.equalToSuperview().offset(leftMargin)
                make.top.equalToSuperview().offset(topMargin)
                make.right.lessThanOrEqualToSuperview()
                make.bottom.lessThanOrEqualToSuperview()
            }
        }
    }
    
    class func height(with imageUrls: [String]) -> CGFloat {
        guard imageUrls.count > 0 else { return 0.0 }
        let rows = imageUrls.count / RowImageNum + (imageUrls.count % RowImageNum == 0 ? 0 : 1)
        let imagesHeight = rows <= 0 ? 0 : (CGFloat(rows) * imageHeight + CGFloat(rows - 1) * MomentImagesView.space)
        return imagesHeight
    }
}

