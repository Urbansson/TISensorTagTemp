//
//  BLEService.swift
//  CoreBluetooth
//
//  Created by Theodor Brandt on 2014-12-13.
//  Copyright (c) 2014 Theodor Brandt. All rights reserved.
//

import Foundation
import CoreBluetooth

//Protocol to notify view when stuff happens
@objc protocol BLEServiceDeligate
{
    //optional func BLEFinderIsReady()
    
    optional func BLEServiceIsFound()

    optional func BLEServiceIsConfigured()
    optional func BLEServiceIsDeconfigured()

    
    optional func BLEServiceIRTemperatureHasData(tAmb:Float, tObj:Float)
    optional func BLEServiceAccelerometerHasData()
    optional func BLEServiceHumidityHasData()

    optional func BLEServiceMagnetometerHasData()
    optional func BLEServiceBarometerHasData()
    optional func BLEServiceGyroscopeHasData()
    optional func BLEServiceButtonHasData()

}

class BLEService: NSObject, CBPeripheralDelegate {


    var peripheral: CBPeripheral!
    var UUIDInfo: [String : String]!
    var deligate:BLEServiceDeligate?

    var configured:Bool = false;
    
    init(initWithPeripheral peripheral: CBPeripheral) {
        super.init()
        
        self.peripheral = peripheral
        self.peripheral?.delegate = self
        
        UUIDInfo = self.makeSensorTagConfigurationFile(
            true, AccelerometerSensor: false, HumiditySensor: false, MagnetometerSensor: false, BarometerSensor: false, GyroscopeSensor: false, Buttons: false)        
    }
    deinit {
        self.reset()
    }
    
    func startGettingData(){
        self.configureSensorTag()
    }
    
    func stopGettingData(){
        self.deconfigureSensorTag()
    }
    
    func discoverServices() {
        println("startDiscoveringServices")
        
        self.peripheral?.discoverServices(nil)
    }
    
    func peripheral(peripheral: CBPeripheral!, didDiscoverServices error: NSError!) {
        
        
        for aService in peripheral.services{
            println("Service UUID: \(self.serviceLookup((aService as CBService) ))")
            peripheral.discoverCharacteristics(nil, forService: aService as CBService)
        }
        
    }
    
    func peripheral(peripheral: CBPeripheral!, didDiscoverCharacteristicsForService service: CBService!, error: NSError!) {

        println("Found Characteristics For Service: \(service.UUID)")

        var result = service.UUID.isEqual(CBUUID(string: self.UUIDInfo["Button service UUID"]))
        println("Comparing \(result)")
        if(result){
            //self.configureSensorTag()
            self.deligate?.BLEServiceIsFound!()
        }
    }
    
    
    
    func peripheral(peripheral: CBPeripheral!, didUpdateValueForCharacteristic characteristic: CBCharacteristic!, error: NSError!) {
        
        println("Getting some data or something from: \(characteristic.UUID)")
        
        if(!self.configured){
            return
        }
        
        if(characteristic.UUID.isEqual(CBUUID(string: self.UUIDInfo["IR temperature data UUID"]))){
            println("IR temperature data UUID")
            
            var tAmb = sensorTMP006.calcTAmb(characteristic.value)
            var tObj = sensorTMP006.calcTObj(characteristic.value)
            
            //println("Ambient Temperature \(tAmb) Target Temperature \(tObj)")
            self.deligate?.BLEServiceIRTemperatureHasData!(tAmb, tObj: tObj)
        }
        if(characteristic.UUID.isEqual(CBUUID(string: self.UUIDInfo["Accelerometer data UUID"]))){
            println("Accelerometer data UUID")
            self.deligate?.BLEServiceAccelerometerHasData!()

        }
        if(characteristic.UUID.isEqual(CBUUID(string: self.UUIDInfo["Humidity data UUID"]))){
            println("Humidity data UUID")
            
            self.deligate?.BLEServiceHumidityHasData!()
        }
        if(characteristic.UUID.isEqual(CBUUID(string: self.UUIDInfo["Magnetometer data UUID"]))){
            println("Magnetometer data UUID")
            
            self.deligate?.BLEServiceMagnetometerHasData!()
        }
        if(characteristic.UUID.isEqual(CBUUID(string: self.UUIDInfo["Barometer calibration UUID"]))){
            println("Barometer calibration data UUID Dont know what to do here")
        }
        if(characteristic.UUID.isEqual(CBUUID(string: self.UUIDInfo["Barometer data UUID"]))){
            println("Barometer data UUID")
            
            self.deligate?.BLEServiceBarometerHasData!()
        }
        if(characteristic.UUID.isEqual(CBUUID(string: self.UUIDInfo["Gyroscope data UUID"]))){
            println("Gyroscope data UUID")
            
            self.deligate?.BLEServiceGyroscopeHasData!()
        }
        if(characteristic.UUID.isEqual(CBUUID(string: self.UUIDInfo["Button data UUID"]))){
            println("Button data UUID")
            
            self.deligate?.BLEServiceButtonHasData!()
        }
        
        
        //println("Data: \(characteristic.value)")
        /*
        
        optional func IRTemperatureHasData()
        optional func AccelerometerHasData()
        optional func MagnetometerHasData()
        optional func BarometerHasData()
        optional func GyroscopeHasData()
        optional func ButtonHasData()
        
        
        var x = sensorKXTJ9.calcXValue(characteristic.value)
        var y = sensorKXTJ9.calcXValue(characteristic.value)
        var z = sensorKXTJ9.calcXValue(characteristic.value)
        println("Data X: \(x) Y: \(y) Z: \(z)")
        */
    }
    
