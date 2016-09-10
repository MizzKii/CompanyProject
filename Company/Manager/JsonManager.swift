//
//  JsonReader.swift
//  Company
//
//  Created by Panudech Chuangnuktum on 5/2/2559 BE.
//  Copyright © 2559 MizzKii. All rights reserved.
//

import Foundation
import Cocoa

class JsonResponse: NSViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    internal func onLoaded(json:NSArray?) {
    
    }
}

class JsonManager {
    
    private static let instance = JsonManager()
    private var jsonUrl:String?
    
    private init() {
        
    }
    
    internal static func getInstance() -> JsonManager {
        return instance
    }
    
    private func setJsonUrl() {
        print("===== Start Load Setting =====")
        let ob = CoreDataManager.getInstance().getSetting()
        if ob != nil {
            let ip = ob!.valueForKey("ip") as! String
            let path = ob!.valueForKey("path") as! String
            let port = ob!.valueForKey("port") as! String
            self.jsonUrl = "\(port)://\(ip)"
            if path != "" {
                self.jsonUrl! += "/\(path)"
            }
        } else {
            self.jsonUrl = "http://127.0.0.1"
        }
        print("===== End Load Setting =====")
    }
    
    internal func getURL()->String {
        setJsonUrl()
        return "\(self.jsonUrl! as String)/"
    }
    
    func getProductAll()->NSDictionary! {
        setJsonUrl()
        return nil
    }
    
    func getData(response:JsonResponse, file:String) {
        setJsonUrl()
        let url:String = "\(self.jsonUrl! as String)/\(file)"
        let session = NSURLSession.sharedSession()
        let shotsUrl = NSURL(string: url as String)
        if shotsUrl != nil {
            let task = session.dataTaskWithURL(shotsUrl!) {
                (data, res, error) -> Void in
                if data != nil {
                    do {
                        let jsonData = try NSJSONSerialization.JSONObjectWithData(data!, options:NSJSONReadingOptions.MutableContainers ) as! NSArray
                        response.onLoaded(jsonData)
                    } catch _ {
                        // Error
                    }
                } else {
                    print("json no data!")
                    response.onLoaded(nil)
                }
            }
            task.resume()
        } else {
            print("No url")
            response.onLoaded(nil)
        }
    }
}