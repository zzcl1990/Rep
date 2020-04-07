//
//  MomentTextImageTableViewCell.swift
//  Moments
//
//  Created by zhangchenglong01 on 2020/3/28.
//  Copyright © 2020 zhangchenglong01. All rights reserved.
//

import UIKit
import SnapKit

let kAvatarWidth: CGFloat = 40.0
let kAvatarHeight: CGFloat = 40.0

let kAvatarCornerRadius: CGFloat = 20.0

let kTopMargin: CGFloat = 7.0
let kLeftMargin: CGFloat = 17.0

let ContentFont: UIFont = UIFont.systemFont(ofSize: 14.0)
let SenderFont: UIFont = UIFont.boldSystemFont(ofSize: 14.0)

let imageWidth: CGFloat = 80.0
let imageHeight: CGFloat = 80.0

let RowImageNum: Int = 3
let ColImageNum: Int = 3

class MomentTextImageTableViewCell: MomentBaseCell {
    
    var avatar: UIImageView!
    var senderLabel: UILabel!
    
    var contentLabel: UILabel!
    var imagesView: MomentImagesView?
    var commentView: MomentCommentView?
    
    var images: [String]! = []
    
    required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.avatar = nil
        self.senderLabel = nil
        self.contentLabel = nil
        self.imagesView = nil
    }
    
    func setupUI() {
        avatar = UIImageView()
        avatar.clipsToBounds = true
        avatar.layer.cornerRadius = kAvatarCornerRadius
        avatar.image = UIImage(named: "https://thoughtworks-mobile-2018.herokuapp.com/images/tweets/002.jpeg")
        self.contentView.addSubview(avatar)
        avatar.snp.makeConstraints { (make) in
            make.width.height.equalTo(kAvatarWidth)
            make.left.equalToSuperview().offset(kLeftMargin)
            make.top.equalToSuperview().offset(kTopMargin)
        }
        
        senderLabel = UILabel()
        senderLabel.textAlignment = .left
        senderLabel.textColor = UIColor.init(hexString: "#4878b2")
        senderLabel.font = SenderFont
        senderLabel.text = "Alex"
        self.contentView.addSubview(senderLabel)
        senderLabel.snp.makeConstraints { (make) in
            make.top.equalTo(avatar.snp.top)
            make.left.equalTo(avatar.snp.right).offset(7)
        }
        
        contentLabel = UILabel()
        contentLabel.textAlignment = .left
        contentLabel.numberOfLines = 0
        contentLabel.textColor = UIColor.black
        contentLabel.font = ContentFont
        contentLabel.text = "沙发"
        self.contentView.addSubview(contentLabel)
        contentLabel.snp.makeConstraints { (make) in
            make.top.equalTo(senderLabel.snp.bottom).offset(7)
            make.left.equalTo(senderLabel.snp.left)
            make.right.lessThanOrEqualToSuperview().offset(-17)
        }
    }
    
    override func configCell(with model: MomentTweetable) {
        guard let textImageMoment = model as? MomentTextImage else { return }
        self.avatar.setImage(with: URL(string: textImageMoment.sender.avatar)!, placeholder: UIImage(named: "head_default"), completionHandler: nil)
        self.senderLabel.text = textImageMoment.sender.nick
        self.contentLabel.text = textImageMoment.content
        
        let imagesLayout = ImagesLayoutInfo.init(width: imageWidth, height: imageWidth, rowNum: RowImageNum, colNum: ColImageNum)
        imagesView = MomentImagesView(imageUrls: textImageMoment.images, layout: imagesLayout)
        if let view = imagesView {
            self.contentView.addSubview(view)
            view.snp.makeConstraints { (make) in
                make.left.equalTo(contentLabel.snp.left)
                make.top.equalTo(contentLabel.snp.bottom).offset(5)
            }
        }
        
        commentView = MomentCommentView(comments: textImageMoment.comments)
        if let commentV = commentView {
            self.contentView.addSubview(commentV)
            let topTarget = imagesView ?? contentView
            commentV.snp.makeConstraints { (make) in
                make.left.equalTo(self.senderLabel.snp.left)
                make.right.equalToSuperview().offset(-17)
                make.top.equalTo(topTarget.snp.bottom).offset(8)
                //make.bottom.lessThanOrEqualToSuperview()
            }
        }
    }
    
    override class func rowHeight(for model: MomentTweetable) -> CGFloat {
        guard let textImageMoment = model as? MomentTextImage else { return 0 }
        let senderHeight = textImageMoment.sender.nick.height(withConstrainedWidth: SCREEN_WIDTH, font: SenderFont)
        let contentHeight = textImageMoment.content.height(withConstrainedWidth: SCREEN_WIDTH - kAvatarWidth - kLeftMargin * 2 - 7, font: ContentFont)
        let imagesHeight = MomentImagesView.height(with: textImageMoment.images)
        let commentHeight = MomentCommentView.height(with: textImageMoment.comments)
        let cellHeight = kTopMargin + senderHeight + kTopMargin + contentHeight + imagesHeight + commentHeight + 10
        return cellHeight
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
