//
//  MapperService.swift
//  Moments
//
//  Created by zhangchenglong01 on 2020/3/28.
//  Copyright © 2020 zhangchenglong01. All rights reserved.
//

import UIKit

// 映射规则：model ---> Cell

class MapperService: NSObject {
    public static let `default` = MapperService()
    
    private(set) var cellMapper = MomentCellTemplateMapper()
    private(set) var cellFactory = MomentCellFactory()
    
    func registerCell(template type: String, classType cellClass: MomentBaseCell.Type) {
        cellMapper.registerCell(template: type, classType: cellClass)
    }
    
    func cellType(for template: String) -> MomentBaseCell.Type?  {
        return cellMapper.mapper[template]
    }
    
    func makeCell(with template: String) -> MomentCell? {
        guard let cellClass = cellType(for: template) else { return nil }
        return cellFactory.makeCell(with: cellClass)
    }
}
