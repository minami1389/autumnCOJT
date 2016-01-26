//
//  GPSManager.swift
//  TrembleWristband
//
//  Created by Baba Minami on 12/18/15.
//  Copyright © 2015 AutumnCOJT. All rights reserved.
//

import CoreLocation

class GPSManager: NSObject, CLLocationManagerDelegate{

    static let sharedInstance = GPSManager()
    
    private var locationManager:CLLocationManager?
   
    func start() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.distanceFilter = 100
        locationManager?.startUpdatingLocation()
    }
    
    func coordinate() -> CLLocationCoordinate2D {
        if let coordinate = locationManager?.location?.coordinate {
            return coordinate
        } else {
            return CLLocationCoordinate2DMake(0, 0)
        }
    }
   
//delegate
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if(CLLocationManager.authorizationStatus() == CLAuthorizationStatus.NotDetermined) {
            locationManager?.requestAlwaysAuthorization()
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("error：\(error)")
    }
    
}
