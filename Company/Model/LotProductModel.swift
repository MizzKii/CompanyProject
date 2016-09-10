//
//  LotProductModel.swift
//  Company
//
//  Created by Panudech Chuangnuktum on 7/8/2559 BE.
//  Copyright © 2559 MizzKii. All rights reserved.
//

import Foundation
import Alamofire

public class LotProductModel {
    private static let instance = LotProductModel()
    
    private init () { }
    
    public static func getInstance() -> LotProductModel {
        return instance
    }
    
    public func loadLotProducts(loop: (([String: AnyObject]) -> Void)?, success: ((AnyObject?) -> Void)?, failure: ((NSError) -> Void)?) {
        let url = JsonManager.getInstance().getURL() + Property.getInstance().GET_ALL_LOT_PRODUCT
        print("==== Start Load Product ====")
        Alamofire.request(.GET, url).responseJSON { (response) in
            if response.result.isSuccess {
                let dateformatter = NSDateFormatter()
                dateformatter.dateFormat = "yyyy-MM-dd"
                CoreDataManager.getInstance().deleteAllLotProduct()
                for var json in response.result.value as! [[String: AnyObject]] {
                    let id:Int        = Int(json["id"] as! String)!
                    let productId:Int = Int(json["product_id"] as! String)!
                    let groupId:Int   = Int(json["group_id"] as! String)!
                    let summary:Int   = Int(json["summary"] as! String)!
                    let balance:Int   = Int(json["balance"] as! String)!
                    let importDate:NSDate = dateformatter.dateFromString(json["import_date"] as! String)!
                    let expireDate:NSDate = dateformatter.dateFromString(json["expire_date"] as! String)!
                    let productName:String = json["product_name"] as! String
                    let detail:String = json["detail"] as! String
                    CoreDataManager.getInstance().setLotProduct(
                        id,
                        productId: productId,
                        groupId: groupId,
                        summary: summary,
                        balance: balance,
                        importDate: importDate,
                        expireDate: expireDate,
                        productName: productName,
                        detail: detail
                    )
                    loop? (json)
                }
                print("Loaded \((response.result.value!.count) as Int) record")
                success?(response.result.value)
            } else {
                failure?(response.result.error!)
            }
            print("==== End Loaded Product")
        }
    }
    
    public func insertLotProducts(parameters:[String: AnyObject]?, success: ((AnyObject?) -> Void)?, failure: ((NSError) -> Void)?) {
        let url = JsonManager.getInstance().getURL() + Property.getInstance().ADD_LOT_PRODUCT
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
    
    public func updateLotProducts(parameters:[String: AnyObject]?, success: ((AnyObject?) -> Void)?, failure: ((NSError) -> Void)?) {
        let url = JsonManager.getInstance().getURL() + Property.getInstance().EDIT_LOT_PRODUCT
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

