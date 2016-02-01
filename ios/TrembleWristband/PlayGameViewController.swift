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

class PlayGameViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate, CBPeripheralDelegate,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var mapView: GMSMapView!
    
    @IBOutlet weak var memberTableView: UITableView!
    @IBOutlet weak var memberTableViewBottom: NSLayoutConstraint!
    @IBOutlet weak var myImageView: UIImageView!
    @IBOutlet weak var myScreenNameLabel: UILabel!
    @IBOutlet weak var myUserNameLabel: UILabel!
    @IBOutlet weak var myHeartBeatLabel: UILabel!
    
    var locationManager: CLLocationManager?
    var asobiPeripheral: CBPeripheral?
    var heartBeatCharacteristic: CBCharacteristic?
    var vibrationCharacteristic: CBCharacteristic?
    
    var roomID: String?
    var timer:NSTimer?
    var didUpdate = true
    var isAbnormal = "false"
    let defalutHeartBeat = NSUserDefaults.standardUserDefaults().integerForKey(kUserDefaultHeartBeatKey)
    var averageHeartBeat = NSUserDefaults.standardUserDefaults().integerForKey(kUserDefaultHeartBeatKey)
    var abnormalHeartBeatDiff = 10
    var distanceDiff:Double = 100
    
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
        
        memberTableViewBottom.constant = -150
        
        if let me = UserManager.sharedInstance.getMe() {
            myImageView.image = me.image
            myScreenNameLabel.text = me.name
            myUserNameLabel.text = me.screenName
            myHeartBeatLabel.text = String(NSUserDefaults.standardUserDefaults().integerForKey(kUserDefaultHeartBeatKey))
        }
        
        if let value = NSUserDefaults.standardUserDefaults().objectForKey(kUserDefaultRoomIdKey) as? String {
            roomID = value
        }
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        SVProgressHUD.showWithStatus("", maskType: .Gradient)
        guard let roomID = self.roomID else { return }
        APIManager.sharedInstance.fetchUsers(roomID, completion: { (users) -> Void in
            UserManager.sharedInstance.setOthers(users)
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.memberTableView.reloadData()
                SVProgressHUD.dismiss()
            })
        })
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        timer = NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: "onUpdate:", userInfo: nil, repeats: true)
    }
    
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        mapView.camera = GMSCameraPosition.cameraWithTarget(newLocation.coordinate, zoom: 15)
    }
    
    
    func onUpdate(timer:NSTimer) {
        if didUpdate {
            didUpdate = false
            guard let location = locationManager?.location else { return }
            guard let twitterID = UserManager.sharedInstance.getMe()?.twitterId else { return }
            APIManager.sharedInstance.updateUser(twitterID, location: location, isAbnormal: isAbnormal, completion: { () -> Void in
                guard let roomID = self.roomID else { return }
                APIManager.sharedInstance.fetchUsers(roomID, completion: { (users) -> Void in
                    UserManager.sharedInstance.setOthers(users)
                    self.didUpdate = true
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.addAbnormalUserMarker()
                        self.memberTableView.reloadData()
                        self.checkNarrowUser()
                    })
                })
            })
        }
    }
    
    func checkNarrowUser() {
        let me = UserManager.sharedInstance.getMe()
        for user in UserManager.sharedInstance.getOthers() {
            guard let userLocation = user.location() else { return }
            let dis = me?.location()?.distanceFromLocation(userLocation)
            if dis < distanceDiff {
                vibrate(1.0)
                return
            }
        }
    }
    
    func addAbnormalUserMarker() {
        mapView.clear()
        for user in UserManager.sharedInstance.getOthers() {
            guard let userIsAbnormal = user.is_abnormality else { return }
            if userIsAbnormal == true {
                let marker = GMSMarker()
                guard let latitude = user.latitude else { continue }
                guard let longitude = user.longitude else { continue }
                marker.position = CLLocationCoordinate2DMake(latitude, longitude)
                marker.icon = user.image
                marker.title = user.name
                marker.snippet = user.screenName
                marker.map = mapView
            }
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        if characteristic.UUID.isEqual(kHeartBeatCharacteristicUUID) {
            if let value = characteristic.value {
                var heartBeat: NSInteger = 0
                value.getBytes(&heartBeat, length: sizeof(NSInteger))
                averageHeartBeat = (averageHeartBeat+heartBeat)/2
                myHeartBeatLabel.text = String(averageHeartBeat)
                if averageHeartBeat > defalutHeartBeat+abnormalHeartBeatDiff && isAbnormal == "false" {
                    isAbnormal = "true"
                    myHeartBeatLabel.textColor = UIColor(red: 255/255, green: 85/85, blue: 85/85, alpha: 1.0)
                    twiceVibrate(2.0)
                } else {
                    isAbnormal = "false"
                    myHeartBeatLabel.textColor = UIColor.whiteColor()
                }
            }
        }
    }
    
    func twiceVibrate(time:Double) {
        vibrate(time)
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(time+1.0 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            self.vibrate(time)
        }
    }
    
    func vibrate(time: Double) {
        switchVibration(true)
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(time * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            self.switchVibration(false)
        }
    }
    
    func switchVibration(on: Bool) {
        var switchValue = "0"
        if on { switchValue = "1" }
        guard let value = switchValue.dataUsingEncoding(NSUTF8StringEncoding) else { return }
        guard let vibrationCharacteristic = vibrationCharacteristic else { return }
        asobiPeripheral?.writeValue(value, forCharacteristic: vibrationCharacteristic, type: .WithResponse)
    }

//TableView
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return UserManager.sharedInstance.getOthers().count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PlayUserCell", forIndexPath: indexPath) as! PlayUserTableViewCell
        let member = UserManager.sharedInstance.getOthers()[indexPath.row]
        cell.imageView?.image = member.image
        cell.nameLabel.text = member.name
        cell.idLabel.text = member.screenName
        return cell
    }
    
    @IBAction func didTapMemberSwitchButton(sender: AnyObject) {
        if memberTableViewBottom.constant == 0 {
            memberTableViewBottom.constant = -150
        } else {
            memberTableViewBottom.constant = 0
        }
        UIView.animateWithDuration(0.3) { () -> Void in
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func didTapEndButton(sender: AnyObject) {
        let alert = UIAlertController(title: "End Game", message: "本当に終了してよろしいですか？", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "End", style: .Default, handler: { (action) -> Void in
            guard let roomID = self.roomID else { return }
            APIManager.sharedInstance.deleteRoom(roomID, completion: {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                      UIApplication.sharedApplication().keyWindow?.rootViewController?.dismissViewControllerAnimated(true, completion: nil)
                })
            })
        }))
        presentViewController(alert, animated: true, completion: nil)
    }
}
