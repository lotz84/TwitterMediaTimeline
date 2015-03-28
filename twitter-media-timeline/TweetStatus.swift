
import Foundation

struct TweetStatus {
    let id : String
    let text : String
    let createdAt : String
    let favorited : Bool
    let retweeted : Bool
    let favoriteCount : Int
    let retweetCount : Int
    let name : String
    let screenName : String
    let profileImageURL : String
    let urlMap : [String:String]
    let medias: [TweetMedia]
    
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
            var urlMap : [String:String] = [:]
            if let urls = json["entities"]["urls"].array {
                for urlJson in urls {
                    if  let url = urlJson["url"].string,
                        let expanded = urlJson["expanded_url"].string
                    {
                        urlMap.updateValue(expanded, forKey: url)
                        
                        if let media = TweetMedia.fromURL(url) {
                            medias.append(media)
                        }
                    }
                }
            }
            if let mediaJsonArray = json["extended_entities"]["media"].array {
                for mediaJson in mediaJsonArray {
                    if let media = TweetMedia.fromJSON(mediaJson) {
                        medias.append(media)
                    }
                    
                    if  let url = mediaJson["url"].string,
                        let expanded = mediaJson["expanded_url"].string
                    {
                        urlMap.updateValue(expanded, forKey: url)
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
                urlMap: urlMap,
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
            default: // also case "photo"
                return TweetMedia(type: .Photo, url: url)
            }
        }
        return nil
    }
    
    static func fromURL(url: String) -> TweetMedia? {
        
        if url.hasPrefix("https://instagram.com/p/") {
            let requestURL = NSURL(string: "http://api.instagram.com/oembed?url=" + url)!
            let request = NSURLRequest(URL: requestURL, cachePolicy: .ReloadIgnoringLocalCacheData, timeoutInterval: 10)
            let data = NSURLConnection.sendSynchronousRequest(request, returningResponse: nil, error: nil)
            let json : AnyObject? = NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments, error: nil)
            if let thumbnailUrl =  json?["thumbnail_url"] as? String {
                return TweetMedia(type: .Photo, url: thumbnailUrl)
            }
        }
        
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