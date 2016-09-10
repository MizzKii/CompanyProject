//
//  SellViewController.swift
//  Company
//
//  Created by Panudech Chuangnuktum on 3/26/2559 BE.
//  Copyright © 2559 MizzKii. All rights reserved.
//

import Foundation
import Cocoa

class SellViewController: NSViewController{
    private var rcProducts:[[String:AnyObject]] = []
    
    @IBOutlet weak var tfProductList: NSTextField!
    @IBOutlet weak var cbProducts: NSComboBox!
    @IBOutlet weak var tfSummary: NSTextField!
    
    override func viewDidLoad() {
        rcProducts = []
        cbProducts.removeAllItems()
        tfSummary.stringValue = "0"
        ReceiptProductController.callback = self.addProduct
    }
    
    @IBAction func onClickSave(sender: NSButton) {
        if rcProducts == [] {
            return
        }
        let userId = CoreDataManager.getInstance().getUserId()
        ReceiptModel.getInstance().insertReceipt(
            ["userId": userId],
            success: { (value) in
                print(value)
                let json = value as! [String: AnyObject]
                print(json)
                let status = json["status"] as! String
                print(status)
                if status == "success" {
                    let receiptId = json["id"] as! Int
                    print(receiptId)
                    for p in self.rcProducts {
                        print(p)
                        ReceiptModel.getInstance().insertReceiptProduct(
                            [
                                "receiptId": receiptId,
                                "productId": p["id"] as! Int,
                                "count": p["count"] as! Int,
                                "summary": p["summary"] as! Int,
                                "userId": userId
                            ],
                            success: { (value) in
                                
                            }, failure: { (error) in
                        
                            })
                    }
                    self.dismissViewController(self)
                } else {
                    
                }
            }) { (error) in
                print(error)
            }
    }
    
    @IBAction func onClickCancel(sender: AnyObject) {
        rcProducts = []
        dismissViewController(self)
    }
    @IBAction func onClickRemoveProduct(sender: NSButton) {
        let selected = cbProducts.selectedCell()?.title
        if selected != nil && selected != "" {
            var i = 0
            for product in rcProducts {
                if selected == product["name"] as? String {
                    rcProducts.removeAtIndex(i)
                    updateList()
                    break
                }
                i += 1
            }
        }
    }
    
    internal func addProduct(id:Int, name:String, count:Int, summary:Int) {
        rcProducts.append([
            "id": id,
            "name": name,
            "count": count,
            "summary": summary
            ])
        updateList()
    }
    
    func updateList() {
        var pList = ""
        var sum = 0
        self.cbProducts.removeAllItems()
        for p in rcProducts {
            let name = p["name"] as! String
            let count = String(p["count"] as! Int)
            let summary = String(p["summary"] as! Int)
            sum += p["summary"] as! Int
            pList += name + "  จำนวน: " + count + " รวมทั้งหมด " + summary + " บาท\n"
            self.cbProducts.addItemWithObjectValue(name)
        }
        tfProductList.stringValue = pList
        tfSummary.stringValue = String(sum)
    }
}

class ReceiptProductController: NSViewController {
    
    internal static var callback: ((id:Int, name:String, count:Int, summary:Int) -> Void)?
    
    @IBOutlet weak var cbProduct: NSComboBox!
    @IBOutlet weak var tfCount: NSTextField!
    
    @IBAction func onClickSubmit(sender: NSButton) {
        let selected = cbProduct.selectedCell()!.title as String
        let count = Int(tfCount.stringValue)
        if selected != "" && count != nil && count > 0 {
            let ob = CoreDataManager.getInstance().getProduct(selected)
            if ob != nil && ReceiptProductController.callback != nil {
                let id = ob?.valueForKey("id") as! Int
                let price = ob?.valueForKey("price") as! Double
                let summary = Int(Double(count!) * price)
                ReceiptProductController.callback!(id: id, name: selected, count: count!, summary: summary)
                dismissViewController(self)
            }
        }
    }
    
    @IBAction func onClickCancel(sender: NSButton) {
        dismissViewController(self)
    }
    
    override func viewDidLoad() {
        cbProduct.removeAllItems()
        ProductModel.getInstance().loadProducts({ (json) in
            self.cbProduct.addItemWithObjectValue(json["name"]!)
        }, success: nil) { (error) in
                print(error)
            }
    }
}