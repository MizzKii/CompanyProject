//
//  LotViewController.swift
//  Company
//
//  Created by Panudech Chuangnuktum on 4/13/2559 BE.
//  Copyright © 2559 MizzKii. All rights reserved.
//

import Foundation
import Cocoa
import Alamofire

class LotViewController: NSViewController {
    @IBOutlet weak var lotGroup: NSComboBox!
    @IBOutlet weak var lotProduct: NSPopUpButton!
    @IBOutlet weak var allProduct: NSPopUpButton!
    @IBOutlet weak var lotDetail: NSTextField!
    @IBOutlet weak var lotSummary: NSTextField!
    @IBOutlet weak var lotBalance: NSTextField!
    @IBOutlet weak var lotComeIn: NSDatePicker!
    @IBOutlet weak var lotExpire: NSDatePicker!
    @IBOutlet weak var tfStatus: NSTextField!
    
    private let ITEM_ADD = "Add"
    private var groupNow = ""
    
    @IBAction func onChangeLotProduct(sender: NSPopUpButton) {
        let selected:String = sender.selectedItem!.title
        allProduct.enabled = selected == ITEM_ADD
        if selected == ITEM_ADD {
            resetForm()
        } else {
            let groupName = lotGroup.objectValueOfSelectedItem as? String
            if groupName != nil {
                let groupId = getLotGroupId(groupName!)
                if groupId != nil {
                    changeLotProduct(groupId!, productName: selected)
                }
            }
        }
    }
    
    @IBAction func onChangeLotGroup(sender: NSComboBox) {
        let selected:String = sender.objectValueOfSelectedItem as! String
        if selected == groupNow {
            return
        }
        groupNow = selected
        let groupId = getLotGroupId(selected)
        if groupId != nil {
            changeLotProducts(groupId!)
            resetForm()
        }
    }
    
    @IBAction func onClickCancel(sender: AnyObject) {
        dismissViewController(self)
    }
    @IBAction func onClickSave(sender: AnyObject) {
        mageLotGroup { (groupId) in
            self.saveLotProduct(groupId)
        }
    }
    
    override func viewDidLoad() {
        setEnabled(false)
        lotComeIn.dateValue = NSDate()
        lotExpire.dateValue = NSDate()
        ProductModel.getInstance().loadProducts({ (json) in
            self.allProduct.addItemWithTitle(json["name"] as! String)
        }, success: nil) { (error) in
            self.fail(error)
        }
        loadLotGroup()
        loadLotProducts(-1, callback: {
            self.setEnabled(true)
        })
    }
    
    func resetForm() {
        lotDetail.stringValue = ""
        lotSummary.stringValue = ""
        lotBalance.stringValue = ""
        lotComeIn.dateValue = NSDate()
        lotExpire.dateValue = NSDate()
    }
    
    func saveLotProduct(groupId:Int) {
        let selectedProduct = lotProduct.selectedItem!.title
        if selectedProduct == ITEM_ADD {
            insertLotProduct(groupId)
        } else {
            updateLotProduct(groupId)
        }
    }
    
    func changeLotProducts(groupId:Int) {
        allProduct.enabled = true
        lotProduct.removeAllItems()
        lotProduct.addItemWithTitle(ITEM_ADD)
        
        let products = CoreDataManager.getInstance().getLotProducts(String(groupId))
        
        if products != nil {
            for product in products! {
                let name = product.valueForKey("productName")
                if name != nil {
                    lotProduct.addItemWithTitle(name as! String)
                }
            }
        }
    }
    
    func changeLotProduct(groupId:Int, productName:String) {
        let products = CoreDataManager.getInstance().getLotProducts(String(groupId))
        if products != nil {
            for product in products! {
                if product.valueForKey("productName") as! String == productName {
                    lotDetail.stringValue = product.valueForKey("detail") as! String
                    lotSummary.stringValue = String(product.valueForKey("summary")!)
                    lotBalance.stringValue = String(product.valueForKey("balance")!)
                    lotComeIn.dateValue = product.valueForKey("importDate") as! NSDate
                    lotExpire.dateValue = product.valueForKey("expireDate") as! NSDate
                    lotProduct.selectedItem!.title = productName
                    allProduct.enabled = false
                    break
                }
            }
        }
    }
    
    func getLotGroupId(selected:String) -> Int? {
        let group = CoreDataManager.getInstance().getLotGroup(selected)
        return group != nil ? group!.valueForKey("id") as? Int : nil
    }
    
    func loadLotGroup() {
        loadLotGroup {
            
        }
    }
    
    func loadLotGroup(handle:()->Void) {
        let url = JsonManager.getInstance().getURL() + Property.getInstance().GET_LOT_GROUP
        Alamofire.request(.GET, url).responseJSON { (response) in
            print(response.result)
            if response.result.isSuccess {
                CoreDataManager.getInstance().deleteAllLotGroup()
                self.lotGroup.removeAllItems()
                for var json in response.result.value as! [[String: AnyObject]] {
                    CoreDataManager.getInstance().setLotGroup(json["id"] as! String, name: json["name"] as! String)
                    self.lotGroup.addItemWithObjectValue(json["name"]!)
                }
                handle()
            } else {
                self.fail(response.result.error!)
            }
        }
    }
    
    func loadLotProducts() {
        loadLotProducts(-1, callback: {})
    }
    
