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
    
    var peripheralManager: CBPeripheralManager!
    var writeCharacteristic: CBMutableCharacteristic!
    var notifyCharacteristic: CBMutableCharacteristic!

    var myUserId = ""
    
    var memberUsers = [User]()
 
    override func viewDidLoad() {
        super.viewDidLoad()
        self.peripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: [CBPeripheralManagerOptionShowPowerAlertKey:true]);
        let userDefault = NSUserDefaults.standardUserDefaults()
        myUserId = String(userDefault.valueForKey("userId")!)
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.peripheralManager.stopAdvertising()
    }

    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager) {
        if peripheral.state != CBPeripheralManagerState.PoweredOn { return }
        
        writeCharacteristic = CBMutableCharacteristic(type: kWriteCharacteristicUUID, properties: .Write, value: nil, permissions: .Writeable)
        notifyCharacteristic = CBMutableCharacteristic(type: kNotifyCharacteristicUUID, properties: .Notify, value: nil, permissions: .Readable)
        let service = CBMutableService(type: kServiceUUID, primary: true)
        service.characteristics = [writeCharacteristic, notifyCharacteristic]
        peripheralManager.addService(service)
        let advertisingData = [CBAdvertisementDataLocalNameKey:"asobeat:" + myUserId]
        peripheralManager.startAdvertising(advertisingData)
    }
    
    func peripheralManagerDidStartAdvertising(peripheral: CBPeripheralManager, error: NSError?) {
        if error != nil {
            print("Advertising Failed:\(error)")
        }
    }
    
    func peripheralManager(peripheral: CBPeripheralManager, didReceiveWriteRequests requests: [CBATTRequest]) {
        for request in requests {
            self.peripheralManager.respondToRequest(request, withResult: CBATTError.Success)
            let twitterId = String(data: request.value!, encoding: NSUTF8StringEncoding)
            let user = User(id: twitterId!)
            memberUsers.append(user)
            user.fetchHostUserTwitterData({
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
        let value = memberUsers[indexPath.row].id.dataUsingEncoding(NSUTF8StringEncoding)!
        peripheralManager.updateValue(value, forCharacteristic: notifyCharacteristic, onSubscribedCentrals: nil)
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        cell?.userInteractionEnabled = false
    }
    
//IBAction
    @IBAction func didPushedCancelButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(false, completion: nil)
    }

    @IBAction func didPushedDoneButton(sender: AnyObject) {
        var acceptedUserIds = [String]()
        for var i = 0; i < memberUsers.count; i++ {
            let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: i, inSection: 0))
            if cell?.selected == true {
                acceptedUserIds.append(memberUsers[i].id)
            }
        }
        createRoom(acceptedUserIds)
        
    }
    
    func createRoom(userIds:[String]) {
        var url = "http://49.212.151.224:3000/api/rooms?userID=\(myUserId)"
        for id in userIds {
            url += "+\(id)"
        }
        print(url)
        
        let params: [String:AnyObject] = [
            "host_user": myUserId
        ]
        
        let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        request.HTTPMethod = "POST"
        
        do {
            try request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: .PrettyPrinted)
        } catch{}
        let task = session.dataTaskWithRequest(request) { (data, res, err) -> Void in
            if err != nil {
                print("creatRoomError:\(err)")
                return
            }
             print("creatRoom:\(res)")
        }
        task.resume()
    }
    
    
   
}
