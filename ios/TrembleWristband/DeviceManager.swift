//
//  DeviceManager.swift
//  TrembleWristband
//
//  Created by Baba Minami on 2/2/16.
//  Copyright © 2016 AutumnCOJT. All rights reserved.
//

import CoreBluetooth

class DeviceManager: NSObject,CBCentralManagerDelegate, CBPeripheralDelegate {

    static let sharedInstance = DeviceManager()
    
    private var centralManager: CBCentralManager?
    private var asobiPeripheral: CBPeripheral?
    private var heartBeatCharacteristic: CBCharacteristic?
    private var vibrationCharacteristic: CBCharacteristic?
    
    private var deviceID = ""
    private var didDiscoverDevice:()->Void = {}
    private var didFailToDiscoverDevice:()->Void = {}
    
    private var timeout:NSTimer?
    
    var continuityVibrateTimer:NSTimer?
    
    private var heartbeatQueue = [Int]()
    
    func setup(deviceID: String, didDiscoverDevice:()->Void, didFailToDiscoverDevice:()->Void) {
        centralManager = CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionShowPowerAlertKey:true])
        self.deviceID = deviceID
        self.didDiscoverDevice = didDiscoverDevice
        self.didFailToDiscoverDevice = didFailToDiscoverDevice
    }
    
    func reset() {
        if let asobiPeripheral = asobiPeripheral {
            if let heartBeatCharacteristic = heartBeatCharacteristic {
                asobiPeripheral.setNotifyValue(false, forCharacteristic: heartBeatCharacteristic)
                centralManager?.cancelPeripheralConnection(asobiPeripheral)
            }
        }
        centralManager?.stopScan()
        asobiPeripheral = nil
        heartBeatCharacteristic = nil
        vibrationCharacteristic = nil
        print("device reset")
    }
    
    func stopScan() {
        centralManager?.stopScan()
    }
    
    func centralManagerDidUpdateState(central: CBCentralManager) {
        if central.state != CBCentralManagerState.PoweredOn {
            print("PoweredOff")
            return
        }
        print("PoweredOn")
        centralManager?.scanForPeripheralsWithServices(nil, options: nil)
    }
    
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        print("name0:\(advertisementData["kCBAdvDataLocalName"])")
        print("name1:\(peripheral.name)")
       if let localName = advertisementData["kCBAdvDataLocalName"] as? String {
            if localName == "\(deviceID)" {
                asobiPeripheral = peripheral
                asobiPeripheral?.delegate = self
                guard let asobiPeripheral = asobiPeripheral else { return }
                self.centralManager?.connectPeripheral(asobiPeripheral, options: nil)
            }
        }
    }
    
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        print("Connected")
        asobiPeripheral?.discoverServices(nil)
    }
    
    func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        print("Connect error...")
        didFailToDiscoverDevice()
    }
    
    func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        print("DisConnected")
        print("error:\(error)")
        reset()
        didFailToDiscoverDevice()
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        print("didDiscoverService:\(asobiPeripheral?.services)")
        print("didDiscoverService:\(asobiPeripheral)")
        if error != nil {
            print("error: \(error)")
            return
        }
        
        let services = peripheral.services!
        for service in services {
            if service.UUID.isEqual(kDeviceServiceUUID) {
            asobiPeripheral?.discoverCharacteristics([kHeartBeatCharacteristicUUID, kVibrationCharacteristicUUID], forService: service)
            }
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        print("didDiscoverCharacter")
        if error != nil {
            print("error: \(error)")
            return
        }
        guard let characteristics = service.characteristics else { return }
        for characteristic in characteristics {
            if characteristic.UUID.isEqual(kHeartBeatCharacteristicUUID) == true {
                heartBeatCharacteristic = characteristic
                guard let heartBeatCharacteristic = heartBeatCharacteristic else { return }
                asobiPeripheral?.setNotifyValue(true, forCharacteristic: heartBeatCharacteristic)
                print("notify:\(heartBeatCharacteristic)")
            } else if characteristic.UUID.isEqual(kVibrationCharacteristicUUID) == true {
                vibrationCharacteristic = characteristic
            }
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didWriteValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        if error != nil {
            print("writeError:\(error)")
            return
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didUpdateNotificationStateForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        if error != nil {
            print("notifError:\(error)")
            return
        }
        print("didUpdateNotify:\(characteristic)")
        guard let _ = heartBeatCharacteristic else { return }
        guard let _ = vibrationCharacteristic else { return }
        if heartBeatCharacteristic?.isNotifying == true {
            didDiscoverDevice()
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        
        if let error = error {
            print("error:\(error)")
        }
        if characteristic.UUID.isEqual(kHeartBeatCharacteristicUUID) {
            if let value = characteristic.value {
                var heartbeat: NSInteger = 0
                value.getBytes(&heartbeat, length: sizeof(NSInteger))
                if heartbeatQueue.count >= 10 {
                    heartbeatQueue.removeFirst()
                }
                heartbeatQueue.append(heartbeat)
                print(heartbeat)
            }
        }
    }
    
    func getHeaertbeat() -> Int {
        if heartbeatQueue.count == 0 { return 0 }
        var heartbeat = 0
        for i in heartbeatQueue {
            heartbeat += i
        }
        return heartbeat/heartbeatQueue.count
    }
    
    func vibrate(time: Double) {
        print("vibrate")
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
        guard let _ = self.vibrationCharacteristic else { return }
        asobiPeripheral?.writeValue(value, forCharacteristic: self.vibrationCharacteristic!, type: .WithResponse)
    }
    
    func continuityVibrate(interval: NSTimeInterval) {
        print("continuityVibrate")
        continuityVibrateTimer?.invalidate()
        continuityVibrateTimer = NSTimer.scheduledTimerWithTimeInterval(interval, target: self, selector: "continuitySingleVibrate", userInfo: nil, repeats: true)
    }
    
    func continuitySingleVibrate() {
        vibrate(0.3)
    }
    
    func twiceVibrate(time:NSTimeInterval) {
        print("twiceVibrate")
        vibrate(time)
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(time+1.0 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            self.vibrate(time)
        }
    }

}

