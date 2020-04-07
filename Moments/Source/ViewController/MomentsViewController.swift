//
//  MomentsViewController.swift
//  Moments
//
//  Created by zhangchenglong01 on 2020/3/28.
//  Copyright © 2020 zhangchenglong01. All rights reserved.
//

import UIKit
import SnapKit
import MJRefresh

class MomentsViewController: UIViewController {
    var tableView: MomentsTableView!
    let tableViewDelgate: MomentsDelegate!
    let tableViewDataSource: MomentsDataSource!
    
    init() {
        tableView = MomentsTableView(frame: CGRect.zero, style: .grouped)
        tableViewDelgate = MomentsDelegate()
        tableViewDataSource = MomentsDataSource(tableView: tableView)
        
        // register cell template
        MapperService.default.registerCell(template: MomentTextImage.identifier, classType: MomentTextImageTableViewCell.self)
        //MapperService.service.registerCell(template: "MomentVideoTableViewCell", classType: MomentVideoTableViewCell.self)
        // MapperService.service.registerCell(template: "MomentUserInfoTableViewCell", classType: MomentUserInfoTableViewCell.self)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(self.tableView)
        tableView.estimatedRowHeight = 85.0
        tableView.rowHeight = UITableView.automaticDimension
        tableView.allowsSelection = false
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.mj_header = MJRefreshNormalHeader(refreshingTarget: self.tableViewDataSource!, refreshingAction: #selector(MomentsDataSource.onRefreshEvent))
        self.tableView.mj_footer = MJRefreshAutoNormalFooter.init(refreshingTarget: self.tableViewDataSource!, refreshingAction: #selector(MomentsDataSource.onLoadMoreEvent))
        
        self.tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        self.tableViewDataSource.loadData()
    }
}

extension MomentsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let _ = tableViewDataSource.dataList else { return 0}
        return tableViewDataSource.dataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 模版映射
        let model: MomentTweetable = tableViewDataSource.dataList[indexPath.row]
        let cellClass = MapperService.default.cellType(for: model.identifier)
        var cell: MomentCell? = tableView.dequeueReusableCell(withIdentifier: cellClass?.identifier ?? "kReuseIdentifier") as? MomentCell
        if (cell == nil) {
            cell = MapperService.default.makeCell(with: model.identifier)
        }
        guard let momentCell = cell else {
            return UITableViewCell()
        }
        momentCell.configCell(with: model)
        return momentCell as! UITableViewCell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let user = self.tableViewDataSource.userInfo else { return nil }
        let header = MomentHeaderView()
        header.config(with: user)
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let _ = self.tableViewDataSource.userInfo else { return 0.0 }
        return SCREEN_HEIGHT / 3.0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let model: MomentTweetable = tableViewDataSource.dataList[indexPath.row]
        let cellClass = MapperService.default.cellType(for: model.identifier)
        let height = cellClass?.rowHeight(for: model) ?? 0
        return height
    }
        
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200.0
    }
}
