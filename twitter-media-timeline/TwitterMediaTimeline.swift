
import UIKit
import Social
import Accounts

typealias TMTRequest = (maxId: String?, account: ACAccount)
typealias TMTResultHandler = (idArray: [String]) -> ()

protocol TwitterMediaTimelineDataSource : class {
    func getNextStatusIds(request: TMTRequest, callback: TMTResultHandler) -> ()
}

class TwitterMediaTimeline : UIViewController {
    
    weak var dataSource: TwitterMediaTimelineDataSource?
    
    var account : ACAccount?
    var nextMaxId : String?
    var statusIdArray : [String] = []
    var statusMap : [String:TweetStatus] = [:]
    var collectionView : UICollectionView?
    let ReuseIdentifier = "cell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = self.view.bounds.size
        layout.minimumLineSpacing = 0.0;
        layout.minimumInteritemSpacing = 0.0;
        layout.sectionInset = UIEdgeInsetsZero;
        layout.scrollDirection = .Horizontal
        
        collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: layout)
        collectionView!.dataSource = self
        collectionView!.pagingEnabled = true
        collectionView!.registerClass(TweetStatusCell.classForCoder(), forCellWithReuseIdentifier:ReuseIdentifier)
        
        view.addSubview(collectionView!)
        
        self.dataSource?.getNextStatusIds((maxId: nextMaxId, account: account!), callback: self.resultHandler)
    }
    
    func resultHandler(idList: [String]) {
        
        if idList.isEmpty {
            nextMaxId = nil
        } else {
            nextMaxId = String(minElement(idList.map({(x:String) in x.toInt()!})) - 1)
        }
        
        statusIdArray += idList
        
        dispatch_async(dispatch_get_main_queue()) {
            self.collectionView?.reloadData()
        }
    }
}

extension TwitterMediaTimeline : UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return statusIdArray.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if indexPath.row + 1 == statusIdArray.count {
            if let maxId = nextMaxId {
                self.dataSource?.getNextStatusIds((maxId: maxId, account: account!), callback: self.resultHandler)
            }
        }
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(ReuseIdentifier, forIndexPath: indexPath) as! TweetStatusCell
        self.loadStatus(statusIdArray[indexPath.row]) { status in
            cell.setStatus(status)
        }
        return cell;
    }
}

//MARK: Network
extension TwitterMediaTimeline {
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
            handler(JSON(data: body!))
        }
    }
    
    func loadStatus(statusId : String, completion : TweetStatus -> Void) {
        if let json = statusMap[statusId] {
            completion(json)
        } else {
            let url = "https://api.twitter.com/1.1/statuses/show/\(statusId).json"
            
            let request = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: .GET, URL: NSURL(string: url), parameters: nil)
            request.account = self.account
            request.performRequestWithHandler { body, response, error in
                let json = JSON(data: body!)
                if let status = TweetStatus.fromJSON(json) {
                    self.statusMap[statusId] = status
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