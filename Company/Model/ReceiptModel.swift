//
//  ReceiptModel.swift
//  Company
//
//  Created by Panudech Chuangnuktum on 8/6/2559 BE.
//  Copyright © 2559 MizzKii. All rights reserved.
//

import Foundation
import Alamofire

public class ReceiptModel {
    private static let instance = ReceiptModel()
    
    private init () { }
    
    public static func getInstance() -> ReceiptModel {
        return instance
    }
    
    public func loadReceipt(loop: (([String: AnyObject]) -> Void)?, success: ((AnyObject?) -> Void)?, failure: ((NSError) -> Void)?) {
        let url = JsonManager.getInstance().getURL() + Property.getInstance().GET_ALL_PRODUCT
        print("==== Start Load Product ====")
        Alamofire.request(.GET, url).responseJSON { (response) in
            if response.result.isSuccess {
                CoreDataManager.getInstance().deleteAllProduct()
                for var json in response.result.value as! [[String: AnyObject]] {
                    CoreDataManager.getInstance().setProducts(
                        json["id"] as! String,
                        name: json["name"] as! String,
                        price: json["price"] as! String,
                        detail: json["detail"] as? String
                    )
                    loop?(json)
                }
                print("Loaded \((response.result.value!.count) as Int) record")
                success?(response.result.value)
            } else {
                failure?(response.result.error!)
            }
            print("==== End Loaded Product")
        }
    }
    
    public func insertReceipt(parameters:[String: AnyObject]?, success: ((AnyObject?) -> Void)?, failure: ((NSError) -> Void)?) {
        let url = JsonManager.getInstance().getURL() + Property.getInstance().ADD_RECEIPT
        Alamofire.request(.POST, url, parameters: parameters).responseJSON { (response) in
            if response.result.isSuccess {
                if success != nil {
                    success!(response.result.value)
                }
            } else {
                failure!(response.result.error!)
            }
        }
    }
    
    public func insertReceiptProduct(parameters:[String: AnyObject]?, success: ((AnyObject?) -> Void)?, failure: ((NSError) -> Void)?) {
        let url = JsonManager.getInstance().getURL() + Property.getInstance().ADD_RECEIPT_PRODUCT
        Alamofire.request(.POST, url, parameters: parameters).responseJSON { (response) in
            if response.result.isSuccess {
                if success != nil {
                    success!(response.result.value)
                }
            } else {
                failure!(response.result.error!)
            }
        }
    }
}

