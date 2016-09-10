//
//  ProductModel.swift
//  Company
//
//  Created by Panudech Chuangnuktum on 7/6/2559 BE.
//  Copyright © 2559 MizzKii. All rights reserved.
//

import Foundation
import Alamofire

public class ProductModel {
    private static let instance = ProductModel()
    
    private init () { }
    
    public static func getInstance() -> ProductModel {
        return instance
    }
    
    public func loadProducts(loop: (([String: AnyObject]) -> Void)?, success: ((AnyObject?) -> Void)?, failure: ((NSError) -> Void)?) {
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
}

