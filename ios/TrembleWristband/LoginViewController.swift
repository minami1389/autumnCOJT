//
//  LoginViewController.swift
//  TrembleWristband
//
//  Created by minami on 11/13/15.
//  Copyright © 2015 AutumnCOJT. All rights reserved.
//

import UIKit
import TwitterKit
import CoreLocation

class LoginViewController: UIViewController, CLLocationManagerDelegate {

    var locationManager:CLLocationManager!
    
    var latitude = 0.0
    var longitude = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createLoginButton()
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 100
        locationManager.startUpdatingLocation()
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
        userDefault.setValue(session.userID, forKey: "userID")
    }

    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if(CLLocationManager.authorizationStatus() == CLAuthorizationStatus.NotDetermined) {
            locationManager.requestAlwaysAuthorization()
        }
    }

    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        latitude =  (manager.location?.coordinate.latitude)!
        longitude = (manager.location?.coordinate.longitude)!
        print(latitude)
        print(longitude)
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("error：\(error)")
    }
    
    
    
}
