//
//  Moment.swift
//  Moments
//
//  Created by zhangchenglong01 on 2020/3/28.
//  Copyright © 2020 zhangchenglong01. All rights reserved.
//

import Foundation
import SwiftyJSON

public protocol MomentIdentifiable {
    var identifier: String { get }
    static var identifier: String { get }
}

extension MomentIdentifiable {
    var identifier: String {
        return String(describing: type(of: self))
    }
    static var identifier: String {
        return String(describing: self)
    }
}

public protocol MomentTweetable: MomentIdentifiable {
    // check the tweet is invalid
}

struct User: MomentTweetable {
    var name: String
    var avatar: String
    var nick: String
    var profile: String
    
    init(json: JSON) {
        name = json["username"].stringValue
        nick = json["nick"].stringValue
        avatar = json["avatar"].stringValue
        profile = json["profile-image"].stringValue
    }
}

struct Sender {
    var name: String
    var avatar: String
    var nick: String
    
    init(json: JSON) {
        name = json["username"].stringValue
        nick = json["nick"].stringValue
        avatar = json["avatar"].stringValue
    }
}

struct Comment {
    var content: String
    var sender: Sender
    
    init(json: JSON) {
        content = json["content"].stringValue
        sender = Sender(json: json["sender"])
    }
}

struct MomentText: MomentTweetable {
    var senderName: String
    var senderAvatar: String
    
    var content: String
}

struct MomentImage: MomentTweetable {
    var senderName: String
}

struct MomentTextImage: MomentTweetable {
    var sender: Sender
    var content: String
    var comments: [Comment]
    var images: [String]
    
    init?(json: JSON) {
        sender = Sender(json: json["sender"])
        content = json["content"].stringValue
        comments = json["comments"].arrayValue.map{ Comment(json: $0) }
        images = json["images"].arrayValue.map{ $0.dictionaryValue["url"]!.stringValue }
        if images.count == 0 && content.isEmpty {
            return nil
        }
    }
}


struct MomentVideo: MomentTweetable {
    var senderName: String = "aaabbb"
    var senderAvatar: String = "https://thoughtworks-mobile-2018.herokuapp.com/images/user/avatar/001.jpeg"
    
    var videoUrl: String = "https://thoughtworks-mobile-2018.herokuapp.com/images/user/avatar/001.jpeg"
}
