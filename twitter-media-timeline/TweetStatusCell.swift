//
//  TweetStatusView.swift
//  twitter-media-timeline
//
//  Created by Hirose Tatsuya on 2015/03/26.
//  Copyright (c) 2015年 lotz84. All rights reserved.
//

import UIKit
import Social
import Accounts
import MediaPlayer

class TweetStatusCell : UICollectionViewCell {
    
    var tweetStatus : TweetStatus?
    var mediaCount = 0;
    var mediaCountLabel : UILabel
    var mediaView : TweetMediaView
    var statusView : TweetStatusView
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        let baseFrame : CGRect = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
        
        mediaCountLabel = UILabel(frame: CGRect(x: frame.size.width - 50, y: 40, width: 40, height: 25))
        mediaView = TweetMediaView(frame: baseFrame)
        statusView = TweetStatusView(frame: baseFrame)
        
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.blackColor()
        
        mediaCountLabel.backgroundColor = UIColor.lightGrayColor()
        mediaCountLabel.textColor = UIColor.blackColor()
        mediaCountLabel.text = "1/3"
        mediaCountLabel.textAlignment = .Center
        mediaCountLabel.font = UIFont.systemFontOfSize(14)
        mediaCountLabel.layer.cornerRadius = 5
        mediaCountLabel.layer.masksToBounds = true
        mediaCountLabel.userInteractionEnabled = true
        mediaCountLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "rotateMedia"))
        mediaCountLabel.hidden = true
        
        mediaView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "toggleStatusView"))
        
        self.addSubview(mediaView)
        self.addSubview(mediaCountLabel)
        self.addSubview(statusView)
    }
    
    func toggleStatusView() {
        if tweetStatus!.medias.count > 0 {
            statusView.hidden = !statusView.hidden
        }
    }

    func rotateMedia() {
        mediaCount = (mediaCount + 1) % tweetStatus!.medias.count
        mediaCountLabel.text = "\(mediaCount+1)/\(tweetStatus!.medias.count)"
        mediaView.clear()
        mediaView.setMedia(tweetStatus!.medias[mediaCount])
    }
    
    override func prepareForReuse() {
        tweetStatus = nil
        
        mediaView.clear()
        
        mediaCount = 0
        mediaCountLabel.hidden = true
        
        statusView.clear()
        statusView.frame = CGRect(
            x: statusView.frame.origin.x,
            y: 0,
            width: statusView.frame.size.width,
            height: statusView.frame.size.height
        )
    }
    
    func setStatus(status: TweetStatus) {
        
        tweetStatus = status
        
        if status.medias.count > 0 {
            mediaView.setMedia(status.medias[0])
            if status.medias.count > 1 {
                mediaCountLabel.hidden = false
                mediaCountLabel.text = "\(1)/\(status.medias.count)"
            }
        }
        
        statusView.setStatus(status)
        
        let y : CGFloat
        if status.medias.count > 0 {
            y = self.frame.size.height - statusView.frame.size.height
        } else {
            y = (self.frame.size.height - statusView.frame.size.height)/2
        }
        
        statusView.frame = CGRect(
            x: statusView.frame.origin.x,
            y: y,
            width: statusView.frame.size.width,
            height: statusView.frame.size.height
        )
    }
}

class TweetMediaView : UIView {
    
    var scrollView : UIScrollView!
    var previewImageView : UIImageView!
    var moviePlayer : MPMoviePlayerController!
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let baseFrame : CGRect = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
        
        scrollView = UIScrollView(frame: baseFrame)
        scrollView.maximumZoomScale = 4.0
        scrollView.minimumZoomScale = 1.0
        scrollView.delegate = self
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.hidden = true
        
        previewImageView = UIImageView(frame: baseFrame)
        previewImageView.contentMode = UIViewContentMode.ScaleAspectFit
        
        moviePlayer = MPMoviePlayerController()
        moviePlayer.view.frame = baseFrame
        moviePlayer.repeatMode = .One
        moviePlayer.controlStyle = .None
        moviePlayer.view.hidden = true
        
        scrollView.addSubview(previewImageView)
        
        self.addSubview(scrollView)
        self.addSubview(moviePlayer.view)
    }
    
    func clear() {
        scrollView.hidden = true
        scrollView.zoomScale = 1.0
        previewImageView.image = nil
        
        moviePlayer.view.hidden = true
        moviePlayer.stop()
    }
    
    func setMedia(media: TweetMedia) {
        switch media.type {
        case .Photo:
            previewImageView.sd_setImageWithURL(NSURL(string: media.url))
            scrollView.hidden = false
        case .GIF(let isMp4):
            if isMp4 {
                moviePlayer.contentURL = NSURL(string: media.url)
                moviePlayer.view.hidden = false
                moviePlayer.play()
            } else {
                previewImageView.sd_setImageWithURL(NSURL(string: media.url))
                scrollView.hidden = false
            }
        }
    }
}

extension TweetMediaView : UIScrollViewDelegate {
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return previewImageView
    }
}

class TweetStatusView : UIView {
    
    let margin : UIEdgeInsets = UIEdgeInsetsMake(8, 10, 8, 10)
    
    var profileIcon : UIImageView
    var nameLabel : UILabel
    var screenNameLabel : UILabel
    var tweetTextLabel : UILabel
    var socialCountLabel : UILabel
    var createdAtLabel : UILabel
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        let iconSize : CGFloat = 50
        
        profileIcon = UIImageView(frame: CGRect(x: margin.left, y: margin.top, width: iconSize, height: iconSize))
        profileIcon.layer.cornerRadius = 5
        profileIcon.layer.masksToBounds = true
        
