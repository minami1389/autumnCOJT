//
//  Constans.swift
//  TrembleWristband
//
//  Created by Baba Minami on 12/16/15.
//  Copyright © 2015 AutumnCOJT. All rights reserved.
//

import Foundation
import CoreBluetooth

let kUserServiceUUID = CBUUID(string: "632D50CB-9DC0-496C-8E28-19F4E0AA0DBC")
let kWriteCharacteristicUUID = CBUUID(string: "DF89A6DD-DC47-4C5C-8147-1141C62E1B04")
let kNotifyCharacteristicUUID = CBUUID(string: "3F9FC005-8D20-4631-A80F-67CE7B46D7E9")
let kHeartBeatCharacteristicUUID = CBUUID(string: "C6931E22-F44F-4635-8575-830DD8C90FFD")
let kVibrationCharacteristicUUID = CBUUID(string: "638599D4-42C2-45D8-ADBA-D24C7E35A369")
let kDeviceServiceUUID = CBUUID(string: "405C08EF-F0A8-4FD8-A6E6-DFF8177E5EE0")

let kUserDefaultTwitterIdKey = "TwitterId"
let kUserDefaultUserIdKey = "UserId"
let kUserDefaultRoomIdKey = "RoomId"
let kUserDefaultHeartBeatKey = "HeartBeat"
let kUserDefaultDeviceIDKey = "DeviceID"
let kUserDefaultHearbeatBorderKey = "HeartbeatBorder"
let kUserDefaultDistanceBorderKey = "DistanceBorder"