    func configureSensorTag(){
        
        
        if(self.UUIDInfo["Ambient temperature active"] == "1" || self.UUIDInfo["IR temperature active"] == "1"){
            
            var sUUID = CBUUID(string: self.UUIDInfo["IR temperature service UUID"]);
            var cUUID = CBUUID(string: self.UUIDInfo["IR temperature config UUID"]);
            var dUUID = CBUUID(string: self.UUIDInfo["IR temperature data UUID"]);
            
            var dataInt = NSInteger(1) //(1-100)
            var data = NSData(bytes: &dataInt, length: 1)
            BLEUtilitySwift.writeCharacteristic(self.peripheral, sUUID: sUUID, cUUID: cUUID, data: data)
            
            BLEUtilitySwift.setNotificationForCharacteristic(self.peripheral, sUUID: sUUID, cUUID: dUUID, enable: true)
            
            println("IR temperature service Configured")
        }
        
        if(self.UUIDInfo["Accelerometer active"] == "1"){
            
            var sUUID = CBUUID(string: self.UUIDInfo["Accelerometer service UUID"]);
            var dUUID = CBUUID(string: self.UUIDInfo["Accelerometer data UUID"]);
            var cUUID = CBUUID(string: self.UUIDInfo["Accelerometer config UUID"]);
            var pUUID = CBUUID(string: self.UUIDInfo["Accelerometer period UUID"]);
            
            var random = NSInteger(50) //(1-100) // Change to the data from UUIDINFO
            var data = NSData(bytes: &random, length: 1)
            BLEUtilitySwift.writeCharacteristic(self.peripheral, sUUID: sUUID, cUUID: pUUID, data: data)
            
            random = NSInteger(1)
            data = NSData(bytes: &random, length: 1)
            BLEUtilitySwift.writeCharacteristic(self.peripheral, sUUID: sUUID, cUUID: cUUID, data: data)
            BLEUtilitySwift.setNotificationForCharacteristic(self.peripheral, sUUID: sUUID, cUUID: dUUID, enable: true)
            
            println("Accelerometer service Configured")
            
        }
        
        if(self.UUIDInfo["Humidity active"] == "1"){
            var sUUID = CBUUID(string: self.UUIDInfo["Humidity service UUID"]);
            var dUUID = CBUUID(string: self.UUIDInfo["Humidity data UUID"]);
            var cUUID = CBUUID(string: self.UUIDInfo["Humidity config UUID"]);
            
            var dataInt = NSInteger(1) //(1-100)
            var data = NSData(bytes: &dataInt, length: 1)
            BLEUtilitySwift.writeCharacteristic(self.peripheral, sUUID: sUUID, cUUID: cUUID, data: data)
            BLEUtilitySwift.setNotificationForCharacteristic(self.peripheral, sUUID: sUUID, cUUID: dUUID, enable: true)
            
            println("Humidity service Configured")
            
        }
        
        if(self.UUIDInfo["Barometer active"] == "1"){
            var sUUID = CBUUID(string: self.UUIDInfo["Barometer service UUID"]);
            var dUUID = CBUUID(string: self.UUIDInfo["Barometer data UUID"]);
            var cUUID = CBUUID(string: self.UUIDInfo["Barometer config UUID"]);
            var calibrateUUID = CBUUID(string: self.UUIDInfo["Barometer calibration UUID"]);
            
            var dataInt = NSInteger(2) //(1-100)
            var data = NSData(bytes: &dataInt, length: 1)
            
            BLEUtilitySwift.writeCharacteristic(self.peripheral, sUUID: sUUID, cUUID: cUUID, data: data)
            BLEUtilitySwift.setNotificationForCharacteristic(self.peripheral, sUUID: sUUID, cUUID: dUUID, enable: true)
            
            //Don't know what is happening here but is needed
            BLEUtilitySwift.readCharacteristic(self.peripheral, sUUID: sUUID, cUUID: calibrateUUID)
            
            println("Barometer service Configured")
        }
        
        
        if(self.UUIDInfo["Gyroscope active"] == "1"){
            var sUUID = CBUUID(string: self.UUIDInfo["Gyroscope service UUID"]);
            var dUUID = CBUUID(string: self.UUIDInfo["Gyroscope data UUID"]);
            var cUUID = CBUUID(string: self.UUIDInfo["Gyroscope config UUID"]);
            
            var dataInt = NSInteger(1) //(1-100)
            var data = NSData(bytes: &dataInt, length: 1)
            BLEUtilitySwift.writeCharacteristic(self.peripheral, sUUID: sUUID, cUUID: cUUID, data: data)
            BLEUtilitySwift.setNotificationForCharacteristic(self.peripheral, sUUID: sUUID, cUUID: dUUID, enable: true)
            
            println("Gyroscope service Configured")
        }
        
        if(self.UUIDInfo["Magnetometer active"] == "1"){
            
            var sUUID = CBUUID(string: self.UUIDInfo["Magnetometer service UUID"]);
            var dUUID = CBUUID(string: self.UUIDInfo["Magnetometer data UUID"]);
            var cUUID = CBUUID(string: self.UUIDInfo["Magnetometer config UUID"]);
            var pUUID = CBUUID(string: self.UUIDInfo["Magnetometer period UUID"]);
            
            var random = NSInteger(50) //(1-100) // Change to the data from UUIDINFO
            var data = NSData(bytes: &random, length: 1)
            BLEUtilitySwift.writeCharacteristic(self.peripheral, sUUID: sUUID, cUUID: pUUID, data: data)
            
            random = NSInteger(1)
            data = NSData(bytes: &random, length: 1)
            BLEUtilitySwift.writeCharacteristic(self.peripheral, sUUID: sUUID, cUUID: cUUID, data: data)
            BLEUtilitySwift.setNotificationForCharacteristic(self.peripheral, sUUID: sUUID, cUUID: dUUID, enable: true)
            
            println("Magnetometer service Configured")
            
        }
        
        if(self.UUIDInfo["Button active"] == "1"){
            
            var sUUID = CBUUID(string: self.UUIDInfo["Button service UUID"]);
            var dUUID = CBUUID(string: self.UUIDInfo["Button data UUID"]);
            
            BLEUtilitySwift.setNotificationForCharacteristic(self.peripheral, sUUID: sUUID, cUUID: dUUID, enable: true)
            
            println("Button service Configured")
        }
        self.configured = true;
        self.deligate?.BLEServiceIsConfigured?()

        
    }
    
