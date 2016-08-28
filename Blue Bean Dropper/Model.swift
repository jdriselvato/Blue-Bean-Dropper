//
//  Model.swift
//  Blue Bean Dropper
//
//  Created by John Riselvato on 8/27/16.
//  Copyright © 2016 John Riselvato. All rights reserved.
//

import Foundation
import CoreBluetooth

class Model: NSObject {
    let beanAdvertisedUUID = CBUUID(string: "A495FF10-C5B1-4B44-B512-1370F02D74DE")
    let beanScratchServiceUUID = CBUUID(string: "A495FF20-C5B1-4B44-B512-1370F02D74DE")
    
    override init() { }
}