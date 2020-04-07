//
//  MomentsDataSource.swift
//  Moments
//
//  Created by zhangchenglong01 on 2020/3/28.
//  Copyright © 2020 zhangchenglong01. All rights reserved.
//

import UIKit

let kLoadCount = 5

class MomentsDataSource: NSObject {
    var dataList: [MomentTweetable]! = []
    let streams = [StreamWrapper(stream: MomentTweetsStream()), StreamWrapper(stream:MomentUserInfoStream())]
    weak var tableView: MomentsTableView!
    var tweetsStream: MomentTweetsStream {
        return streams[0].stream as! MomentTweetsStream
    }
    var offset = 0
    
    private (set) var userInfo: MomentTweetable?
    
    init(tableView: MomentsTableView) {
        self.tableView = tableView
    }
    
    func loadData() {
        streams.load { (result) in
            switch result {
            case .success(let dic):
                self.dataList.append(contentsOf: dic[MomentTweetsStream.identifier]!)
                self.userInfo = dic[MomentUserInfoStream.identifier]?.first
                self.tableView.reloadData()
                self.offset = 5
                break
            case .failure:
                break
            }
        }
    }
    
    @objc func onRefreshEvent() {
        self.tweetsStream.fetch { (result) in
            switch result {
            case .success(let list):
                print(list)
                self.dataList.removeAll()
                self.dataList.append(contentsOf: list)
                self.tableView.reloadData()
                self.tableView.mj_header?.endRefreshing()
                self.offset = 5
                self.tableView.mj_footer?.resetNoMoreData()
                break
            case .failure:
                break
            }
        }
    }
    
    @objc func onLoadMoreEvent() {
        self.tweetsStream.loadMore(kLoadCount, offset: self.offset) { (result) in
            switch result {
                case .success(let list):
                    self.dataList.append(contentsOf: list)
                    self.tableView.reloadData()
                    self.offset += kLoadCount
                    self.tableView.mj_footer?.endRefreshing()
                    break
                case .failure:
                    self.tableView.mj_footer?.endRefreshingWithNoMoreData()
                    break
            }
        }
    }
}


