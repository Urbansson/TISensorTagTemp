//
//  BLEFinder.swift
//  CoreBluetooth
//
//  Created by Theodor Brandt on 2014-12-13.
//  Copyright (c) 2014 Theodor Brandt. All rights reserved.
//

import Foundation
import CoreBluetooth


//Protocol to notify view when stuff happens
@objc protocol BLEFinderDeligate
{
    optional func BLEFinderIsReady()
    
    optional func BLEFinderFoundPeripheral(name:String, UUID: String)
    optional func BLEFinderLostPeripheral(name: String, UUID: String) //depricated
    
    optional func BLEFinderPeripheralConnected() //depricated

    optional func BLEFinderErrorState()
}



class BLEFinder: NSObject, CBCentralManagerDelegate {

    private let centralManager: CBCentralManager?
    private var blueToothReady = false;
    var foundPeripherals = [String:CBPeripheral]();

    
    var deligate:BLEFinderDeligate?

    override init() {
        super.init()
        
        let centralQueue = dispatch_queue_create("se.kodmys.bluethoot", DISPATCH_QUEUE_SERIAL)

        centralManager = CBCentralManager(delegate: self, queue: centralQueue)
    }

    func startScanning(){
        
        println("startScanning()")

        if blueToothReady {
            if let central = centralManager {
                println("Is scanning")
                central.scanForPeripheralsWithServices(nil, options: nil)
            }
        }
    }
    
    func stopScanning(){
        
        println("stopScanning()")
        
        centralManager?.stopScan();

    }
    
    func connectToPeripheral(UUID:String) -> BLEService?{
        
        if let peripheral = foundPeripherals[UUID]{
            //centralManager?.connectPeripheral(peripheral, options: nil);
            
            var service = BLEService(initWithPeripheral: peripheral);
            self.stopScanning()
            
            return service;
        }
        
        return nil;
    }
    
    func centralManager(central: CBCentralManager!, didDiscoverPeripheral peripheral: CBPeripheral!, advertisementData: [NSObject : AnyObject]!, RSSI: NSNumber!) {
        
        if(peripheral.identifier.UUIDString == "B3522F28-AECF-7BAB-82CD-A2E8288BFC3A"){
            //println("This is the correct device")
            foundPeripherals[peripheral.identifier.UUIDString] = peripheral;
            deligate?.BLEFinderFoundPeripheral!(peripheral.name, UUID: peripheral.identifier.UUIDString);
            centralManager?.connectPeripheral(peripheral, options: nil);
        }
    }
    
    
    func centralManager(central: CBCentralManager!, didConnectPeripheral peripheral: CBPeripheral!) {
        println("Is now connected")
        //centralManager?.stopScan();
        //deligate?.BLEFinderPeripheralConnected!()
        
    }
    
    func centralManager(central: CBCentralManager!, didDisconnectPeripheral peripheral: CBPeripheral!, error: NSError!) {
        println("Is now disconnected")
        
        foundPeripherals[peripheral.identifier.UUIDString] = nil;
        deligate?.BLEFinderLostPeripheral!(peripheral.name, UUID: peripheral.identifier.UUIDString);


    }
    
    
    
    //Should add deligates so we can see in view when states changes
    func centralManagerDidUpdateState(central: CBCentralManager!) {
    
        println("checking state")
        blueToothReady = false;
        switch (central.state) {
        case .PoweredOff:
            println("CoreBluetooth BLE hardware is powered off")
            
        case .PoweredOn:
            println("CoreBluetooth BLE hardware is powered on and ready")
            blueToothReady = true;
            deligate?.BLEFinderIsReady!()
            
        case .Resetting:
            println("CoreBluetooth BLE hardware is resetting")
            
        case .Unauthorized:
            println("CoreBluetooth BLE state is unauthorized")
            
        case .Unknown:
            println("CoreBluetooth BLE state is unknown");
            
        case .Unsupported:
            println("CoreBluetooth BLE hardware is unsupported on this platform");
            
        }
    }
}