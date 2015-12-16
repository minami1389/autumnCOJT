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

    var userId = ""
    
    var users = [User]()
    var acceptUserIds = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.peripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: [CBPeripheralManagerOptionShowPowerAlertKey:true]);
        let userDefault = NSUserDefaults.standardUserDefaults()
        userId = String(userDefault.valueForKey("userId")!)
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.peripheralManager.stopAdvertising()
    }

    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager) {
        if peripheral.state != CBPeripheralManagerState.PoweredOn { return }
        
        let service = CBMutableService(type: kServiceUUID, primary: true)
        writeCharacteristic = CBMutableCharacteristic(type: kWriteCharacteristicUUID, properties: .Write, value: nil, permissions: .Writeable)
        notifyCharacteristic = CBMutableCharacteristic(type: kNotifyCharacteristicUUID, properties: .Notify, value: nil, permissions: .Readable)
        service.characteristics = [writeCharacteristic, notifyCharacteristic]
        peripheralManager.addService(service)
        let advertisingData = [CBAdvertisementDataLocalNameKey:"asobeat:" + userId]
        peripheralManager.startAdvertising(advertisingData)
    }
    
    func peripheralManagerDidStartAdvertising(peripheral: CBPeripheralManager, error: NSError?) {
        if error != nil {
            print("Failed...error:\(error)")
        }
        print("Succeeded!")
        print(peripheral.description)
    }
    
    func peripheralManager(peripheral: CBPeripheralManager, didReceiveWriteRequests requests: [CBATTRequest]) {
        for request in requests {
            self.peripheralManager.respondToRequest(request, withResult: CBATTError.Success)
            let twitterId = String(data: request.value!, encoding: NSUTF8StringEncoding)
            let user = User(id: twitterId!)
            users.append(user)
            user.fetchHostUserData({
                self.tableView.reloadData()
            })
        }
    }

//TableView
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MemberUserCell") as! MemberUserTableViewCell
        let user = users[indexPath.row] 
        cell.iconImageView?.image = user.image
        cell.nameLabel.text = user.screenName
        cell.idLabel.text = user.name
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let value = users[indexPath.row].id.dataUsingEncoding(NSUTF8StringEncoding)!
        peripheralManager.updateValue(value, forCharacteristic: notifyCharacteristic, onSubscribedCentrals: nil)
    }
    
//IBAction
    @IBAction func didPushedCancelButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(false, completion: nil)
    }

   
}
