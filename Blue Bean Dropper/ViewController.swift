//
//  ViewController.swift
//  Blue Bean Dropper
//
//  Created by John Riselvato on 8/27/16.
//  Copyright © 2016 John Riselvato. All rights reserved.
//
// My LightBlue Bean's UUID: 4EFB01DF-AE2D-4EA0-0149-7FBC5AB11F02
// I use Dweet to update values to a fake server
// Watch Dweet: https://dweet.io/get/latest/dweet/for/Blue-Bean-Drop
// Post Dweet: https://dweet.io:443/dweet/for/Blue-Bean-Drop


import UIKit
import CoreBluetooth

class ViewController: UIViewController, CBPeripheralDelegate, CBCentralManagerDelegate {
    var centralManager : CBCentralManager!
    var peripheral : CBPeripheral!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.redColor()
        
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
        centralManager.scanForPeripheralsWithServices(nil, options: nil)
    }
    
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        print("Discovered: \(peripheral.name) at \(RSSI)")
        print("AdvertisementData:\(advertisementData)")
        
        if self.peripheral != peripheral && peripheral.name == "Bean" {
            self.peripheral = peripheral
            self.peripheral.delegate = self
            centralManager.connectPeripheral(peripheral, options: nil)
        }
    }
    
    func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        print("Failed to connect \(peripheral) cause of \(error)")
    }
    
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        print("connected to \(peripheral)")
        
        self.view.backgroundColor = UIColor.greenColor()
        centralManager.stopScan() // stop searching after we connect to the device we want
        print("Available services:\(peripheral.services)")
        peripheral.discoverServices(nil)
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverIncludedServicesForService service: CBService, error: NSError?) {
        print("Services\(service) and error: \(error)")
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        print("Services and error: \(error)")
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
            print("Sending Dweet count: \(stringValue)")
            self.sendCountDweet(stringValue)
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
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

extension NSData {
    var hexString: String? {
        let buf = UnsafePointer<UInt8>(bytes)
        let charA = UInt8(UnicodeScalar("a").value)
        let char0 = UInt8(UnicodeScalar("0").value)
        
        func itoh(value: UInt8) -> UInt8 {
            return (value > 9) ? (charA + value - 10) : (char0 + value)
        }
        
        let ptr = UnsafeMutablePointer<UInt8>.alloc(length * 2)
        
        for i in 0 ..< length {
            ptr[i*2] = itoh((buf[i] >> 4) & 0xF)
            ptr[i*2+1] = itoh(buf[i] & 0xF)
        }
        
        return String(bytesNoCopy: ptr, length: length*2, encoding: NSUTF8StringEncoding, freeWhenDone: true)
    }
}
