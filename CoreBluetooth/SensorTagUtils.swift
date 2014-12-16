//
//  SensorTagConfigurator.swift
//  CoreBluetooth
//
//  Created by Theodor Brandt on 2014-12-13.
//  Copyright (c) 2014 Theodor Brandt. All rights reserved.
//

import Foundation
import CoreBluetooth

class SensorTagUtils: NSObject{

    class func configure(peripheral: CBPeripheral, UUIDInfo:[String:String]){
        
        if(UUIDInfo["Ambient temperature active"] == "1" || UUIDInfo["IR temperature active"] == "1"){
            
            var sUUID = CBUUID(string: UUIDInfo["IR temperature service UUID"]);
            var cUUID = CBUUID(string: UUIDInfo["IR temperature config UUID"]);
            var dUUID = CBUUID(string: UUIDInfo["IR temperature data UUID"]);
            
            var dataInt = NSInteger(1) //(1-100)
            var data = NSData(bytes: &dataInt, length: 1)
            BLEUtilitySwift.writeCharacteristic(peripheral, sUUID: sUUID, cUUID: cUUID, data: data)
            
            BLEUtilitySwift.setNotificationForCharacteristic(peripheral, sUUID: sUUID, cUUID: dUUID, enable: true)
            
            println("IR temperature service Configured")
        }
        
        if(UUIDInfo["Accelerometer active"] == "1"){
            
            var sUUID = CBUUID(string: UUIDInfo["Accelerometer service UUID"]);
            var dUUID = CBUUID(string: UUIDInfo["Accelerometer data UUID"]);
            var cUUID = CBUUID(string: UUIDInfo["Accelerometer config UUID"]);
            var pUUID = CBUUID(string: UUIDInfo["Accelerometer period UUID"]);
            
            var random = NSInteger(50) //(1-100) // Change to the data from UUIDINFO
            var data = NSData(bytes: &random, length: 1)
            BLEUtilitySwift.writeCharacteristic(peripheral, sUUID: sUUID, cUUID: pUUID, data: data)
            
            random = NSInteger(1)
            data = NSData(bytes: &random, length: 1)
            BLEUtilitySwift.writeCharacteristic(peripheral, sUUID: sUUID, cUUID: cUUID, data: data)
            BLEUtilitySwift.setNotificationForCharacteristic(peripheral, sUUID: sUUID, cUUID: dUUID, enable: true)
            
            println("Accelerometer service Configured")
            
        }
        
        if(UUIDInfo["Humidity active"] == "1"){
            var sUUID = CBUUID(string: UUIDInfo["Humidity service UUID"]);
            var dUUID = CBUUID(string: UUIDInfo["Humidity data UUID"]);
            var cUUID = CBUUID(string: UUIDInfo["Humidity config UUID"]);
            
            var dataInt = NSInteger(1) //(1-100)
            var data = NSData(bytes: &dataInt, length: 1)
            BLEUtilitySwift.writeCharacteristic(peripheral, sUUID: sUUID, cUUID: cUUID, data: data)
            BLEUtilitySwift.setNotificationForCharacteristic(peripheral, sUUID: sUUID, cUUID: dUUID, enable: true)
            
            println("Humidity service Configured")
            
        }
        
        if(UUIDInfo["Barometer active"] == "1"){
            var sUUID = CBUUID(string: UUIDInfo["Barometer service UUID"]);
            var dUUID = CBUUID(string: UUIDInfo["Barometer data UUID"]);
            var cUUID = CBUUID(string: UUIDInfo["Barometer config UUID"]);
            var calibrateUUID = CBUUID(string: UUIDInfo["Barometer calibration UUID"]);
            
            var dataInt = NSInteger(2) //(1-100)
            var data = NSData(bytes: &dataInt, length: 1)
            
            BLEUtilitySwift.writeCharacteristic(peripheral, sUUID: sUUID, cUUID: cUUID, data: data)
            BLEUtilitySwift.setNotificationForCharacteristic(peripheral, sUUID: sUUID, cUUID: dUUID, enable: true)
            
            //Don't know what is happening here but is needed
            BLEUtilitySwift.readCharacteristic(peripheral, sUUID: sUUID, cUUID: calibrateUUID)
            
            println("Barometer service Configured")
        }
        
        
        if(UUIDInfo["Gyroscope active"] == "1"){
            var sUUID = CBUUID(string: UUIDInfo["Gyroscope service UUID"]);
            var dUUID = CBUUID(string: UUIDInfo["Gyroscope data UUID"]);
            var cUUID = CBUUID(string: UUIDInfo["Gyroscope config UUID"]);
            
            var dataInt = NSInteger(1) //(1-100)
            var data = NSData(bytes: &dataInt, length: 1)
            BLEUtilitySwift.writeCharacteristic(peripheral, sUUID: sUUID, cUUID: cUUID, data: data)
            BLEUtilitySwift.setNotificationForCharacteristic(peripheral, sUUID: sUUID, cUUID: dUUID, enable: true)
            
            println("Gyroscope service Configured")
        }
        
