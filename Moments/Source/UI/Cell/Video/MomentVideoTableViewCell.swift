//
//  MomentVideoTableViewCell.swift
//  Moments
//
//  Created by zhangchenglong01 on 2020/3/28.
//  Copyright © 2020 zhangchenglong01. All rights reserved.
//

import UIKit

class MomentVideoTableViewCell: MomentBaseCell {
    var avatar: UIImageView!
    var senderLabel: UILabel!
       
    var contentLabel: UILabel!
    var images: [String]! = []
    
    required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        avatar = UIImageView()
        avatar.backgroundColor = UIColor.blue
        avatar.layer.cornerRadius = 3
        avatar.image = UIImage(named: "https://thoughtworks-mobile-2018.herokuapp.com/images/tweets/002.jpeg")
        self.contentView.addSubview(avatar)
        avatar.snp.makeConstraints { (make) in
            make.width.height.equalTo(30)
            make.left.equalToSuperview().offset(17)
            make.top.equalToSuperview().offset(10)
        }
        
        senderLabel = UILabel()
        senderLabel.textAlignment = .left
        senderLabel.textColor = UIColor.blue
        senderLabel.font = UIFont.systemFont(ofSize: 14)
        senderLabel.text = "Alex"
        self.contentView.addSubview(senderLabel)
        senderLabel.snp.makeConstraints { (make) in
            make.top.equalTo(avatar.snp_topMargin)
            make.left.equalTo(avatar.snp_rightMargin).offset(5)
        }
        
        contentLabel = UILabel()
        contentLabel.textAlignment = .left
        contentLabel.textColor = UIColor.blue
        contentLabel.font = UIFont.systemFont(ofSize: 14)
        contentLabel.text = "沙发"
        self.contentView.addSubview(contentLabel)
        contentLabel.snp.makeConstraints { (make) in
            make.top.equalTo(senderLabel.snp_bottomMargin).offset(7)
            make.left.equalTo(senderLabel.snp_leftMargin)
            make.right.lessThanOrEqualToSuperview().offset(-17)
        }
    }
    
    override func configCell(with model: MomentTweetable) {
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }


    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
