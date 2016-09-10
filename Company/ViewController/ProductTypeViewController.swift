//
//  ProductTypeViewController.swift
//  Company
//
//  Created by Panudech Chuangnuktum on 4/11/2559 BE.
//  Copyright © 2559 MizzKii. All rights reserved.
//

import Foundation
import Cocoa
import Alamofire

class ProductTypeViewController: NSViewController {
    
    private final let NEW = "new"
    private final let SUCCESS = "success"
    
    @IBOutlet weak var productName: NSPopUpButton!
    @IBOutlet weak var pCode: NSTextField!
    @IBOutlet weak var pName: NSTextField!
    @IBOutlet weak var pPrice: NSTextField!
    @IBOutlet weak var pDetail: NSTextField!
    @IBOutlet weak var btnSave: NSButton!
    @IBOutlet weak var tfStatus: NSTextField!
    
    @IBAction func onChangeProduct(sender: NSPopUpButton) {
        let selected:String? = sender.selectedItem?.title
        if selected == NEW {
            setTextField("", name: "", price: "", detail: "")
        } else if selected != "" || selected != nil {
            let ob = CoreDataManager.getInstance().getProduct(sender.selectedItem!.title)
            print(ob)
            if ob != nil {
                setTextField(
                    String(ob!.valueForKey("id") as! Int),
                    name: ob!.valueForKey("name") as! String,
                    price: String(format: "%.2f", ob!.valueForKey("price") as! Double),
                    detail: ob?.valueForKey("detail") == nil ? "" : ob?.valueForKey("detail") as! String
                )
            }
        }
    }
    
    @IBAction func onClickCancel(sender: AnyObject) {
        dismissViewController(self)
    }
    
    @IBAction func onClickSave(sender: NSButton) {
        let selected:String? = productName.selectedItem?.title
        let code:String = pCode.stringValue.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        if selected == NEW {
            insert()
        } else if (selected != "" || selected != nil) && code != "" {
            update(code)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setEnabled(false)
        loadProducts()
    }
    
    func loadProducts() {
        loadProducts { () in
            
        }
    }
    
    func loadProducts(handle: () -> Void) {
        self.setEnabled(false)
        ProductModel.getInstance().loadProducts({ (json) in
            self.productName.addItemWithTitle(json["name"] as! String)
            }, success: { (value) in
                self.setEnabled(true)
                handle()
            }, failure: { (error) in
                self.setEnabled(true)
                self.fail(error)
        })
    }
    
    func setTextField(code:String, name:String, price:String, detail:String) {
        pCode.stringValue = code
        pName.stringValue = name
        pPrice.stringValue = price
        pDetail.stringValue = detail
    }
    
    func insert() {
        setEnabled(false)
        let detail = pDetail.stringValue;
        print("detail: \(detail)")
        let url = JsonManager.getInstance().getURL() + Property.getInstance().ADD_PRODUCT
        Alamofire.request(.GET, url as String, parameters: [
            "name":pName.stringValue,
            "price":pPrice.stringValue,
            "detail":pDetail.stringValue,
            "user":0])
            .responseJSON { response in
                self.setEnabled(true)
                print(response.result.value)
                if response.result.isSuccess {
                    var status:String = "fail"
                    if let JSON = response.result.value as? [String: AnyObject] {
                        status = JSON["status"] as! String
                    }
                    self.saveStatus(status)
                } else {
                    self.fail(response.result.error!)
                }
        }
    }
    
    func update(code:String) {
        let url = JsonManager.getInstance().getURL() + Property.getInstance().EDIT_PRODUCT
        Alamofire.request(.GET, url as String, parameters: [
            "code":pCode.stringValue,
            "name":pName.stringValue,
            "price":pPrice.stringValue,
            "detail":pDetail.stringValue,
            "user":0])
            .responseJSON { response in
                self.setEnabled(true)
                if response.result.isSuccess {
                    var status:String = "fail"
                    if let JSON = response.result.value as? [String: AnyObject] {
                        status = JSON["status"] as! String
                    }
                    self.saveStatus(status)
                } else {
                    self.fail(response.result.error!)
                }
        }
    }
    
    func saveStatus(status:String) {
        if status == self.SUCCESS {
            self.loadProducts { () in
                self.productName.selectItemWithTitle(self.pName.stringValue)
                self.onChangeProduct(self.productName)
                self.setStatus(Status.save)
            }
        } else {
            self.setStatus(Status.unsave)
        }
    }
    
    func fail(error:NSError)  {
        print("ERROR: \(error)")
        setStatus(Status.fail)
    }
    
    func setEnabled(isEnable:Bool) {
        setStatus(isEnable ? Status.ready : Status.load)
        productName.enabled = isEnable
//        pCode.enabled = isEnable
        pName.enabled = isEnable
        pPrice.enabled = isEnable
        pDetail.enabled = isEnable
        btnSave.enabled = isEnable
    }
    
    func setStatus(status:Status) {
        tfStatus.stringValue = status.rawValue
    }
}