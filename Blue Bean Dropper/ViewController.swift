//
//  ViewController.swift
//  Blue Bean Dropper
//
//  Created by John Riselvato on 8/27/16.
//  Copyright © 2016 John Riselvato. All rights reserved.
//
// My LightBlue Bean's UUID: 4EFB01DF-AE2D-4EA0-0149-7FBC5AB11F02

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
    
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        print("Discovered: \(peripheral.name) at \(RSSI)")
        print("AdvertisementData:\(advertisementData)")
        
        if self.peripheral != peripheral {
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
        
        if peripheral.name == "Bean" {
            self.view.backgroundColor = UIColor.greenColor()
            centralManager.stopScan() // stop searching after we connect to the device we want
        }

        print("Available services:\(peripheral.services)")
        peripheral.discoverServices(nil)
        
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverIncludedServicesForService service: CBService, error: NSError?) {
        print("Services\(service) and error\(error)")
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        print("Services and error\(error)")
        if let services = peripheral.services {
            for service in services {
                peripheral.discoverCharacteristics(nil, forService: service)
            }
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        print("peripheral:\(peripheral) and service:\(service)")
        for characteristic in service.characteristics!
        {
            peripheral.setNotifyValue(true, forCharacteristic: characteristic)
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        print("characteristic changed:\(characteristic)")
    }
    
    func startScan(){
        print("Scanning...")
        centralManager.scanForPeripheralsWithServices(nil, options: nil)
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

