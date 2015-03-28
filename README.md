#TwitterMediaTimeline

"Twitter Media Timeline"(TMT) is focused on displaying not only tweets but tweets with media. If you search for ["#cat"](https://twitter.com/search?q=%23cat&src=typd) on Twitter, there are lots of photos and movies. TMT beautifully and impressively displays those tweets for you.

![](http://i.gyazo.com/e67c8439ef0bf233faa61e711b224d44.gif)

##Feature
* Auto Preview
  * Image (URL and Twitter upload)
  * GIF   (URL and Twitter upload)
  * Instagram URL
  * Gyazo (image only)
* Multiple Photos

##Example

```swift
func showTwitterMediaTimeline(account : ACAccount){
    let vc = TwitterMediaTimeline()
    vc.account = account
    vc.dataSource = self
    self.presentViewController(vc, animated: true, completion: nil)
}
```

###DataSource Delegate (Search Tweet)

```swift
extension ViewController : TwitterMediaTimelineDataSource {
    func getNextStatusIds(request: TMTRequest, callback: TMTResultHandler) -> () {
        let url = "https://api.twitter.com/1.1/search/tweets.json"
        var param = [
            "q": "query string",
            "result_type": "recent",
            "count": "100"
        ]
        
        let slRequest = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: .GET, URL: NSURL(string: url), parameters: param)
        slRequest.account = request.account
        slRequest.performRequestWithHandler { body, response, error in

            let json = JSON(body!) //SwiftyJSON
            
            var idArray : [String] = []
            for status in json["statuses"].arrayValue {
                if let id = status["id_str"].string {
                    idArray.append(id)
                }
            }
            
            callback(idArray: idArray)
        }
    }
}
```

##Install & Try Demo

```shell
$ git clone git@github.com:lotz84/TwitterMediaTimeline.git
$ cd TwitterMediaTimeline
$ pod install
$ open twitter-media-timeline.xcworkspace
```

##Requirement
Swift 1.2

##Dependencies
* [SwiftyJSON](https://github.com/SwiftyJSON/SwiftyJSON)
* [SDWebImage](https://github.com/rs/SDWebImage)

##License
TwitterMediaTimeline is available under the MIT license. See the LICENSE file for more info.
