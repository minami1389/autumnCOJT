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
    var locationManager: CLLocationManager!
    
    var roomNumber = ""
    var userId = ""
    var timer:NSTimer!
    var didUpdate = true
    var isAbnormality = "false"

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        mapView.myLocationEnabled = true
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = 300
        locationManager.startUpdatingLocation()
        
        let userDefault = NSUserDefaults.standardUserDefaults()
        roomNumber = userDefault.objectForKey("roomNumber") as! String
        userId = userDefault.objectForKey("userId") as! String
        
        timer = NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: "onUpdate:", userInfo: nil, repeats: true)
    }
    
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        let coordinate = CLLocationCoordinate2D(latitude:newLocation.coordinate.latitude,longitude:newLocation.coordinate.longitude)
        let nowPosition = GMSCameraPosition.cameraWithLatitude(coordinate.latitude,longitude:coordinate.longitude,zoom:15)
        print(coordinate)
        mapView.camera = nowPosition
    }
    
    func onUpdate(timer:NSTimer) {
        if didUpdate {
            didUpdate = false
            updateUserInfo()
        }
    }
    
    func updateUserInfo() {
        let params:[String: AnyObject] = [
            "twitter_id": userId,
            "longitude": (locationManager.location?.coordinate.longitude)!,
            "latitude": (locationManager.location?.coordinate.latitude)!,
            "is_abnormality": isAbnormality
        ]
        
        let url = "http://49.212.151.224:3000/api/users/\(userId)"
        let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        request.HTTPMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            try request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: .PrettyPrinted)
        } catch{}
        let task = session.dataTaskWithRequest(request) { (data, res, err) -> Void in
            self.didUpdate = true
            if err != nil {
                print("updateUserInfoError:\(err)")
                return
            }
            
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as! NSArray
                print(json)
            } catch {}
        }
        task.resume()
    }
    
    /*
    func getRoomUsers() {
        let url = "http://49.212.151.224:3000/api/users/:\(roomNumber)"
    
    let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
    let request = NSMutableURLRequest(URL: NSURL(string: url)!)
    request.HTTPMethod = "GET"
    
    let task = session.dataTaskWithRequest(request) { (data, res, err) -> Void in
        if err != nil {
            print("getRoomError:\(err)")
            return
        }
        
        var roomNumber = ""
        do {
            let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as! NSArray
            let room = json.firstObject! as! NSDictionary
            roomNumber = room["_id"] as! String
            let userDefault = NSUserDefaults.standardUserDefaults()
            userDefault.setObject(roomNumber, forKey: "roomNumber")
        } catch {}
        
        let value = "createRoom:\(roomNumber)".dataUsingEncoding(NSUTF8StringEncoding)!
        self.peripheralManager.updateValue(value, forCharacteristic: self.notifyCharacteristic, onSubscribedCentrals: nil)
        self.performSegueWithIdentifier("createToMeasure", sender: self)
    }
    task.resume()
    }*/
}
