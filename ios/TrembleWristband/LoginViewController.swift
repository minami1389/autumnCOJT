//
//  LoginViewController.swift
//  TrembleWristband
//
//  Created by minami on 11/13/15.
//  Copyright © 2015 AutumnCOJT. All rights reserved.
//

import UIKit
import TwitterKit

class LoginViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createLoginButton()
        GPAManager.sharedInstance.start()
    }
    
    func createLoginButton() {
        let logInButton = TWTRLogInButton { (session, error) in
            if let unwrappedSession = session {
                self.didLoggedIn(unwrappedSession)
            } else {
                NSLog("Login error: %@", error!.localizedDescription);
            }
        }
        logInButton.center = CGPoint(x: self.view.center.x, y: self.view.center.y+130)
        logInButton.layer.borderColor = UIColor.whiteColor().CGColor
        logInButton.layer.borderWidth = 1.0
        self.view.addSubview(logInButton)
    }
    
    func didLoggedIn(session:TWTRSession) {
        let alert = UIAlertController(title: "Logged In",
                                    message: "User \(session.userName) has logged in",
                             preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK",
                                      style: UIAlertActionStyle.Default,
                                    handler: { (action:UIAlertAction!) -> Void in
                                                self.performSegueWithIdentifier("toGameStartVC", sender: self)
                                    }))
        self.presentViewController(alert, animated: true, completion: nil)
        
        let userDefault = NSUserDefaults.standardUserDefaults()
        userDefault.setValue(session.userID, forKey: "userId")
        
        postUser(session.userID)
        print(GPAManager.sharedInstance.coordinate().latitude)
        print(GPAManager.sharedInstance.coordinate().longitude)
    }

    func postUser(twitterId:String) {
        let params:[String: AnyObject] = [
            "twitter_id": twitterId,
            "longitude": 0,
            "latitude": 0,
            "is_abnormality": "false"
        ]
        
        let url = "http://49.212.151.224:3000/api/users"
        let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            try request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: .PrettyPrinted)
        } catch{}
        let task = session.dataTaskWithRequest(request) { (data, res, err) -> Void in
            if err != nil {
                print("postUserError:\(err)")
                return
            }
        }
        task.resume()
    }
    
}
