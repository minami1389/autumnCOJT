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
    
    var locationManager:CLLocationManager?
    private var didUpdateLocation:(location:CLLocation)->Void = {_ in }
    
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
    
    func setDidUpdateLocationBlock(block:(location:CLLocation)->Void) {
        didUpdateLocation = block
    }
   
//delegate
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if(CLLocationManager.authorizationStatus() == CLAuthorizationStatus.NotDetermined) {
            locationManager?.requestAlwaysAuthorization()
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        didUpdateLocation(location: newLocation)
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("locationManagerError：\(error)")
    }
    
}
