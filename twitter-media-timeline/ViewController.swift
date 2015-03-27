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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let btn0 = UIButton.buttonWithType(.System) as! UIButton
        btn0.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height/2)
        btn0.backgroundColor = UIColor.redColor()
        btn0.addTarget(self, action: "selectTwitterAccount", forControlEvents: .TouchUpInside)
        
        self.view.addSubview(btn0)
    }
    
    func showCollectionView(account : ACAccount){
        let vc = TwitterMediaTimeline()
        vc.account = account
        self.presentViewController(vc, animated: true, completion: nil)
    }

    func selectTwitterAccount()
    {
        if(SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter)){
            let accountStore = ACAccountStore()
            let twitterAccountType = accountStore.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
            
            accountStore.requestAccessToAccountsWithType(twitterAccountType, options: nil) {granted, error in
                if (granted) {
                    let accounts = accountStore.accountsWithAccountType(twitterAccountType)
                    if(accounts.count == 1) {
                        dispatch_async(dispatch_get_main_queue()) { [weak self] in
                            self!.showCollectionView(accounts[0] as! ACAccount)
                        }
                    } else {
                        let alert = UIAlertController(title: "アカウントを選択してください", message: nil, preferredStyle: .ActionSheet)
                        for item in accounts {
                            let account = item as! ACAccount
                            alert.addAction(UIAlertAction(title: "@"+account.username, style: .Default) { action in
                                self.showCollectionView(account)
                            })
                        }
                        alert.addAction(UIAlertAction(title: "キャンセル", style: .Cancel, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                }
            }
        } else {
            let message = "本体の設定からTwitterアカウントを登録してください"
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
}

