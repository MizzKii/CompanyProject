//
//  ViewController.swift
//  Company
//
//  Created by Panudech Chuangnuktum on 4/30/2559 BE.
//  Copyright © 2559 MizzKii. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    // valiable setting
    @IBOutlet weak var tfIp: NSTextField!
    @IBOutlet weak var tfPath: NSTextField!
    @IBOutlet weak var cbPort: NSComboBox!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        loadSetting()
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func loadSetting() {
        print("===== Start Load Setting =====")
        let ob = CoreDataManager.getInstance().getSetting()
        print("===== Get Setting =====")
        if ob != nil {
            let ip = ob!.valueForKey("ip")
            let path = ob!.valueForKey("path")
            let port = ob!.valueForKey("port")
            print("ip: \(ip as! String)\npath: \(path as! String)\nport: \(port as! String)")
            tfIp.stringValue = ip as! String
            tfPath.stringValue = path as! String
            cbPort.stringValue = port as! String
        }
        print("===== End Load Setting =====")
    }

    @IBAction func saveSetting(sender: NSButton) {
        CoreDataManager.getInstance().setSetting(tfIp.stringValue, path: tfPath.stringValue, port: cbPort.stringValue)
    }

    @IBAction func resetSetting(sender: NSButton) {
        loadSetting()
    }
    
}

