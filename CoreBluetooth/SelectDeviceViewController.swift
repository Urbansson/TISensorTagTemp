//
//  SelectDeviceViewController.swift
//  CoreBluetooth
//
//  Created by Theodor Brandt on 2014-12-14.
//  Copyright (c) 2014 Theodor Brandt. All rights reserved.
//

import Foundation
import UIKit

class SelectDeviceViewController:UITableViewController, UITableViewDelegate, UITableViewDataSource, BLEFinderDeligate {
    
    var foundDevices = [(String, String)]();
    
    
    var finder:BLEFinder!

    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        var nib = UINib(nibName: "selectDeviceCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: "customCell")
        
        finder = BLEFinder();
        finder.deligate = self;
        self.tableView.beginUpdates()
        self.tableView.endUpdates()


    }
    
    override func viewWillDisappear(animated: Bool) {
        finder.stopScanning()
    }
    
    override func viewWillAppear(animated: Bool) {
        finder.startScanning()
        
    }
    
    func BLEFinderIsReady() {
        finder.startScanning()
    }
    
    func BLEFinderFoundPeripheral(name: String, UUID: String) {
        
        dispatch_async(dispatch_get_main_queue(), {
            self.foundDevices.append(name,UUID)
            self.tableView.reloadData()

        });
    }
    
    func BLEFinderLostPeripheral(name: String, UUID: String) {

        
        dispatch_async(dispatch_get_main_queue(), {
            var i = 0
            for info in self.foundDevices{
                
                if info.1 == UUID{
                    self.foundDevices.removeAtIndex(i);
                    break;
                }
                i++;
            }
            
            self.tableView.reloadData()
        });
    }

    override func tableView(tableView:UITableView, numberOfRowsInSection section:Int) -> Int {
        return foundDevices.count;
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell:selectDeviceCell = self.tableView.dequeueReusableCellWithIdentifier("customCell") as selectDeviceCell
        
        // this is how you extract values from a tuple
        var (name, info) = foundDevices[indexPath.row]
        
        cell.loadItem(name, deviceInfo: info)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        println("Connect to \(self.foundDevices[indexPath.row].1) and stop scanning and move view")
        
        var service = self.finder.connectToPeripheral(self.foundDevices[indexPath.row].1);
        
    
        println("Service is \(service)")

        if service != nil{
            self.performSegueWithIdentifier("showService", sender: service)
        }else{
            println("Could not connect")
        }
    }
    

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        println("Changing")

        if (segue.identifier == "showService") {
            let vc = segue.destinationViewController as ServiceViewController
            vc.service = sender as BLEService
        }
    }
    
    //Just to force the Height of the table cell
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60;
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60;
    }
    
}




/*
    override func viewDidLoad() {
        
        println("Hello")
        
    }
    
    func tableView(tableView:UITableView!, numberOfRowsInSection section:Int) -> Int {
        return 10
    }
    
    func tableView(tableView:UITableView!, cellForRowAtIndexPath indexPath:NSIndexPath!) -> UITableViewCell! {
       
        
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "MyTestCell")
        
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}*/