//
//  GameStartViewController.swift
//  TrembleWristband
//
//  Created by minami on 11/13/15.
//  Copyright © 2015 AutumnCOJT. All rights reserved.
//

import UIKit
import CoreLocation

class GameStartViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var userNameLabel: UILabel!
    
    var locationManager:CLLocationManager!
    
    var latitude = 0.0
    var longitude = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let userDefault = NSUserDefaults.standardUserDefaults()
        let userId = userDefault.valueForKey("userId")
        userNameLabel.text = String(userId)
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 100
        locationManager.startUpdatingLocation()
    }

//locationManager
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if(CLLocationManager.authorizationStatus() == CLAuthorizationStatus.NotDetermined) {
            locationManager.requestAlwaysAuthorization()
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        latitude =  (manager.location?.coordinate.latitude)!
        longitude = (manager.location?.coordinate.longitude)!
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("error：\(error)")
    }

    
//IBAction
    @IBAction func didTapScreen(sender: AnyObject) {
        self.view.endEditing(true)
    }
    
    @IBAction func didPushedCreateRoomButton(sender: AnyObject) {
        performSegueWithIdentifier("toCreateRoomVC", sender: self)
    }

    @IBAction func didPushedJoinRoomButton(sender: AnyObject) {
        performSegueWithIdentifier("toJoinRoomVC", sender: self)
    }
}
