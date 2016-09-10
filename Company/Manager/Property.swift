//
//  Variable.swift
//  Company
//
//  Created by Panudech Chuangnuktum on 6/13/2559 BE.
//  Copyright © 2559 MizzKii. All rights reserved.
//

import Foundation

class Property {
    private static let instance = Property()
    internal let GET_ALL_PRODUCT = "getProducts.php"
    internal let ADD_PRODUCT = "setProduct.php"
    internal let EDIT_PRODUCT = "setProductAs.php"
    
    internal let GET_LOT_GROUP = "getLotGroup.php"
    internal let ADD_LOT_GROUP = "setLotGroup.php"
    
    internal let GET_ALL_LOT_PRODUCT = "getLotProducts.php"
    internal let ADD_LOT_PRODUCT = "setLotProduct.php"
    internal let EDIT_LOT_PRODUCT = "setLotProductAs.php"
    
    internal let ADD_RECEIPT = "addReceipt.php"
    internal let ADD_RECEIPT_PRODUCT = "addReceiptProduct.php"
    
    private init() {
        
    }
    
    internal static func getInstance() -> Property {
        return instance
    }
}