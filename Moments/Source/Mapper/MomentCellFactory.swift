//
//  MomentCellFactory.swift
//  Moments
//
//  Created by zhangchenglong01 on 2020/3/28.
//  Copyright © 2020 zhangchenglong01. All rights reserved.
//

import UIKit

class MomentCellFactory: NSObject {
    func makeCell(with cellClass: MomentBaseCell.Type) -> MomentCell {
        let cell: MomentCell = cellClass.init(style: .default, reuseIdentifier: MomentBaseCell.identifier)
        return cell
    }
}
