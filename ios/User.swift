//
//  User.swift
//  TrembleWristband
//
//  Created by Baba Minami on 12/9/15.
//  Copyright © 2015 AutumnCOJT. All rights reserved.
//

import UIKit
import TwitterKit

class User: NSObject, NSURLSessionDelegate, NSURLSessionDataDelegate {

    var id: String?
    var twitterId: String?
    var name: String?
    var screenName: String?
    var image:UIImage?
    var longitude: Float?
    var latitude: Float?
    var is_abnormality: Bool?

    
    init(twitterId: String) {
        super.init()
        self.twitterId = twitterId
    }
    
    func containsUsers(users:NSArray) -> Bool {
        for obj in users {
            if let user = obj as? User {
                if user.twitterId == self.twitterId { return true }
            }
        }
        return false
    }
    
    func fetchHostUserTwitterData(completion:()->Void) {
        let client = Twitter.sharedInstance().APIClient
        guard let twitterId = twitterId else { return }
        client.loadUserWithID(twitterId, completion: { (obj, error) in
            if error != nil {
                print("error:\(error)")
            } else {
                do {
                    let iconUrl = NSURL(string: (obj?.profileImageURL)!)
                    let iconData = try NSData(contentsOfURL: iconUrl!, options: NSDataReadingOptions.DataReadingMappedIfSafe)
                    let image = UIImage(data: iconData)
                    self.name = (obj?.name)!
                    self.screenName = (obj?.screenName)!
                    self.image = image
                    completion()
                } catch {
                    print("error")
                }
            }
        })
    }
}
