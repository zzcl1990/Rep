//
//  MomentHeaderView.swift
//  Moments
//
//  Created by zhangchenglong01 on 2020/4/4.
//  Copyright © 2020 zhangchenglong01. All rights reserved.
//

import UIKit
import CoreGraphics
import SnapKit

let kHeadAvatarWidth: CGFloat = 80.0
let kHeadAvatarCornerRadius: CGFloat = 1.0

class MomentHeaderView: UIView {
    var profileImageView: UIImageView!
    var avatar: UIImageView!
    var nick: UILabel!
    init() {
        super.init(frame: CGRect.zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        profileImageView = UIImageView()
        self.addSubview(profileImageView)
        profileImageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        avatar = UIImageView()
        avatar.clipsToBounds = true
        avatar.layer.cornerRadius = kHeadAvatarCornerRadius
        self.addSubview(avatar)
        avatar.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-17)
            make.width.height.equalTo(kHeadAvatarWidth)
            make.bottom.equalTo(profileImageView.snp.bottom).offset(20)
        }
        
        nick = UILabel()
        nick.textColor = UIColor.white
        nick.textAlignment = .right
        nick.font = UIFont.boldSystemFont(ofSize: 16)
        self.addSubview(nick)
        nick.snp.makeConstraints { (make) in
            make.right.equalTo(avatar.snp.left).offset(0)
            make.top.equalTo(avatar.snp.top).offset(0)
        }
    }
    
    public func config(with user: MomentTweetable) {
        guard let model = user as? User else { return }
        profileImageView.setImage(with: URL(string: model.profile)!, placeholder: nil, completionHandler: nil)
        avatar.setImage(with: URL(string: model.avatar)!, placeholder: nil, completionHandler: nil)
        nick.text = model.nick
    }
}