        nameLabel = UILabel(frame: CGRectZero)
        nameLabel.font = UIFont.systemFontOfSize(16)
        nameLabel.textColor = UIColor.whiteColor()
        
        screenNameLabel = UILabel(frame: CGRectZero)
        screenNameLabel.font = UIFont.systemFontOfSize(14)
        screenNameLabel.textColor = UIColor.grayColor()
        
        tweetTextLabel = UILabel(frame: CGRectZero)
        tweetTextLabel.numberOfLines = 0
        tweetTextLabel.lineBreakMode = NSLineBreakMode.ByCharWrapping
        tweetTextLabel.textColor = UIColor.whiteColor()
        tweetTextLabel.font = UIFont.systemFontOfSize(14)
        
        func rightOrigin(view: UIView) -> CGFloat {
            return view.frame.origin.x + view.frame.size.width
        }

        func bottomOrigin(view: UIView) -> CGFloat {
            return view.frame.origin.y + view.frame.size.height
        }
        
        let countLabel = UILabel(frame: CGRect(
            x: margin.left + 5,
            y: bottomOrigin(profileIcon) + 3,
            width: 24,
            height: 30
        ))
        countLabel.font = UIFont.systemFontOfSize(12)
        countLabel.numberOfLines = 0
        countLabel.textColor = UIColor.whiteColor()
        countLabel.text = "Fav:\nRT:"

        
        socialCountLabel = UILabel(frame: CGRect(
            x: rightOrigin(countLabel),
            y: bottomOrigin(profileIcon) + 3,
            width: iconSize - countLabel.frame.size.width - 5,
            height: 30
        ))
        socialCountLabel.font = UIFont.systemFontOfSize(12)
        socialCountLabel.numberOfLines = 0
        socialCountLabel.textAlignment = .Right
        socialCountLabel.textColor = UIColor.whiteColor()
        
        createdAtLabel = UILabel(frame: CGRectZero)
        createdAtLabel.textColor = UIColor.whiteColor()
        createdAtLabel.font = UIFont.systemFontOfSize(12)
        
        super.init(frame: frame)
        
        self.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.5)
        
        self.addSubview(profileIcon)
        self.addSubview(nameLabel)
        self.addSubview(screenNameLabel)
        self.addSubview(tweetTextLabel)
        self.addSubview(countLabel)
        self.addSubview(socialCountLabel)
        self.addSubview(createdAtLabel)

    }
    
    func rightOrigin(view: UIView) -> CGFloat {
        return view.frame.origin.x + view.frame.size.width
    }
    
    func bottomOrigin(view: UIView) -> CGFloat {
        return view.frame.origin.y + view.frame.size.height
    }

    func oneLineStringWidth(text: String, font: UIFont) -> CGFloat {
        return (text as NSString).sizeWithAttributes([NSFontAttributeName : font]).width
    }
    
    func multiLineStringWidth(text: String, font: UIFont, width: CGFloat) -> CGFloat {
        return (text as NSString).boundingRectWithSize(CGSizeMake(width, 0), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName : font], context: nil).size.height
    }
    
    func updateNameLabelFrame() {
        nameLabel.frame = CGRect(
            x: rightOrigin(profileIcon) + 5,
            y: margin.top,
            width: self.oneLineStringWidth(nameLabel.text!, font: nameLabel.font),
            height: 20
        )
    }
    
    func updateScreenNameLabelFrame() {
        screenNameLabel.frame = CGRect(
            x: rightOrigin(nameLabel) + 5,
            y: margin.top + 5,
            width: self.oneLineStringWidth(screenNameLabel.text!, font: screenNameLabel.font),
            height: 15
        )
    }
    
    func updateTweetTextLabelFrame() {
        let x = rightOrigin(profileIcon) + 5
        let y = bottomOrigin(nameLabel) + 5
        let width = self.frame.size.width - x - margin.right
        let height = self.multiLineStringWidth(tweetTextLabel.text!, font: tweetTextLabel.font, width: width)
        tweetTextLabel.frame = CGRect(x: x, y: y, width: width, height: height)
    }
    
    func updateCreatedAtLabelFrame() {
        let width = oneLineStringWidth(createdAtLabel.text!, font: createdAtLabel.font)
        let x = rightOrigin(tweetTextLabel) - width
        let y = bottomOrigin(tweetTextLabel)
        let height : CGFloat = 12
        createdAtLabel.frame = CGRect(x: x, y: y, width: width, height: height)
    }
    
    func clear() {
        self.hidden = false
        profileIcon.image = nil
        nameLabel.text = ""
        screenNameLabel.text = ""
        tweetTextLabel.text = ""
        socialCountLabel.text = ""
        createdAtLabel.text = ""
    }
    
    func setStatus(status: TweetStatus) {
        
        profileIcon.sd_setImageWithURL(NSURL(string: status.profileImageURL))
        
        nameLabel.text = status.name
        self.updateNameLabelFrame()
        
        screenNameLabel.text = "@" + status.screenName
        self.updateScreenNameLabelFrame()
        
        tweetTextLabel.text = status.text
        self.updateTweetTextLabelFrame()
        
        socialCountLabel.text = "\(status.favoriteCount)\n\(status.retweetCount)"
        
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
        if let d = formatter.dateFromString(status.createdAt) {
            formatter.dateStyle = .MediumStyle
            formatter.timeStyle = .ShortStyle
            createdAtLabel.text = formatter.stringFromDate(d)
        }
        self.updateCreatedAtLabelFrame()
        
        self.frame = CGRect(
            x: self.frame.origin.x,
            y: self.frame.origin.y,
            width: self.frame.size.width,
            height:max(self.bottomOrigin(createdAtLabel), self.bottomOrigin(socialCountLabel)) + margin.bottom
        )
        
        // fav
        // rt
    }
}
