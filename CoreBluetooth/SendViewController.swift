//
//  SendViewController.swift
//  CoreBluetooth
//
//  Created by Theodor Brandt on 2014-12-15.
//  Copyright (c) 2014 Theodor Brandt. All rights reserved.
//

import UIKit

class SendViewController: UIViewController {
    
    var filer:Filehandler?
    
    
    @IBOutlet var serverIp: UITextField!
    
    @IBOutlet var serverPort: UITextField!

    
    @IBAction func Send(sender: AnyObject) {
        
        //filer?.changeServer("192.168.1.243", hostPORT: 6667)
        
        var serverAddress = serverIp.text;
        var serverPortInt = 0
        serverPortInt = serverPort.text.toInt()!
        
        filer?.changeServer(serverAddress, hostPORT: UInt32(serverPortInt))
        
        println("Start sending")
        //println("\(filer?.read())")
        filer?.send();
        println("Done sending")
    }
    
    
    @IBAction func hideKeyboard(sender: AnyObject) {
        
        serverIp.resignFirstResponder()
        serverPort.resignFirstResponder();
        
    }
    
    
    
}
