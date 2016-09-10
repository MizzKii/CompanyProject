//
//  CoreData.swift
//  Company
//
//  Created by Panudech Chuangnuktum on 5/5/2559 BE.
//  Copyright © 2559 MizzKii. All rights reserved.
//

import Foundation
import CoreData
import Cocoa

class CoreDataManager {
    
    private static let instance = CoreDataManager()
    private var managedContext: NSManagedObjectContext?
    private var coordinator: NSPersistentStoreCoordinator?
    
    private init() {
        loadContext()
    }
    
    private func loadContext() {
        print("Getting Context & Coordinator")
        let appDelegate = NSApplication.sharedApplication().delegate as! AppDelegate
        self.managedContext = appDelegate.managedObjectContext
        self.coordinator = appDelegate.persistentStoreCoordinator
    }
    
    internal static func getInstance()->CoreDataManager {
        return instance
    }
    
    internal func getUserId() -> Int {
        return 0
    }
    
    private func getObject(entity:String, key:String, value:String) -> NSManagedObject? {
        print("Get entity '\(entity)'")
        let fetchRequest = NSFetchRequest(entityName: entity)
        do {
            let results = try managedContext!.executeFetchRequest(fetchRequest)
            print("Get \(results.count) record")
            if results.count > 0 {
                for result in results as! [NSManagedObject] {
                    if result.valueForKey(key) as! String == value {
                        return result
                    }
                }
            }
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        return nil
    }
    
    private func getObjects(entity:String, key:String, value:String) -> [NSManagedObject]? {
        print("Get entity '\(entity)'")
        let fetchRequest = NSFetchRequest(entityName: entity)
        var res = [NSManagedObject]()
        do {
            let results = try managedContext!.executeFetchRequest(fetchRequest)
            print("Get \(results.count) record")
            if results.count > 0 {
                for result in results as! [NSManagedObject] {
                    if String(result.valueForKey(key)!) == value {
                        res.append(result)
                    }
                }
                return res
            }
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        return nil
    }
    
    private func deleteAll(entityName:String) {
        print("Truncate \(entityName)")
        let request = NSFetchRequest(entityName: entityName)
        do {
            let list = try self.managedContext!.executeFetchRequest(request)
            for ob: AnyObject in list
            {
                managedContext!.deleteObject(ob as! NSManagedObject)
            }
            try self.managedContext!.save()
        } catch let error as NSError {
            print("Could not delete all \(error), \(error.userInfo)")
        }
    }
    
    internal func getSetting()->NSManagedObject? {
        print("Get entity 'Setting'")
        let fetchRequest = NSFetchRequest(entityName: "Setting")
        do {
            let results = try managedContext!.executeFetchRequest(fetchRequest)
            print("Get \(results.count) record")
            if results.count > 0 {
                return results[0] as? NSManagedObject
            }
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        return nil
    }
    
    internal func setSetting(ip:String, path:String, port:String) {
        print("Truncate")
        deleteAllSetting()
        print("Get entity 'Setting'")
        let entity =  NSEntityDescription.entityForName("Setting",
            inManagedObjectContext:managedContext!)
        
        let setting = NSManagedObject(entity: entity!,
            insertIntoManagedObjectContext: managedContext)
        
        print("Set values")
        setting.setValue(ip, forKey: "ip")
        setting.setValue(path, forKey: "path")
        setting.setValue(port, forKey: "port")
        
        print("Save")
        do {
            try self.managedContext!.save()
            print("Success")
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
    private func deleteAllSetting() {
        deleteAll("Setting")
    }
    
    internal func getProduct(name:String) -> NSManagedObject? {
        return getObject("Product", key: "name", value: name)
//        print("Get entity 'Product'")
//        let fetchRequest = NSFetchRequest(entityName: "Product")
//        do {
//            let results = try managedContext!.executeFetchRequest(fetchRequest)
//            print("Get \(results.count) record")
//            if results.count > 0 {
//                for result in results as! [NSManagedObject] {
//                    if result.valueForKey("name") as! String == name {
//                        return result
//                    }
//                }
//            }
//        } catch let error as NSError {
//            print("Could not fetch \(error), \(error.userInfo)")
//        }
//        return nil
    }
    
    internal func setProducts(id:String, name:String, price:String, detail:String?) {
        let entity =  NSEntityDescription.entityForName("Product",
                                                        inManagedObjectContext:managedContext!)
        
        let product = NSManagedObject(entity: entity!,
                                      insertIntoManagedObjectContext: managedContext)
        
        product.setValue(Int(id), forKey: "id")
        product.setValue(name, forKey: "name")
        product.setValue(Double(price), forKey: "price")
        product.setValue(detail, forKey: "detail")
        
        do {
            try self.managedContext!.save()
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
    internal func deleteAllProduct() {
        deleteAll("Product")
    }
    
    internal func getLotGroup(name:String) -> NSManagedObject? {
        return getObject("LotGroup", key: "name", value: name)
    }
    
    internal func setLotGroup(id:String, name:String) {
        let entity =  NSEntityDescription.entityForName("LotGroup",
                                                        inManagedObjectContext:managedContext!)
        
        let product = NSManagedObject(entity: entity!,
                                      insertIntoManagedObjectContext: managedContext)
        
        product.setValue(Int(id), forKey: "id")
        product.setValue(name, forKey: "name")
        
        do {
            try self.managedContext!.save()
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
    internal func deleteAllLotGroup() {
        deleteAll("LotGroup")
    }
    
    internal func getLotProducts(groupId:String) -> [NSManagedObject]? {
        return getObjects("LotProduct", key: "groupId", value: groupId)
    }
    
    internal func setLotProduct(id:Int, productId:Int, groupId:Int, summary:Int, balance:Int, importDate:NSDate, expireDate:NSDate, productName:String, detail:String) {
        let entity =  NSEntityDescription.entityForName("LotProduct", inManagedObjectContext:managedContext!)
        let product = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
        
        product.setValue(id, forKey: "id")
        product.setValue(productId, forKey: "productId")
        product.setValue(groupId, forKey: "groupId")
        product.setValue(summary, forKey: "summary")
        product.setValue(balance, forKey: "balance")
        product.setValue(importDate, forKey: "importDate")
        product.setValue(expireDate, forKey: "expireDate")
        product.setValue(productName, forKey: "productName")
        product.setValue(detail, forKey: "detail")
        
        do {
            try self.managedContext!.save()
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
    internal func deleteAllLotProduct() {
        deleteAll("LotProduct")
    }
}