//
//  CreateRoomViewController.swift
//  TrembleWristband
//
//  Created by minami on 11/13/15.
//  Copyright © 2015 AutumnCOJT. All rights reserved.
//

import UIKit
import CoreBluetooth
import TwitterKit


//Peripheral

class CreateRoomViewController: UIViewController, CBPeripheralManagerDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var peripheralManager: CBPeripheralManager?
    var writeCharacteristic: CBMutableCharacteristic?
    var notifyCharacteristic: CBMutableCharacteristic?

    var memberUsers = [User]()
 
    override func viewDidLoad() {
        super.viewDidLoad()
        self.peripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: [CBPeripheralManagerOptionShowPowerAlertKey:true]);
    }
    
    override func viewWillDisappear(animated: Bool) {
        peripheralManager?.stopAdvertising()
    }

    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager) {
        if peripheral.state != CBPeripheralManagerState.PoweredOn { return }
        writeCharacteristic = CBMutableCharacteristic(type: kWriteCharacteristicUUID, properties: .Write, value: nil, permissions: .Writeable)
        notifyCharacteristic = CBMutableCharacteristic(type: kNotifyCharacteristicUUID, properties: .Notify, value: nil, permissions: .Readable)
        let service = CBMutableService(type: kServiceUUID, primary: true)
        guard let writeCharacteristic = writeCharacteristic else { return }
        guard let notifyCharacteristic = notifyCharacteristic else { return }
        service.characteristics = [writeCharacteristic, notifyCharacteristic]
        peripheralManager?.addService(service)
        if let userId = UserManager.sharedInstance.getMe()?.twitterId {
            peripheralManager?.startAdvertising([CBAdvertisementDataLocalNameKey:"asobeat:\(userId)"])
        }
    }
    
    func peripheralManagerDidStartAdvertising(peripheral: CBPeripheralManager, error: NSError?) {
        if error != nil {
            print("Advertising Failed:\(error)")
        }
    }
    
    func peripheralManager(peripheral: CBPeripheralManager, didReceiveWriteRequests requests: [CBATTRequest]) {
        for request in requests {
            peripheralManager?.respondToRequest(request, withResult: CBATTError.Success)
            guard let requestValue = request.value else { return }
            guard let twitterId = String(data: requestValue, encoding: NSUTF8StringEncoding) else { return }
            let user = User(twitterId: twitterId)
            memberUsers.append(user)
            user.fetchUserTwitterData({
                self.tableView.reloadData()
            })
        }
    }

//TableView
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memberUsers.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MemberUserCell") as! MemberUserTableViewCell
        let user = memberUsers[indexPath.row]
        cell.iconImageView?.image = user.image
        cell.nameLabel.text = user.screenName
        cell.idLabel.text = user.name
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let value = memberUsers[indexPath.row].twitterId?.dataUsingEncoding(NSUTF8StringEncoding) else { return }
        guard let notifyCharacteristic = notifyCharacteristic else { return }
        peripheralManager?.updateValue(value, forCharacteristic: notifyCharacteristic, onSubscribedCentrals: nil)
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        cell?.userInteractionEnabled = false
    }
    
//IBAction
    @IBAction func didPushedCancelButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func didPushedDoneButton(sender: AnyObject) {
        var acceptedUserIds = [String]()
        for var i = 0; i < memberUsers.count; i++ {
            let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: i, inSection: 0))
            if cell?.selected == true {
                guard let twitterId = memberUsers[i].twitterId else { return }
                acceptedUserIds.append(twitterId)
            }
        }
        APIManager.sharedInstance.createRoom(acceptedUserIds) { (roomId) -> Void in
            print("roomId:\(roomId)")
            NSUserDefaults.standardUserDefaults().setObject(roomId, forKey: kUserDefaultRoomIdKey)
            self.broadCastRoomNumberToOther(roomId)
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if let vc = self.storyboard?.instantiateViewControllerWithIdentifier("measureVC") as? MeasureHeartBeatViewController {
                    self.presentViewController(vc, animated: true, completion: nil)
                }
            })
            
        }
    }
    
    func broadCastRoomNumberToOther(roomId: String) {
        guard let value = "createRoom:\(roomId)".dataUsingEncoding(NSUTF8StringEncoding) else { return }
        guard let notifyCharacteristic = self.notifyCharacteristic else { return }
        self.peripheralManager?.updateValue(value, forCharacteristic: notifyCharacteristic, onSubscribedCentrals: nil)
    }
   
}