        if(UUIDInfo["Magnetometer active"] == "1"){
            
            var sUUID = CBUUID(string: UUIDInfo["Magnetometer service UUID"]);
            var dUUID = CBUUID(string: UUIDInfo["Magnetometer data UUID"]);
            var cUUID = CBUUID(string: UUIDInfo["Magnetometer config UUID"]);
            var pUUID = CBUUID(string: UUIDInfo["Magnetometer period UUID"]);
            
            var random = NSInteger(50) //(1-100) // Change to the data from UUIDINFO
            var data = NSData(bytes: &random, length: 1)
            BLEUtilitySwift.writeCharacteristic(peripheral, sUUID: sUUID, cUUID: pUUID, data: data)
            
            random = NSInteger(1)
            data = NSData(bytes: &random, length: 1)
            BLEUtilitySwift.writeCharacteristic(peripheral, sUUID: sUUID, cUUID: cUUID, data: data)
            BLEUtilitySwift.setNotificationForCharacteristic(peripheral, sUUID: sUUID, cUUID: dUUID, enable: true)
            
            println("Magnetometer service Configured")
            
        }
        
        if(UUIDInfo["Button active"] == "1"){
            
            var sUUID = CBUUID(string: UUIDInfo["Button service UUID"]);
            var dUUID = CBUUID(string: UUIDInfo["Button data UUID"]);
            
            BLEUtilitySwift.setNotificationForCharacteristic(peripheral, sUUID: sUUID, cUUID: dUUID, enable: true)
            
            println("Button service Configured")
        }
    }
    
    class func deconfigure(peripheral: CBPeripheral, UUIDInfo:[String:String]){
        
        if(UUIDInfo["Ambient temperature active"] == "1" || UUIDInfo["IR temperature active"] == "1"){
            
            var sUUID = CBUUID(string: UUIDInfo["IR temperature service UUID"]);
            var cUUID = CBUUID(string: UUIDInfo["IR temperature config UUID"]);
            var dUUID = CBUUID(string: UUIDInfo["IR temperature data UUID"]);
            
            var dataInt = NSInteger(0) //(1-100)
            var data = NSData(bytes: &dataInt, length: 1)
            BLEUtilitySwift.writeCharacteristic(peripheral, sUUID: sUUID, cUUID: cUUID, data: data)
            
            BLEUtilitySwift.setNotificationForCharacteristic(peripheral, sUUID: sUUID, cUUID: dUUID, enable: true)
        }
        
        if(UUIDInfo["Accelerometer active"] == "1"){
            
            var sUUID = CBUUID(string: UUIDInfo["Accelerometer service UUID"]);
            var dUUID = CBUUID(string: UUIDInfo["Accelerometer data UUID"]);
            var cUUID = CBUUID(string: UUIDInfo["Accelerometer config UUID"]);
            
            var dataInt = NSInteger(0) //(1-100)
            var data = NSData(bytes: &dataInt, length: 1)
            BLEUtilitySwift.writeCharacteristic(peripheral, sUUID: sUUID, cUUID: cUUID, data: data)
            
            BLEUtilitySwift.setNotificationForCharacteristic(peripheral, sUUID: sUUID, cUUID: dUUID, enable: false)
            
        }
        