    func deconfigureSensorTag(){
        
        if(self.UUIDInfo["Ambient temperature active"] == "1" || self.UUIDInfo["IR temperature active"] == "1"){
            
            var sUUID = CBUUID(string: self.UUIDInfo["IR temperature service UUID"]);
            var cUUID = CBUUID(string: self.UUIDInfo["IR temperature config UUID"]);
            var dUUID = CBUUID(string: self.UUIDInfo["IR temperature data UUID"]);
            
            var dataInt = NSInteger(0) //(1-100)
            var data = NSData(bytes: &dataInt, length: 1)
            BLEUtilitySwift.writeCharacteristic(self.peripheral, sUUID: sUUID, cUUID: cUUID, data: data)
            
            BLEUtilitySwift.setNotificationForCharacteristic(self.peripheral, sUUID: sUUID, cUUID: dUUID, enable: true)
        }
        
        
        if(self.UUIDInfo["Accelerometer active"] == "1"){
            
            var sUUID = CBUUID(string: self.UUIDInfo["Accelerometer service UUID"]);
            var dUUID = CBUUID(string: self.UUIDInfo["Accelerometer data UUID"]);
            var cUUID = CBUUID(string: self.UUIDInfo["Accelerometer config UUID"]);
            
            var dataInt = NSInteger(0) //(1-100)
            var data = NSData(bytes: &dataInt, length: 1)
            BLEUtilitySwift.writeCharacteristic(self.peripheral, sUUID: sUUID, cUUID: cUUID, data: data)
            
            BLEUtilitySwift.setNotificationForCharacteristic(self.peripheral, sUUID: sUUID, cUUID: dUUID, enable: false)
            
        }
        
        if(self.UUIDInfo["Humidity active"] == "1"){
            var sUUID = CBUUID(string: self.UUIDInfo["Humidity service UUID"]);
            var dUUID = CBUUID(string: self.UUIDInfo["Humidity data UUID"]);
            var cUUID = CBUUID(string: self.UUIDInfo["Humidity config UUID"]);
            
            var dataInt = NSInteger(0) //(1-100)
            var data = NSData(bytes: &dataInt, length: 1)
            BLEUtilitySwift.writeCharacteristic(self.peripheral, sUUID: sUUID, cUUID: cUUID, data: data)
            
            BLEUtilitySwift.setNotificationForCharacteristic(self.peripheral, sUUID: sUUID, cUUID: dUUID, enable: false)
        }
        
        if(self.UUIDInfo["Barometer active"] == "1"){
            var sUUID = CBUUID(string: self.UUIDInfo["Barometer service UUID"]);
            var dUUID = CBUUID(string: self.UUIDInfo["Barometer data UUID"]);
            var cUUID = CBUUID(string: self.UUIDInfo["Barometer config UUID"]);
            
            var dataInt = NSInteger(0) //(1-100)
            var data = NSData(bytes: &dataInt, length: 1)
            BLEUtilitySwift.writeCharacteristic(self.peripheral, sUUID: sUUID, cUUID: cUUID, data: data)
            
            BLEUtilitySwift.setNotificationForCharacteristic(self.peripheral, sUUID: sUUID, cUUID: dUUID, enable: false)
            
        }
        
        
        if(self.UUIDInfo["Gyroscope active"] == "1"){
            var sUUID = CBUUID(string: self.UUIDInfo["Gyroscope service UUID"]);
            var dUUID = CBUUID(string: self.UUIDInfo["Gyroscope data UUID"]);
            var cUUID = CBUUID(string: self.UUIDInfo["Gyroscope config UUID"]);
            
            var dataInt = NSInteger(0) //(1-100)
            var data = NSData(bytes: &dataInt, length: 1)
            BLEUtilitySwift.writeCharacteristic(self.peripheral, sUUID: sUUID, cUUID: cUUID, data: data)
            
            BLEUtilitySwift.setNotificationForCharacteristic(self.peripheral, sUUID: sUUID, cUUID: dUUID, enable: false)
        }
        
        if(self.UUIDInfo["Magnetometer active"] == "1"){
            
            var sUUID = CBUUID(string: self.UUIDInfo["Magnetometer service UUID"]);
            var dUUID = CBUUID(string: self.UUIDInfo["Magnetometer data UUID"]);
            var cUUID = CBUUID(string: self.UUIDInfo["Magnetometer config UUID"]);
            
            var dataInt = NSInteger(0) //(1-100)
            var data = NSData(bytes: &dataInt, length: 1)
            BLEUtilitySwift.writeCharacteristic(self.peripheral, sUUID: sUUID, cUUID: cUUID, data: data)
            
            BLEUtilitySwift.setNotificationForCharacteristic(self.peripheral, sUUID: sUUID, cUUID: dUUID, enable: false)
        }
        
        if(self.UUIDInfo["Button active"] == "1"){
            
            var sUUID = CBUUID(string: self.UUIDInfo["Button service UUID"]);
            var dUUID = CBUUID(string: self.UUIDInfo["Button data UUID"]);
            
            BLEUtilitySwift.setNotificationForCharacteristic(self.peripheral, sUUID: sUUID, cUUID: dUUID, enable: false)
        }
        
        println("EVERYTHING IS DECONFIGURED")
        
        self.configured = false;
        self.deligate?.BLEServiceIsDeconfigured?()

    }


    
    func serviceLookup(sUUID: CBService) -> String{
        
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
    
    private func makeSensorTagConfigurationFile(temperatureSensor: Bool, AccelerometerSensor: Bool, HumiditySensor: Bool,MagnetometerSensor: Bool,BarometerSensor: Bool,GyroscopeSensor: Bool,Buttons: Bool) -> [String : String]{
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
    
    func reset() {
        println("reset")
        
        if peripheral != nil {
            peripheral.delegate = nil
            peripheral = nil
        }
    }
    
}