//
//  File.swift
//  Company
//
//  Created by Panudech Chuangnuktum on 6/19/2559 BE.
//  Copyright © 2559 MizzKii. All rights reserved.
//

import Cocoa

class MainController: NSViewController {
    
}

enum Status:String {
    case load = "loading..."
    case ready = "ready"
    case fail = "connect fail"
    case save = "saved"
    case unsave = "not save"
}