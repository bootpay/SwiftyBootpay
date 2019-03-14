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

extension String {
    subscript (bounds: CountableClosedRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start...end])
    }
    
    subscript (bounds: CountableRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start..<end])
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
public class BootpayItem: NSObject, Params {
    public override init() {}
    @objc public var item_name = ""
    @objc public var qty: Int = 0
    @objc public var unique = ""
    @objc public var price = Double(0)
    @objc public var cat1 = ""
    @objc public var cat2 = ""
    @objc public var cat3 = ""
    
    func toString() -> String {
        if item_name.isEmpty { return "" }
        if qty == 0 { return "" }
        if unique.isEmpty { return "" }
        if price == Double(0) { return "" }
        
        return [
            "{",
            "item_name: '\(item_name.replace(target: "\"", withString: "'").replace(target: "'", withString: "\\'"))',",
            "qty: \(qty),",
            "unique: '\(unique)',",
            "price: \(Int(price)),",
            "cat1: '\(cat1.replace(target: "\"", withString: "'").replace(target: "'", withString: "\\'"))',",
            "cat2: '\(cat2.replace(target: "\"", withString: "'").replace(target: "'", withString: "\\'"))',",
            "cat3: '\(cat3.replace(target: "\"", withString: "'").replace(target: "'", withString: "\\'"))'",
            "}"
            ].reduce("", +)
    }
}

public class BootpayController: UIViewController {
    @objc public var price = Double(0)
    @objc public var application_id = BootpayAnalytics.sharedInstance.getApplicationId()
    @objc public var name = ""
    @objc public var pg = ""
    @objc public var phone = ""
    @objc public var show_agree_window = 0
    @objc public var items = [BootpayItem]()
    @objc public var method = ""
    @objc public var user_info: [String: String] = [:]
    @objc public var params: [String: String] = [:]
    @objc public var order_id = ""
    @objc public var use_order_id = 0
    @objc public var expire_month = 12 // 정기결제 실행 기간
    @objc public var vbank_result = 1 // 가상계좌 결과창 안보이게 하기
    @objc public var account_expire_at = "" // 가상계좌 입금 만료 기한
    @objc public var quotas = [0,2,3,4,5,6,7,8,9,10,11,12] // 할부 개월 수
    var isPaying = false
    @objc public var sendable: BootpayRequestProtocol?
    
    internal var wv: BootpayWebView!
}


extension BootpayController: Params {
    @objc(addItem:)
    public func addItem(item: BootpayItem) {
        self.items.append(item)
    }
    
    @objc(setBootpayItems:)
    public func setItems(items: [BootpayItem]) {
        self.items = items
    }
    
    @objc public func transactionConfirm(data: [String: Any]) {
        let json = dicToJsonString(data).replace(target: "'", withString: "\\'") 
        wv.doJavascript("window.BootPay.transactionConfirm(\(json));")
    }
    
    @objc public func removePaymentWindow() {
        wv.doJavascript("window.BootPay.removePaymentWindow();")
    }
    
    @objc public func dismiss() {
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
        print(script)
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
        let str = self.items.map { $0.toString() }.reduce("", {$0 + "," + $1})
        return str[1..<str.count]
    }
    
    fileprivate func generateScript() -> String {
//        print(name)
//        print(name.replace(target: "'", withString: "\'"))
        
        var array = ["BootPay.request({",
                     "price: '\(price)',",
            "application_id: '\(application_id)',",
            "name: '\(name.replace(target: "\"", withString: "'").replace(target: "'", withString: "\\'"))',",
            "pg:'\(pg)',",
            "phone:'\(phone)',",
            "show_agree_window: '\(show_agree_window)',",
            "items: [\(generateItems())],",
            "params: \(dicToJsonString(params).replace(target: "'", withString: "\\'")),",
            "order_id: '\(order_id)',",
            "use_order_id: '\(use_order_id)',",
            "account_expire_at: '\(account_expire_at)',",
            "extra: {",
                "app_scheme:'\(getURLSchema())',",
                "expire_month:'\(expire_month)',",
                "vbank_result:\(vbank_result),",
                "quota:'\(quotas.compactMap{String($0)}.joined(separator: ","))'",
            "}",
        ]
        
        if !method.isEmpty {
            array.append(",method: '\(method)'")
        }
        if !user_info.isEmpty {
            array.append(",user_info: \(dicToJsonString(user_info).replace(target: "'", withString: "\\'"))")
        }
        
        let result = array +
            ["}).error(function (data) {",
             "webkit.messageHandlers.\(wv.bridgeName).postMessage(data);",
             "}).confirm(function (data) {",
             "webkit.messageHandlers.\(wv.bridgeName).postMessage(data);",
             "}).ready(function (data) {",
             "webkit.messageHandlers.\(wv.bridgeName).postMessage(data);",
             "}).cancel(function (data) {",
             "webkit.messageHandlers.\(wv.bridgeName).postMessage(data);",
             "}).close(function () {",
             "webkit.messageHandlers.\(wv.bridgeName).postMessage('close');",
             "}).done(function (data) {",
             "webkit.messageHandlers.\(wv.bridgeName).postMessage(data);",
             "});"]
        
        return result.reduce("", +)
    }
    
    fileprivate func clear() {
        if self.items.count > 0 { self.items.removeAll() }
        
        self.price = Double(0)
        self.application_id = ""
        self.name = ""
        self.pg = ""
        self.phone = ""
        self.items = [BootpayItem]()
        self.method = ""
        self.order_id = ""
        self.use_order_id = 0
        self.user_info = [:]
        self.params = [:]
        self.expire_month = 12 // 정기결제 실행 기간
        self.vbank_result = 1 // 가상계좌 결과창 안보이게 하기
        self.quotas = [0,2,3,4,5,6,7,8,9,10,11,12] // 할부 개월 수
    }
    
    fileprivate func getURLSchema() -> String{
        guard let schemas = Bundle.main.object(forInfoDictionaryKey: "CFBundleURLTypes") as? [[String:Any]],
            let schema = schemas.first,
            let urlschemas = schema["CFBundleURLSchemes"] as? [String],
            let urlschema = urlschemas.first
            else {
                return ""
        }
        return urlschema
    }
}