        if(UUIDInfo["Humidity active"] == "1"){
            var sUUID = CBUUID(string: UUIDInfo["Humidity service UUID"]);
            var dUUID = CBUUID(string: UUIDInfo["Humidity data UUID"]);
            var cUUID = CBUUID(string: UUIDInfo["Humidity config UUID"]);
            
            var dataInt = NSInteger(0) //(1-100)
            var data = NSData(bytes: &dataInt, length: 1)
            BLEUtilitySwift.writeCharacteristic(peripheral, sUUID: sUUID, cUUID: cUUID, data: data)
            
            BLEUtilitySwift.setNotificationForCharacteristic(peripheral, sUUID: sUUID, cUUID: dUUID, enable: false)
        }
        
        if(UUIDInfo["Barometer active"] == "1"){
            var sUUID = CBUUID(string: UUIDInfo["Barometer service UUID"]);
            var dUUID = CBUUID(string: UUIDInfo["Barometer data UUID"]);
            var cUUID = CBUUID(string: UUIDInfo["Barometer config UUID"]);
            
            var dataInt = NSInteger(0) //(1-100)
            var data = NSData(bytes: &dataInt, length: 1)
            BLEUtilitySwift.writeCharacteristic(peripheral, sUUID: sUUID, cUUID: cUUID, data: data)
            
            BLEUtilitySwift.setNotificationForCharacteristic(peripheral, sUUID: sUUID, cUUID: dUUID, enable: false)
            
        }
        
        
        if(UUIDInfo["Gyroscope active"] == "1"){
            var sUUID = CBUUID(string: UUIDInfo["Gyroscope service UUID"]);
            var dUUID = CBUUID(string: UUIDInfo["Gyroscope data UUID"]);
            var cUUID = CBUUID(string: UUIDInfo["Gyroscope config UUID"]);
            
            var dataInt = NSInteger(0) //(1-100)
            var data = NSData(bytes: &dataInt, length: 1)
            BLEUtilitySwift.writeCharacteristic(peripheral, sUUID: sUUID, cUUID: cUUID, data: data)
            
            BLEUtilitySwift.setNotificationForCharacteristic(peripheral, sUUID: sUUID, cUUID: dUUID, enable: false)
        }
        
        if(UUIDInfo["Magnetometer active"] == "1"){
            
            var sUUID = CBUUID(string: UUIDInfo["Magnetometer service UUID"]);
            var dUUID = CBUUID(string: UUIDInfo["Magnetometer data UUID"]);
            var cUUID = CBUUID(string: UUIDInfo["Magnetometer config UUID"]);
            
            var dataInt = NSInteger(0) //(1-100)
            var data = NSData(bytes: &dataInt, length: 1)
            BLEUtilitySwift.writeCharacteristic(peripheral, sUUID: sUUID, cUUID: cUUID, data: data)
            
            BLEUtilitySwift.setNotificationForCharacteristic(peripheral, sUUID: sUUID, cUUID: dUUID, enable: false)
        }
        
        if(UUIDInfo["Button active"] == "1"){
            
            var sUUID = CBUUID(string: UUIDInfo["Button service UUID"]);
            var dUUID = CBUUID(string: UUIDInfo["Button data UUID"]);
            
            BLEUtilitySwift.setNotificationForCharacteristic(peripheral, sUUID: sUUID, cUUID: dUUID, enable: false)
        }
    }

    class func makeSensorTagConfigurationFile(temperatureSensor: Bool, AccelerometerSensor: Bool, HumiditySensor: Bool,MagnetometerSensor: Bool,BarometerSensor: Bool,GyroscopeSensor: Bool,Buttons: Bool) -> [String : String]{
        var UUIDinfo = [String : String]()
        
        var string = temperatureSensor ? "1":"0"
        println("Is this working: \(string)")
        
        // First we set ambient temperature
        UUIDinfo["Ambient temperature active"] = temperatureSensor ? "1":"0";
        // Then we set IR temperature
        UUIDinfo["IR temperature active"] = temperatureSensor ? "1":"0";
        // Append the UUID to make it easy for app
        UUIDinfo["IR temperature service UUID"] = "F000AA00-0451-4000-B000-000000000000";
        UUIDinfo["IR temperature data UUID"] = "F000AA01-0451-4000-B000-000000000000";
        UUIDinfo["IR temperature config UUID"] = "F000AA02-0451-4000-B000-000000000000";
        
