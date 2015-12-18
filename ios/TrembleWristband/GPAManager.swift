//
//  GPAManager.swift
//  TrembleWristband
//
//  Created by Baba Minami on 12/18/15.
//  Copyright © 2015 AutumnCOJT. All rights reserved.
//

import UIKit
import CoreLocation

class GPAManager: NSObject, CLLocationManagerDelegate{

    private var locationManager:CLLocationManager!
    
    private var latitude = 0.0
    private var longitude = 0.0
    
    class var sharedInstance: GPAManager {
        struct Singleton {
            static var instance = GPAManager()
        }
        return Singleton.instance
    }
    
    func start() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 100
        locationManager.startUpdatingLocation()
    }
    
    func coordinate() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
   
//delegate
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
    
}
