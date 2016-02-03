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
import SVProgressHUD

class PlayGameViewController: UIViewController, GMSMapViewDelegate,  UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var memberTableView: UITableView!
    @IBOutlet weak var memberTableViewBottom: NSLayoutConstraint!
    @IBOutlet weak var myImageView: UIImageView!
    @IBOutlet weak var myScreenNameLabel: UILabel!
    @IBOutlet weak var myUserNameLabel: UILabel!
    @IBOutlet weak var myHeartBeatLabel: UILabel!
    @IBOutlet weak var myHeartImageView: UIImageView!
    
    @IBOutlet weak var myInfoView: UIView!
    
    var roomID = NSUserDefaults.standardUserDefaults().objectForKey(kUserDefaultRoomIdKey)
    var timer:NSTimer?
    var didUpdate = true
    var isAbnormal = "false"
    let defalutHeartBeat = NSUserDefaults.standardUserDefaults().integerForKey(kUserDefaultHeartBeatKey)
    var abnormalHeartBeatDiff = 10
    var distanceDiff:Double = 100
    
    let deviceManager = DeviceManager.sharedInstance
    let gpsManager = GPSManager.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        mapView.myLocationEnabled = true
        
        memberTableViewBottom.constant = -150
        
        if let me = UserManager.sharedInstance.getMe() {
            myImageView.image = me.image
            myScreenNameLabel.text = me.name
            myUserNameLabel.text = me.screenName
            myHeartBeatLabel.text = String(NSUserDefaults.standardUserDefaults().integerForKey(kUserDefaultHeartBeatKey))
            myHeartBeatLabel.text = "69"
        }
        
        gpsManager.setDidUpdateLocationBlock { (location) -> Void in
            self.mapView.camera = GMSCameraPosition.cameraWithTarget(location.coordinate, zoom: 15)
        }
        self.mapView.camera = GMSCameraPosition.cameraWithTarget(gpsManager.coordinate(), zoom: 15)
    }

    override func viewDidLayoutSubviews() {
        myHeartImageView.image = UIImage.fontAwesomeIconWithName(.Heartbeat, textColor: UIColor(red: 229/255, green: 57/255, blue: 53/255, alpha: 1.0), size: CGSizeMake(myHeartImageView.frame.width, myHeartImageView.frame.height)).imageWithRenderingMode(.AlwaysOriginal)
        setShadow(myInfoView)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        SVProgressHUD.showWithStatus("", maskType: .Gradient)
        guard let roomID = roomID as? String else { return }
        APIManager.sharedInstance.fetchUsers(roomID, completion: { (users) -> Void in
            UserManager.sharedInstance.setOthers(users)
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.memberTableView.reloadData()
                SVProgressHUD.dismiss()
            })
        })
    }
    
    
    func setShadow(view:UIView) {
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowOpacity = 1.0
        view.layer.shadowRadius = 1.0
        view.layer.masksToBounds = false
        view.layer.shadowColor = UIColor.darkGrayColor().CGColor
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        timer = NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: "routine", userInfo: nil, repeats: true)
    }
    
    func routine() {
        onUpdate()
        updateHeartbeat()
    }
    
    func updateHeartbeat() {
        let heartbeat = deviceManager.getHeaertbeat()
        myHeartBeatLabel.text = String(heartbeat)
        myHeartBeatLabel.text = "69"
        print(isAbnormal)
        let border = defalutHeartBeat+abnormalHeartBeatDiff
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            if heartbeat > border && self.isAbnormal == "false" {
                print("true")
                self.isAbnormal = "true"
                self.myHeartBeatLabel.textColor = UIColor(red: 255/255, green: 85/85, blue: 85/85, alpha: 1.0)
                self.deviceManager.twiceVibrate(2.0)
            } else if heartbeat <= border && self.isAbnormal == "true" {
                print("false")
                self.isAbnormal = "false"
                self.myHeartBeatLabel.textColor = UIColor.whiteColor()
            }
        }
    }
    
    func onUpdate() {
        if !didUpdate { return }
        didUpdate = false
        guard let location = GPSManager.sharedInstance.locationManager?.location else { return }
        guard let twitterID = UserManager.sharedInstance.getMe()?.twitterId else { return }
        APIManager.sharedInstance.updateUser(twitterID, location: location, isAbnormal: isAbnormal, completion: { () -> Void in
            guard let roomID = self.roomID as? String else { return }
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
    
    func checkNarrowUser() {
        var minDis:Double = 0
        let me = UserManager.sharedInstance.getMe()
        for user in UserManager.sharedInstance.getOthers() {
            guard let dis = me?.location().distanceFromLocation(user.location()) else { return }
            if minDis == 0 || minDis > dis {
                print("dis:\(dis)")
                minDis = dis
            }
        }
        if minDis != 0 && minDis < distanceDiff {
            deviceManager.continuityVibrate(minDis/20)
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
    
    @IBAction func didTapDebugButton(sender: AnyObject) {
        if isAbnormal == "true" {
            isAbnormal = "false"
        } else {
            isAbnormal = "true"
        }
        
    }
    @IBAction func didTapEndButton(sender: AnyObject) {
        let alert = UIAlertController(title: "End Game", message: "本当に終了してよろしいですか？", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "End", style: .Default, handler: { (action) -> Void in
            guard let roomID = self.roomID as? String else { return }
            APIManager.sharedInstance.deleteRoom(roomID, completion: {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                      UIApplication.sharedApplication().keyWindow?.rootViewController?.dismissViewControllerAnimated(true, completion: nil)
                })
            })
        }))
        presentViewController(alert, animated: true, completion: nil)
    }
}
