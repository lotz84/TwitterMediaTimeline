//
//  TweetStatus.swift
//  twitter-media-timeline
//
//  Created by Hirose Tatsuya on 2015/03/26.
//  Copyright (c) 2015年 lotz84. All rights reserved.
//

import Foundation

struct TweetStatus {
    var id : String
    var text : String
    var createdAt : String
    var favorited : Bool
    var retweeted : Bool
    var favoriteCount : Int
    var retweetCount : Int
    var name : String
    var screenName : String
    var profileImageURL : String
    var medias: [TweetMedia]
    
    static func fromJSON(json: JSON) -> TweetStatus? {
        if  let id = json["user"]["id_str"].string,
            let favorited = json["favorited"].bool,
            let retweeted = json["retweeted"].bool,
            let profileImageURL = json["user"]["profile_image_url"].string,
            let favoriteCount = json["favorite_count"].int,
            let retweetCount = json["retweet_count"].int,
            let createdAt = json["created_at"].string,
            let text = json["text"].string,
            let name = json["user"]["name"].string,
            let screenName = json["user"]["screen_name"].string
        {
            var medias : [TweetMedia] = []
            if let mediaJsonArray = json["extended_entities"]["media"].array {
                for mediaJson in mediaJsonArray {
                    if let media = TweetMedia.fromJSON(mediaJson) {
                        medias.append(media)
                    }
                }
            }
            if let urls = json["entities"]["urls"].array {
                for urlJson in urls {
                    if let url = urlJson["expanded_url"].string {
                        if let media = TweetMedia.fromURL(url) {
                            medias.append(media)
                        }
                    }
                }
            }
            
            return TweetStatus(
                id: id,
                text: text,
                createdAt: createdAt,
                favorited: favorited,
                retweeted: retweeted,
                favoriteCount: favoriteCount,
                retweetCount: retweetCount,
                name: name,
                screenName: screenName,
                profileImageURL: profileImageURL,
                medias: medias
            )
        }
        return nil
    }
}

struct TweetMedia {
    
    var type: TweetMediaType
    var url : String
    
    static func fromJSON(json: JSON) -> TweetMedia? {
        if let url = json["media_url"].string,
           let type = json["type"].string
        {
            switch type {
            case "animated_gif":
                if let variants = json["video_info"]["variants"].array {
                    if let variant = variants.first {
                        if let url = variant["url"].string {
                            return TweetMedia(type: .GIF(true), url: url)
                        }
                    }
                }
            case "photo":
                return TweetMedia(type: .Photo, url: url)
            default:
                return TweetMedia(type: .Photo, url: url)
            }
        }
        return nil
    }
    
    static func fromURL(url: String) -> TweetMedia? {
        
        if url.hasPrefix("http://gyazo.com/") {
            return TweetMedia(type: .Photo, url: url + ".png")
        }
        
        if url.hasSuffix(".png")
            || url.hasSuffix(".bmp")
            || url.hasSuffix(".jpg")
            || url.hasSuffix(".jpeg")
            || url.hasSuffix(".JPG")
            || url.hasSuffix(".JPEG")
        {
            return TweetMedia(type: .Photo, url: url)
        } else if url.hasSuffix(".gif") {
            return TweetMedia(type: .GIF(false), url: url)
        }
        return nil
    }
}

enum TweetMediaType {
    case GIF(Bool) // is mp4?
    case Photo
}