        // Then we setup the accelerometer
        UUIDinfo["Accelerometer active"] = AccelerometerSensor ? "1":"0";
        UUIDinfo["Accelerometer period"] = "500";
        UUIDinfo["Accelerometer service UUID"] = "F000AA10-0451-4000-B000-000000000000";
        UUIDinfo["Accelerometer data UUID"] = "F000AA11-0451-4000-B000-000000000000";
        UUIDinfo["Accelerometer config UUID"] = "F000AA12-0451-4000-B000-000000000000";
        UUIDinfo["Accelerometer period UUID"] = "F000AA13-0451-4000-B000-000000000000";
        
        //Then we setup the rH sensor
        UUIDinfo["Humidity active"] = HumiditySensor ? "1":"0";
        UUIDinfo["Humidity service UUID"] = "F000AA20-0451-4000-B000-000000000000";
        UUIDinfo["Humidity data UUID"] = "F000AA21-0451-4000-B000-000000000000";
        UUIDinfo["Humidity config UUID"] = "F000AA22-0451-4000-B000-000000000000";
        
        //Then we setup the magnetometer
        UUIDinfo["Magnetometer active"] = MagnetometerSensor ? "1":"0";
        UUIDinfo["Magnetometer period"] = "500";
        UUIDinfo["Magnetometer service UUID"] = "F000AA30-0451-4000-B000-000000000000";
        UUIDinfo["Magnetometer data UUID"] = "F000AA31-0451-4000-B000-000000000000";
        UUIDinfo["Magnetometer config UUID"] = "F000AA32-0451-4000-B000-000000000000";
        UUIDinfo["Magnetometer period UUID"] = "F000AA33-0451-4000-B000-000000000000";
        
        //Then we setup the barometric sensor
        UUIDinfo["Barometer active"] = BarometerSensor ? "1":"0";
        UUIDinfo["Barometer service UUID"] = "F000AA40-0451-4000-B000-000000000000";
        UUIDinfo["Barometer data UUID"] = "F000AA41-0451-4000-B000-000000000000";
        UUIDinfo["Barometer config UUID"] = "F000AA42-0451-4000-B000-000000000000";
        UUIDinfo["Barometer calibration UUID"] = "F000AA43-0451-4000-B000-000000000000";
        
        //Then we setup the Gyroscope sensor
        UUIDinfo["Gyroscope active"] = GyroscopeSensor ? "1":"0";
        UUIDinfo["Gyroscope service UUID"] = "F000AA50-0451-4000-B000-000000000000";
        UUIDinfo["Gyroscope data UUID"] = "F000AA51-0451-4000-B000-000000000000";
        UUIDinfo["Gyroscope config UUID"] = "F000AA52-0451-4000-B000-000000000000";
        
        //Last we setup the button service
        UUIDinfo["Button active"] = Buttons ? "1":"0";
        UUIDinfo["Button service UUID"] = "FFE0";
        UUIDinfo["Button data UUID"] = "FFE1";
        
        
        //println("UUIDinfo is set \(UUIDinfo)")
        
        return UUIDinfo;
    }

    
    func serviceLookup(sUUID: CBService, UUIDInfo:[String:String]) -> String{
        
        if(sUUID.UUID.isEqual(CBUUID(string: UUIDInfo["IR temperature service UUID"]))){
            return "IR temperature service";
        }
        
        if(sUUID.UUID.isEqual(CBUUID(string: UUIDInfo["Accelerometer service UUID"]))){
            return "Accelerometer service UUID";
        }
        
        if(sUUID.UUID.isEqual(CBUUID(string: UUIDInfo["Humidity service UUID"]))){
            return "Humidity service UUID";
        }
        
        if(sUUID.UUID.isEqual(CBUUID(string: UUIDInfo["Magnetometer service UUID"]))){
            return "Magnetometer service UUID";
        }
        
        if(sUUID.UUID.isEqual(CBUUID(string: UUIDInfo["Barometer service UUID"]))){
            return "Barometer service UUID";
        }
        
        if(sUUID.UUID.isEqual(CBUUID(string: UUIDInfo["Gyroscope service UUID"]))){
            return "Gyroscope service UUID";
        }
        if(sUUID.UUID.isEqual(CBUUID(string: UUIDInfo["Button service UUID"]))){
            return "Button service UUID";
        }
        return "Service not found"
    }

    
    

}