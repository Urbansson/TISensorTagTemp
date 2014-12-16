//
//  SelectDeviceCell.swift
//  CoreBluetooth
//
//  Created by Theodor Brandt on 2014-12-14.
//  Copyright (c) 2014 Theodor Brandt. All rights reserved.
//

import Foundation
import UIKit

class selectDeviceCell: UITableViewCell {
    
    @IBOutlet var deviceName: UILabel!
    @IBOutlet var deviceInfo: UILabel!
    
    func loadItem(deviceName: String, deviceInfo: String) {
        self.deviceName.text = deviceName
        self.deviceInfo.text = deviceInfo
    }

}