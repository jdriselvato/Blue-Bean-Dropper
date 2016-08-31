//
//  ViewModel.swift
//  Blue Bean Dropper
//
//  Created by John Riselvato on 8/27/16.
//  Copyright © 2016 John Riselvato. All rights reserved.
//

import Foundation
import CoreBluetooth

class ViewModel: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    var centralManager : CBCentralManager!
    var peripheral : CBPeripheral!

    let model: Model
    
    init(model: Model) {
        self.model = model
        super.init()
        
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func centralManagerDidUpdateState(central: CBCentralManager) {
        switch central.state {
        case .Unknown, .Unsupported, .Unauthorized:
            print("ERROR: \(central.state)")
        case .Resetting:
            print("Resetting")
        case .PoweredOn:
            print("Powered On")
            startScan() // start scan
        case .PoweredOff:
            print("Powered Off")
        }
    }
    
    func startScan(){
        print("Scanning...")
        centralManager.scanForPeripheralsWithServices([
            self.model.beanAdvertisedUUID
            ], options: nil)
        
    }
    
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        print("> Discovered: \(peripheral.name) at \(RSSI) & AdvertisementData:\(advertisementData)")
        
        if self.peripheral != peripheral && peripheral.name == "Bean" {
            self.peripheral = peripheral
            self.peripheral.delegate = self
            centralManager.connectPeripheral(
                peripheral,
                options: [
                    CBConnectPeripheralOptionNotifyOnNotificationKey : true,
                    CBCentralManagerOptionRestoreIdentifierKey: "BlueBeanDropperCentralManagerIdentifier"
                ])
        }
    }
    
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        print("connected to \(peripheral)")
        
        centralManager.stopScan() // stop searching after we connect to the device we want
        peripheral.discoverServices(nil)
        
        self.peripheral(peripheral, didDiscoverServices: nil)
    }
    
    func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        print("Failed to connect \(peripheral) cause of \(error)")
    }
    
    func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        print("didDisconnectPeripheral")
        self.centralManager.connectPeripheral(self.peripheral, options: nil)
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverIncludedServicesForService service: CBService, error: NSError?) {
        print("Services\(service) and error: \(error)")
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        print("Services and error: \(error)")
        print("Available services:\(peripheral.services)")
        if let services = peripheral.services {
            for service in services {
                peripheral.discoverCharacteristics(nil, forService: service)
            }
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        print("peripheral: \(peripheral) \n service: \(service)")
        for characteristic in service.characteristics! {
            if characteristic.UUID == CBUUID(string: "A495FF21-C5B1-4B44-B512-1370F02D74DE") {
                peripheral.setNotifyValue(true, forCharacteristic: characteristic)
            }
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        print("characteristic changed: \(characteristic)")
        
        if let stringValue = characteristic.value!.hexString {
            let trimed = stringValue.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "000000"))
            let result = UInt8(strtoul("\(trimed)", nil, 16))
            print("Sending Dweet count: \(result)")
            self.sendCountDweet("\(result)")
        }
    }
    
    func centralManager(central: CBCentralManager, willRestoreState dict: [String : AnyObject]) {
        if let peripherals:[CBPeripheral] = dict[CBCentralManagerRestoredStatePeripheralsKey] as! [CBPeripheral]! {
            print("CentralManager#willRestoreState \(peripherals)")
            
        }
    }
    
    func sendCountDweet(count: String) {
        let thing = "Blue-Bean-Drop"
        let URL = NSURL(string: "https://dweet.io/dweet/for/\(thing)?drop=\(count)&callback=dweetCallback.callback0")
        
        let task = NSURLSession.sharedSession().dataTaskWithURL(URL!) { (data, response, error) in
            print(NSString(data: data!, encoding: NSUTF8StringEncoding)) // response
        }
        
        task.resume()
    }
}