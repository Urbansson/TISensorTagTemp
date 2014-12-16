//
//  ViewController.swift
//  CoreBluetooth
//
//  Created by Theodor Brandt on 2014-12-13.
//  Copyright (c) 2014 Theodor Brandt. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController, BLEFinderDeligate, BLEServiceDeligate {

    //This is the class for finding devices
    var finder:BLEFinder!
    
    //This class is for getting data from a devie
    var service:BLEService!

    @IBOutlet var LabelUUID: UILabel!
    @IBOutlet var LabelValue: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        finder = BLEFinder();
        finder.deligate = self;
        
        println("Done setting up")
        println("Starting Thread \(NSThread.currentThread()))")

        SensorTagUtils.makeSensorTagConfigurationFile(
            true, AccelerometerSensor: false, HumiditySensor: false, MagnetometerSensor: false, BarometerSensor: false, GyroscopeSensor: false, Buttons: false)
    }
    
    @IBAction func connect(sender: AnyObject) {
        self.service.startGettingData()

        println("Configureing")
        
    }
    
    @IBAction func diconnect(sender: AnyObject) {
        
        self.service.stopGettingData()

        println("Removing")

    }
    
    func BLEFinderIsReady() {
        finder.startScanning()
    }
    
    
    func BLEFinderFoundPeripheral(name: String, UUID: String) {
        //println("BLEFinderFoundPeripheral \(NSThread.currentThread()))")

        //println("Found \(name) with UUID \(UUID)")
        dispatch_async(dispatch_get_main_queue(), {
            self.LabelUUID.text = UUID
            
        })
        
        
        //should ofcourse not be called in the deligate
        self.service = finder.connectToPeripheral(UUID);
        self.service.deligate = self;
        
    }
    
    func BLEFinderPeripheralConnected() {
        println("Starting to discover \(NSThread.currentThread()))")

        println("Starting to discover")
        self.service.discoverServices()
    }
    
    func BLEServiceIsFound() {
        //self.service.startGettingData()
        println("can now take data")
    }

    
    func BLEServiceIRTemperatureHasData(tAmb: Float, tObj: Float) {
        //println("Current Thread \(NSThread.currentThread()))")
        println("IRTemperatureHasData Thread \(NSThread.currentThread()))")

        
        dispatch_async(dispatch_get_main_queue(), {
            self.LabelValue.text = "Recived data \(tAmb) and \(tObj)"

        })
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

