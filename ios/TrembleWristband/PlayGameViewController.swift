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
import CoreBluetooth

class PlayGameViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate, CBPeripheralDelegate {

    @IBOutlet weak var roomNumberLabel: UILabel!
    @IBOutlet weak var mapView: GMSMapView!
    var locationManager: CLLocationManager?
    
    var asobiPeripheral: CBPeripheral?
    var heartBeatCharacteristic: CBCharacteristic?
    var vibrationCharacteristic: CBCharacteristic?
    
    var roomID: String?
    var twitterID: String?
    var timer:NSTimer?
    var didUpdate = true
    var isAbnormal = "false"
    var users = [User]()
    var averageHeartBeat = 0
    let defalutHeartBeat = NSUserDefaults.standardUserDefaults().integerForKey(kUserDefaultHeartBeatKey)
    
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
        
        asobiPeripheral?.delegate = self
        
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
    
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        if characteristic.UUID.isEqual(kHeartBeatCharacteristicUUID) {
            if let value = characteristic.value {
                var heartBeat: NSInteger = 0
                value.getBytes(&heartBeat, length: sizeof(NSInteger))
                averageHeartBeat = (averageHeartBeat+heartBeat)/2
                if averageHeartBeat > defalutHeartBeat+30 {
                    isAbnormal = "true"
                } else {
                    isAbnormal = "false"
                }
            }
        }
    }
    
    func switchVibration(on: Bool) {
        var switchValue = "0"
        if on { switchValue = "1" }
        guard let value = switchValue.dataUsingEncoding(NSUTF8StringEncoding) else { return }
        guard let vibrationCharacteristic = vibrationCharacteristic else { return }
        asobiPeripheral?.writeValue(value, forCharacteristic: vibrationCharacteristic, type: .WithResponse)
    }

    
    
    
}
