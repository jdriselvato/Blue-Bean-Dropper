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
// bluetooth-central in plist to sync data in background


import UIKit
import CoreBluetooth

class ViewController: UIViewController {
    let viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.redColor()
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
