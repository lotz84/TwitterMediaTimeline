//
//  TwitterMediaTimelineViewController.swift
//  twitter-media-timeline
//
//  Created by Hirose Tatsuya on 2015/03/26.
//  Copyright (c) 2015年 lotz84. All rights reserved.
//

import UIKit
import Social
import Accounts

class TwitterMediaTimeline : UIViewController {
    
    var account : ACAccount?
    var statusIds : [String] = []
    var nextSinceId = "0"
    var statusJSON : [String:TweetStatus] = [:]
    var collectionView : UICollectionView?
    let ReuseIdentifier = "cell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = self.view.bounds.size
        //layout.headerReferenceSize = CGSizeMake(0, 0);
        //layout.footerReferenceSize = CGSizeMake(0, 0);
        layout.minimumLineSpacing = 0.0;
        layout.minimumInteritemSpacing = 0.0;
        layout.sectionInset = UIEdgeInsetsZero;
        layout.scrollDirection = .Horizontal
        
        self.collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: layout)
        self.view.addSubview(collectionView!)
        
        collectionView!.pagingEnabled = true
        
        collectionView!.delegate = self
        collectionView!.dataSource = self
        
        collectionView!.registerClass(TweetStatusCell.classForCoder(), forCellWithReuseIdentifier:ReuseIdentifier)
        
        self.loadNextTweets()
    }
    
    func defaultRequestHandler(handler: JSON -> Void) -> SLRequestHandler {
        return { body, response, error in
            if (body == nil) {
                println("HTTPRequest Error: \(error.localizedDescription)")
                return
            }
            if (response.statusCode < 200 && 300 <= response.statusCode) {
                println("The response status code is \(response.statusCode)")
                return
            }
            
            let json = JSON(data: body!)
            
            handler(json)
        }
    }
    
    func loadNextTweets()
    {
        let url = "https://api.twitter.com/1.1/search/tweets.json"
        let param = [
            "q":"#adfjls",
            "since_id":self.nextSinceId,
            "result_type": "recent",
            "count": "100"
        ]
        
        let request = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: .GET, URL: NSURL(string: url), parameters: param)
        request.account = self.account
        request.performRequestWithHandler(defaultRequestHandler { json in
            
            self.nextSinceId = json["search_metadata"]["max_id"].stringValue
            
            for status in json["statuses"].arrayValue {
                if status["retweeted_status"] != nil {
                    continue
                }
                if let id = status["id_str"].string {
                    self.statusIds.append(id)
                }
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                self.collectionView?.reloadData()
            }
        })
    }
    
    func loadStatus(statusId : String, completion : TweetStatus -> Void) {
        if let json = self.statusJSON[statusId] {
            completion(json)
        } else {
            let url = "https://api.twitter.com/1.1/statuses/show/\(statusId).json"
            
            let request = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: .GET, URL: NSURL(string: url), parameters: nil)
            request.account = self.account
            request.performRequestWithHandler { body, response, error in
                let json = JSON(data: body!)
                if let status = TweetStatus.fromJSON(json) {
                    println("===================================")
                    println(json)
                    self.statusJSON[statusId] = status
                    dispatch_async(dispatch_get_main_queue()) {
                        completion(status)
                    }
                } else {
                    println("TweetStatus JSON parse fail")
                }
            }
        }
    }
}

extension TwitterMediaTimeline : UICollectionViewDelegate {

}

extension TwitterMediaTimeline : UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.statusIds.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(ReuseIdentifier, forIndexPath: indexPath) as! TweetStatusCell
        self.loadStatus(self.statusIds[indexPath.row]) { status in
            cell.setStatus(status)
        }
        return cell;
    }
}