//
//  BootpayController.swift
//  client_bootpay_swift
//
//  Created by YoonTaesup on 2017. 10. 27..
//  Copyright © 2017년 bootpay.co.kr. All rights reserved.
//

import UIKit
import WebKit


extension String: LocalizedError {
    public var errorDescription: String? { return self }
}

extension String
{
    func replace(target: String, withString: String) -> String
    {
        return self.replacingOccurrences(of: target, with: withString, options: NSString.CompareOptions.literal, range: nil)
    }
}

extension URL {
    public var queryItems: [String: String] {
        var params = [String: String]()
        return URLComponents(url: self, resolvingAgainstBaseURL: false)?
            .queryItems?
            .reduce([:], { (_, item) -> [String: String] in
                params[item.name] = item.value
                return params
            }) ?? [:]
    }
}

public protocol Params {}

//// from - devxoul's then (https://github.com/devxoul/Then)
extension Params where Self: AnyObject {
    public func params(_ block: (Self) -> Void) -> Self {
        block(self)
        return self
    }
}

//MARK: Bootpay Models
public class BootpayItem: Params {
    public init() {}
    public var item_name = ""
    public var qty: Int = 0
    public var unique = ""
    public var price = Double(0)
    
    func toString() -> String {
        if item_name.isEmpty { return "" }
        if qty == 0 { return "" }
        if unique.isEmpty { return "" }
        if price == Double(0) { return "" }
        
        return [
            "{",
            "item_name: '\(item_name)',",
            "qty: '\(qty)',",
            "unique: '\(unique)',",
            "price: '\(Int(price))'",
            "}"
            ].reduce("", +)
    }
}

public class BootpayController: UIViewController {
    public var price = Double(0)
    public var application_id = BootpayAnalytics.sharedInstance.getApplicationId()
    public var name = ""
    public var pg = ""
    public var show_agree_window = 0
    public var items = [BootpayItem]()
    public var method = ""
    public var user_info: [String: String] = [:]
    public var params: [String: String] = [:] 
    public var order_id = ""
    var isPaying = false
    public var sendable: BootpayRequestProtocol?
    
    internal var wv: BootpayWebView!
}


extension BootpayController: Params {
    public func addItem(item: BootpayItem) {
        self.items.append(item)
    }
    
    public func setItems(items: [BootpayItem]) {
        self.items = items
    }
    
    public func transactionConfirm(data: [String: Any]) {
        let json = dicToJsonString(data).replace(target: "\"", withString: "'")
        wv.doJavascript("window.BootPay.transactionConfirm(\(json));")
    }
    
    public func dismiss() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func isPayingNow() -> Bool {
        return self.isPaying
    }
}

//MARK: Bootpay Data Setting
extension BootpayController {
    fileprivate func dicToJsonString(_ data: [String: Any]) -> String {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
            let jsonStr = String(data: jsonData, encoding: .utf8)
            if let jsonStr = jsonStr {
                return jsonStr
            }
            return ""
        } catch {
            print(error.localizedDescription)
            return ""
        }
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        self.isPaying = true
        if wv == nil { wv = BootpayWebView() }
        wv.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        
        let script = generateScript() 
        wv.bootpayRequest(script)
        wv.sendable = self.sendable
        wv.parentController = self
        self.view.addSubview(wv)
    } 
    
    fileprivate func validCheck() throws {
        if price <= 0 { throw "Price is not configured." }
        if application_id.isEmpty { throw "Application id is not configured." }
        if pg.isEmpty { throw "PG is not configured." }
        if order_id.isEmpty { throw "order_id is not configured." }
    }
    
    fileprivate func generateItems() -> String {
        if self.items.count == 0 { return "" }
        return self.items.map { $0.toString() }.reduce(",", +)
    }
    
    fileprivate func generateScript() -> String {
        var array = ["BootPay.request({",
                     "price: '\(price)',",
                     "application_id: '\(application_id)',",
                     "name: '\(name)',",
                     "pg:'\(pg)',",
                     "show_agree_window: '\(show_agree_window)',",
                     "item: [\(generateItems())],",
                     "params: \(dicToJsonString(params).replace(target: "\"", withString: "'")),",
                     "order_id: '\(order_id)'",
        ]
        
        if !method.isEmpty {
            array.append(",method: '\(method)'")
        }
        if !user_info.isEmpty {
            array.append(",user_info: \(dicToJsonString(user_info).replace(target: "\"", withString: "'"))")
        }
        
        let result = array +
                ["}).error(function (data) {",
                 "webkit.messageHandlers.\(wv.bridgeName).postMessage(data);",
                 "}).confirm(function (data) {",
                 "webkit.messageHandlers.\(wv.bridgeName).postMessage(data);",
                 "}).cancel(function (data) {",
                 "webkit.messageHandlers.\(wv.bridgeName).postMessage(data);",
                 "}).done(function (data) {",
                 "webkit.messageHandlers.\(wv.bridgeName).postMessage(data);",
                 "});"]
        
        NSLog(result.reduce("", +))
        
        return result.reduce("", +)
    }
    
    fileprivate func clear() {
        if self.items.count > 0 { self.items.removeAll() }
        
        self.price = Double(0)
        self.application_id = ""
        self.name = ""
        self.pg = ""
        self.items = [BootpayItem]()
        self.method = ""
        self.order_id = "" 
    }
}


