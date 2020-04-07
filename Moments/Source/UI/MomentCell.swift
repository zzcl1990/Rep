//
//  MomentCell.swift
//  Moments
//
//  Created by zhangchenglong01 on 2020/3/28.
//  Copyright © 2020 zhangchenglong01. All rights reserved.
//

import Foundation
import CoreGraphics
import UIKit

protocol CellLayout {
    static func calculateLayout(with model: MomentTweetable) -> String
    static func rowHeight(for model: MomentTweetable) -> CGFloat
    static func estimatedRowHeight(for model: MomentTweetable) -> CGFloat
    
    // static var layoutInfo: MomentCellLayout { get }
}

protocol MomentCell: CellLayout, MomentIdentifiable {
    func configCell(with model: MomentTweetable)
}

class MomentBaseCell: UITableViewCell, MomentCell {
   // static var layoutInfo: MomentCellLayout
    
    required override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    class func calculateLayout(with model: MomentTweetable) -> String {
        return ""
    }
    
    class func rowHeight(for model: MomentTweetable) -> CGFloat {
        return 0
    }
    
    class func estimatedRowHeight(for model: MomentTweetable) -> CGFloat {
        return 0
    }
    
    func configCell(with model: MomentTweetable) {
        
    }
}


