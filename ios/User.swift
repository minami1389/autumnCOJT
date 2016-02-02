//
//  User.swift
//  TrembleWristband
//
//  Created by Baba Minami on 12/9/15.
//  Copyright © 2015 AutumnCOJT. All rights reserved.
//

import UIKit
import TwitterKit
import CoreLocation

class User: NSObject, NSURLSessionDelegate, NSURLSessionDataDelegate {

    var id: String?
    var longitude: Double?
    var latitude: Double?
    var is_abnormality: Bool?
    var twitterId: String?
    var name: String?
    var screenName: String?
    var image:UIImage?

    
    init(twitterId: String) {
        super.init()
        self.twitterId = twitterId
        self.longitude = 0
        self.latitude = 0
        self.is_abnormality = false
    }
    
    func containsUsers(users:NSArray) -> Bool {
        for obj in users {
            if let user = obj as? User {
                if user.twitterId == self.twitterId { return true }
            }
        }
        return false
    }
    
    func fetchUserTwitterData(completion:()->Void) {
        let client = Twitter.sharedInstance().APIClient
        guard let twitterId = twitterId else { return }
        client.loadUserWithID(twitterId, completion: { (obj, error) in
            if error != nil {
                print("error:\(error)")
                return
            }
            do {
                let iconUrl = NSURL(string: (obj?.profileImageURL)!)
                let iconData = try NSData(contentsOfURL: iconUrl!, options: NSDataReadingOptions.DataReadingMappedIfSafe)
                let image = UIImage(data: iconData)
                self.name = (obj?.name)!
                self.screenName = (obj?.formattedScreenName)!
                self.image = image
                completion()
            } catch { }
        })
    }
    
    func location() -> CLLocation {
        guard let latitude = latitude else { return CLLocation() }
        guard let longitude = longitude else { return CLLocation() }
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
}
