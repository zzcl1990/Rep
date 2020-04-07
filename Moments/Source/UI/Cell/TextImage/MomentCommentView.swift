//
//  MomentCommentView.swift
//  Moments
//
//  Created by zhangchenglong01 on 2020/4/5.
//  Copyright © 2020 zhangchenglong01. All rights reserved.
//

import UIKit
import SnapKit

class MomentCommentView: UIView {
    private(set) var comments: [Comment]
    private(set) var commentLabels: [UILabel] = []
    init?(comments: [Comment]) {
        guard comments.count > 0 else {
            return nil
        }
        self.comments = comments
        super.init(frame: CGRect.zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        self.clipsToBounds = true
        self.layer.cornerRadius = 2
        self.backgroundColor = UIColor.init(hexString: "#f2f2f2")
        self.config(with: comments)
    }
    
    func config(with comments: [Comment]) {
        for (index, item) in comments.enumerated() {
            let label = UILabel()
            label.textAlignment = .left
            label.numberOfLines = 0
            label.textColor = UIColor.init(hexString: "#000000")
            label.font = UIFont.systemFont(ofSize: 14.0)
            label.attributedText = self.attributeText(with: item)
            self.commentLabels.append(label)
            self.addSubview(label)
            var topTargetConstraintItem: SnapKit.ConstraintItem
            if index == 0 {
                topTargetConstraintItem = self.snp.top
            } else {
                topTargetConstraintItem = self.commentLabels.last!.snp.bottom
            }
            label.snp.makeConstraints { (make) in
                make.left.equalToSuperview().offset(3)
                make.right.equalToSuperview().offset(-3)
                make.top.equalTo(topTargetConstraintItem).offset(index == 0 ? 0 : 2)
                make.bottom.lessThanOrEqualToSuperview()
            }
        }
    }
    
    private func attributeText(with comment: Comment) -> NSAttributedString {
        let content = comment.sender.nick + ": " + comment.content
        let textColorAttr = [NSAttributedString.Key.foregroundColor: UIColor.init(hexString: "#4878b2")]
        let attrString = NSMutableAttributedString.init(string: content)
        attrString.setAttributes(textColorAttr, range: NSRange(location: 0, length: comment.sender.nick.count))
        return attrString
    }
    
    class func height(with comments: [Comment]) -> CGFloat {
        guard comments.count > 0 else {
            return 0.0
        }
        var contentHeight: CGFloat = 0.0
        comments.forEach { (moment) in
            let itemHeight: CGFloat = moment.content.height(withConstrainedWidth: SCREEN_WIDTH - kAvatarWidth - kLeftMargin * 2 - 7, font: ContentFont)
            contentHeight += itemHeight
        }
        
        contentHeight += CGFloat(comments.count * 2)
        return contentHeight
    }
}
