//
//  APIManager.swift
//  TrembleWristband
//
//  Created by Baba Minami on 1/25/16.
//  Copyright © 2016 AutumnCOJT. All rights reserved.
//

import UIKit

class APIManager: NSObject {

    static let sharedInstance = APIManager()
    private let endPoint = "http://49.212.151.224:3000/api"
    private let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
    
    
    func createUser(twitterId: String) {
        let nowCoordinate = GPSManager.sharedInstance.coordinate()
        let params:[String: AnyObject] = [
            "twitter_id": twitterId,
            "longitude": nowCoordinate.longitude,
            "latitude": nowCoordinate.latitude,
            "is_abnormality": "false"
        ]
        
        guard let url = NSURL(string: "\(endPoint)/users") else { return }
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            try request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: .PrettyPrinted)
            let task = session.dataTaskWithRequest(request) { (data, res, err) -> Void in
                if err != nil {
                    print("createUserError:\(err)")
                    return
                }
                do {
                    guard let data = data else { return }
                    let json = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
                    if let userInfo = json["op"] as? NSDictionary {
                        NSUserDefaults.standardUserDefaults().setValue(userInfo["_id"], forKey: "userId")
                    }
                } catch {}
            }
            task.resume()
        } catch{}
    }
    
}
