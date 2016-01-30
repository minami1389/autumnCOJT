//
//  APIManager.swift
//  TrembleWristband
//
//  Created by Baba Minami on 1/25/16.
//  Copyright © 2016 AutumnCOJT. All rights reserved.
//

import CoreLocation

class APIManager: NSObject {

    static let sharedInstance = APIManager()
    private let endPoint = "http://49.212.151.224:3000/api"
    private let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
    
    func createUser(twitterId: String, completion:(user: User)->Void) {
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
                completion(user: User(twitterId: twitterId))
            }
            task.resume()
        } catch{}
    }
    
    func createRoom(twitterIds: [String], completion:(roomId:String)->Void) {
        guard let myTwitterId = UserManager.sharedInstance.getMe()?.twitterId else { return }
        var urlString = "\(endPoint)/rooms?userID=\(myTwitterId)"
        for id in twitterIds {
            urlString += "+\(id)"
        }
        let params: [String:AnyObject] = [
            "host_user": myTwitterId
        ]
        guard let url = NSURL(string: urlString) else { return }
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            try request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: .PrettyPrinted)
            let task = session.dataTaskWithRequest(request) { (data, res, err) -> Void in
                if err != nil {
                    print("creatRoomError:\(err)")
                    return
                }
                self.fetchRoom(myTwitterId, completion: { (roomId) -> Void in
                    completion(roomId: roomId)
                })
            }
            task.resume()
        } catch{ }
    }
    
    func fetchRoom(hostTwitterId: String, completion:(roomId:String)->Void) {
        guard let url = NSURL(string: "\(endPoint)/rooms?getRoomFromHostUserId=\(hostTwitterId)") else { return }
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        
        let task = session.dataTaskWithRequest(request) { (data, res, err) -> Void in
            if err != nil {
                print("getRoomError:\(err)")
                return
            }
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as! NSArray
                guard let room = json.lastObject as? NSDictionary else { return }
                guard let roomId = room["id"] as? Int else {
                    print("id:\(room["id"])")
                    return
                }
                completion(roomId: String(roomId))
            } catch {}
        }
        task.resume()
    }
    
    func updateUser(twitterId: String, location:CLLocation, isAbnormal:String, completion:()->Void) {
        let params:[String: AnyObject] = [
            "twitter_id": twitterId,
            "longitude": location.coordinate.longitude,
            "latitude": location.coordinate.latitude,
            "is_abnormality": isAbnormal
        ]
        
        guard let url = NSURL(string: "\(endPoint)/users/\(twitterId)") else { return }
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            try request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: .PrettyPrinted)
        } catch{}
        let task = session.dataTaskWithRequest(request) { (data, res, err) -> Void in
            if err != nil {
                print("updateUserInfoError:\(err)")
                return
            }
            completion()
        }
        task.resume()
    }
    
    func fetchUsers(roomID: String, completion:([User])->Void) {
        guard let url = NSURL(string: "\(endPoint)/users?getUsersFromRoomId=\(roomID)") else { return }
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        let task = session.dataTaskWithRequest(request) { (data, res, err) -> Void in
            if err != nil {
                print("getRoomError:\(err)")
                return
            }
            do {
                let dispatchGroup = dispatch_group_create()
                let dispatchQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
                
                var users = [User]()
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as! NSArray
                for obj in json {
                    dispatch_group_enter(dispatchGroup)
                    guard let twitterID = obj["twitter_id"] else { return }
                    guard let id = twitterID as? String else { return }
                    self.fetchUser(id, completion: { (user) -> Void in
                        guard let user = user else { return }
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            user.fetchUserTwitterData({
                                users.append(user)
                                dispatch_group_leave(dispatchGroup)
                            })
                        })
                    })
                }
            
                dispatch_group_notify(dispatchGroup, dispatchQueue, { () -> Void in
                    completion(users)
                })
                
                
            } catch {}
        }
        task.resume()
    }
    
    
    func fetchUser(twitterId: String, completion:(User?)->Void) {
        guard let url = NSURL(string: "\(endPoint)/users/\(twitterId)") else { return }
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        let task = session.dataTaskWithRequest(request) { (data, res, err) -> Void in
            if err != nil {
                print("getRoomError:\(err)")
                return
            }
            do {
                guard let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as? NSDictionary else {
                    completion(nil)
                    return
                }
                let user = User(twitterId: twitterId)
                user.longitude = json["longitude"] as? Double
                user.latitude = json["latitude"] as? Double
                let isAbnormality = json["is_abnormality"] as? Int
                user.is_abnormality = (isAbnormality == 1)
                completion(user)
                
            } catch {}
        }
        task.resume()

    }
    
    func deleteRoom(roomID: String) {
        guard let url = NSURL(string: "\(endPoint)/rooms/\(roomID)") else { return }
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "DELETE"
        let task = session.dataTaskWithRequest(request) { (data, res, err) -> Void in
            if err != nil {
                print("deleteRoomError:\(err)")
                return
            }
            print("delete")
        }
        task.resume()
    }

    
    
}
