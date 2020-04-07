//
//  MomentCellTemplateMapper.swift
//  Moments
//
//  Created by zhangchenglong01 on 2020/3/28.
//  Copyright © 2020 zhangchenglong01. All rights reserved.
//

import Foundation

class MomentCellTemplateMapper: NSObject {
    private(set) var mapper: [String: MomentBaseCell.Type] = [:]
    func registerCell(template type: String, classType cellClass: MomentBaseCell.Type) {
        if !mapper.keys.contains(type) {
            mapper[type] = cellClass
        }
    }
}
