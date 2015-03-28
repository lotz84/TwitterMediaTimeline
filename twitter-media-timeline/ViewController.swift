//
//  ViewController.swift
//  twitter-media-timeline
//
//  Created by Hirose Tatsuya on 2015/03/26.
//  Copyright (c) 2015年 lotz84. All rights reserved.
//

import UIKit
import Social
import Accounts

class ViewController: UIViewController {

    @IBOutlet weak var queryTextField: UITextField!
    
    func showTwitterMediaTimeline(account : ACAccount){
        let vc = TwitterMediaTimeline()
        vc.account = account
        vc.dataSource = self
        self.presentViewController(vc, animated: true, completion: nil)
    }

    @IBAction func selectTwitterAccount()
    {
        queryTextField.resignFirstResponder()
        if(SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter)){
            let accountStore = ACAccountStore()
            let twitterAccountType = accountStore.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
            
            accountStore.requestAccessToAccountsWithType(twitterAccountType, options: nil) {granted, error in
                if granted {
                    let accounts = accountStore.accountsWithAccountType(twitterAccountType)
                    if accounts.count == 1 {
                        dispatch_async(dispatch_get_main_queue()) { [weak self] in
                            self!.showTwitterMediaTimeline(accounts[0] as! ACAccount)
                        }
                    } else {
                        let alert = UIAlertController(title: "Select User", message: nil, preferredStyle: .ActionSheet)
                        for item in accounts {
                            let account = item as! ACAccount
                            alert.addAction(UIAlertAction(title: "@"+account.username, style: .Default) { action in
                                self.showTwitterMediaTimeline(account)
                            })
                        }
                        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                }
            }
        } else {
            let message = "No User"
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func defaultRequestHandler(handler: JSON -> Void) -> SLRequestHandler {
        return { body, response, error in
            if body == nil {
                println("HTTPRequest Error: \(error.localizedDescription)")
                return
            }
            if response.statusCode < 200 && 300 <= response.statusCode {
                println("The response status code is \(response.statusCode)")
                return
            }
            handler(JSON(data: body!))
        }
    }
}

extension ViewController : TwitterMediaTimelineDataSource {
    
    func getNextStatusIds(request: TMTRequest, callback: TMTResultHandler) -> () {
        if queryTextField.text.isEmpty {
            return
        }
        
        let url = "https://api.twitter.com/1.1/search/tweets.json"
        var param = [
            "q": queryTextField.text,
            "result_type": "recent",
            "count": "100"
        ]
        if let maxId = request.maxId {
            param.updateValue(maxId, forKey: "max_id")
        }
        
        let slRequest = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: .GET, URL: NSURL(string: url), parameters: param)
        slRequest.account = request.account
        slRequest.performRequestWithHandler(defaultRequestHandler { json in
            
            var idArray : [String] = []
            for status in json["statuses"].arrayValue {
                if status["retweeted_status"] != nil {
                    continue
                }
                if let id = status["id_str"].string {
                    idArray.append(id)
                }
            }
            
            callback(idArray: idArray)
        })
    }
}

