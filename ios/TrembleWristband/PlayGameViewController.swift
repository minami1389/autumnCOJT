//
//  PlayGameViewController.swift
//  TrembleWristband
//
//  Created by Baba Minami on 12/25/15.
//  Copyright © 2015 AutumnCOJT. All rights reserved.
//

import UIKit
import CoreLocation
import GoogleMaps

class PlayGameViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var roomNumberLabel: UILabel!
    @IBOutlet weak var mapView: GMSMapView!
    var locationManager: CLLocationManager?
    
    var roomID: String?
    var twitterID: String?
    var timer:NSTimer?
    var didUpdate = true
    var isAbnormal = "false"
    var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        mapView.myLocationEnabled = true
        
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.requestAlwaysAuthorization()
        locationManager?.distanceFilter = 300
        locationManager?.startUpdatingLocation()
        
        let userDefault = NSUserDefaults.standardUserDefaults()
        if let value = userDefault.objectForKey(kUserDefaultRoomIdKey) as? String {
            roomID = value
        }
        if let value = userDefault.objectForKey(kUserDefaultUserIdKey) as? String {
            twitterID = value
        }
        
        timer = NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: "onUpdate:", userInfo: nil, repeats: true)
    }
    
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        mapView.camera = GMSCameraPosition.cameraWithTarget(newLocation.coordinate, zoom: 15)
    }
    
    func onUpdate(timer:NSTimer) {
        if didUpdate {
            didUpdate = false
            guard let location = locationManager?.location else { return }
            guard let twitterID = twitterID else { return }
            APIManager.sharedInstance.updateUser(twitterID, location: location, isAbnormal: isAbnormal, completion: { () -> Void in
                guard let roomID = self.roomID else { return }
                APIManager.sharedInstance.fetchUsers(roomID, completion: { (users) -> Void in
                    self.users = users
                    self.didUpdate = true
                    print("update")
                })
            })
        }
    }
    
    
}