    func loadLotProducts(groupId:Int, callback:()->Void) {
        lotProduct.removeAllItems()
        lotProduct.addItemWithTitle(ITEM_ADD)
        LotProductModel.getInstance().loadLotProducts(
            { (json) in
                if Int(json["group_id"] as! String) == groupId {
                    self.lotProduct.addItemWithTitle(json["product_name"] as! String)
                }
            }, success: { (result) in
                callback()
            }, failure: { (error) in
                self.fail(error)
        })
    }
    
    func mageLotGroup(callback:(Int) -> Void) {
        if lotGroup.objectValueOfSelectedItem != nil {
            let selected = lotGroup.objectValueOfSelectedItem as! String
            let groupId = getLotGroupId(selected)
            callback(groupId!)
            
        } else {
            let groupName = lotGroup.objectValue as! String
            let url = JsonManager.getInstance().getURL() + Property.getInstance().ADD_LOT_GROUP
            Alamofire.request(.GET, url,parameters: ["name": groupName, "user": 0]).responseJSON(completionHandler: { (response) in
                if response.result.isSuccess {
                    let json = response.result.value as! [String: AnyObject]
                    let status = json["status"] as! String
                    print(status)
                    if status == "success" {
                        self.loadLotGroup {
                            self.lotGroup.selectItemWithObjectValue(groupName)
                            let groupId = self.getLotGroupId(groupName)
                            callback(groupId!)
                        }
                    } else {
                        self.setStatus(Status.unsave)
                    }
                } else {
                    self.fail(response.result.error!)
                }
            })
        }
    }
    
    func insertLotProduct(groupId:Int) {
        var productId = ""
        let productName = allProduct.selectedItem!.title
        let ob = CoreDataManager.getInstance().getProduct(productName)
        if ob != nil {
            productId = String(ob!.valueForKey("id") as! Int)
        } else {
            setStatus(Status.unsave)
            return
        }
        
        let summary = String(lotSummary.intValue)
        let balance = String(lotBalance.intValue)
        
        let comeIn = lotComeIn.dateValue.descriptionWithCalendarFormat("%Y-%m-%d", timeZone: nil, locale: nil)!
        let expire = lotExpire.dateValue.descriptionWithCalendarFormat("%Y-%m-%d", timeZone: nil, locale: nil)!
        
        let userId = String(CoreDataManager.getInstance().getUserId())
        
        LotProductModel.getInstance().insertLotProducts(
            ["group_id":groupId, "product_id":productId, "summary":summary, "balance":balance, "come_in":comeIn, "expire":expire, "detail":lotDetail.stringValue, "user_id":userId],
            success: { (value) in
                self.loadLotProducts(groupId, callback: {
                    self.changeLotProducts(groupId)
                    self.changeLotProduct(groupId, productName: productName)
                })
                if value!["status"] as! String == "success" {
                    self.setStatus(Status.save)
                } else {
                    print(value)
                    self.setStatus(.unsave)
                }
            }, failure: { (error) in
                self.fail(error)
        })
    }
    
    func updateLotProduct(groupId:Int) {
        var lotProductId = ""
        let productName = lotProduct.selectedItem!.title
        let products = CoreDataManager.getInstance().getLotProducts(String(groupId))
        if products != nil {
            for product in products! {
                if product.valueForKey("productName") as! String == productName {
                    lotProductId = String(product.valueForKey("productId")!)
                    break
                }
            }
        }
        if lotProductId == "" {
            setStatus(Status.unsave)
            return
        }
        
        let summary = String(lotSummary.intValue)
        let balance = String(lotBalance.intValue)
        
        let comeIn = lotComeIn.dateValue.descriptionWithCalendarFormat("%Y-%m-%d %H:%M:%S", timeZone: nil, locale: nil)!
        let expire = lotExpire.dateValue.descriptionWithCalendarFormat("%Y-%m-%d %H:%M:%S", timeZone: nil, locale: nil)!
        
        let userId = String(CoreDataManager.getInstance().getUserId())
        
        LotProductModel.getInstance().updateLotProducts(
            ["lot_product_id":lotProductId, "summary":summary, "balance":balance, "come_in":comeIn, "expire":expire, "detail":lotDetail.stringValue, "user_id":userId],
            success: { (value) in
                self.loadLotProducts(groupId, callback: {
                    self.changeLotProducts(groupId)
                    self.changeLotProduct(groupId, productName: productName)
                })
                if value!["status"] as! String == "success" {
                    self.setStatus(Status.save)
                    self.changeLotProducts(groupId)
                    self.changeLotProduct(groupId, productName: productName)
                } else {
                    self.setStatus(Status.unsave)
                }
                print(value)
            }, failure: { (error) in
                self.fail(error)
        })
    }
    
    func fail(error:NSError) {
        print("ERROR: \(error)")
        setStatus(Status.fail)
    }
    
    func setEnabled(isEnable:Bool) {
        setStatus(isEnable ? Status.ready : Status.load)
        lotGroup.enabled = isEnable
        lotProduct.enabled = isEnable
        lotDetail.enabled = isEnable
        lotSummary.enabled = isEnable
        lotBalance.enabled = isEnable
        lotComeIn.enabled = isEnable
        lotExpire.enabled = isEnable
        if isEnable {
            allProduct.enabled = lotProduct.selectedItem!.title == ITEM_ADD
        } else {
            allProduct.enabled = isEnable
        }
    }
    
    func setStatus(status:Status) {
        tfStatus.stringValue = status.rawValue
    }
}