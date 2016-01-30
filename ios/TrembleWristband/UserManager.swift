//
//  UserManager.swift
//  TrembleWristband
//
//  Created by Baba Minami on 1/25/16.
//  Copyright © 2016 AutumnCOJT. All rights reserved.
//

class UserManager: NSObject {

    static let sharedInstance = UserManager()
    
    private var me: User?
    private var others = [User]()
    
    func setMe(me: User?) {
        self.me = me
    }
    
    func setOther(user: User) {
        others.append(user)
    }
    
    func setOthers(users: [User]) {
        var otherUsers = [User]()
        for user in users {
            if user.twitterId == me?.twitterId { continue }
            otherUsers.append(user)
        }
        others = otherUsers
    }
    
    func getMe() -> User? {
        return me
    }
    
    func getOthers() -> [User] {
        return others
    }
    
    func deleteMe() {
        me = nil
    }
}
