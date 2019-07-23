//
//  BootpayRequest.swift
//  Alamofire
//
//  Created by YoonTaesup on 2019. 4. 15..
//

import Foundation
import ObjectMapper

public class BootpayPayload: NSObject, BootpayParams, Mappable  {
    
    @objc public var application_id = Bootpay.sharedInstance.getApplicationId()
    @objc public var pg = ""
    @objc public var method = ""
    @objc public var methods = [String]()
    
    @objc public var name = ""
    @objc public var price = Double(0)
    
    @objc public var tax_free = Double(0)
    
    @objc public var order_id = ""
    @objc public var use_order_id = false 
    @objc public var params: [String: Any] = [:]
    
    @objc public var account_expire_at = "" // 가상계좌 입금 만료 기한
    @objc public var show_agree_window = false
    
    @objc public var boot_key = ""
    @objc public var ux = "PG_DIALOG"
    @objc public var sms_use = false    
    
    public override init() {}
    public required init?(map: Map) {
    }
    
    public func mapping(map: Map) {
        application_id <- map["application_id"]
        pg <- map["pg"]
        method <- map["method"]
        methods <- map["methods"]
        name <- map["name"]
        price <- map["price"]
        tax_free <- map["tax_free"]
        
        order_id <- map["order_id"]
        use_order_id <- map["use_order_id"]
        params <- map["params"]
        
        account_expire_at <- map["account_expire_at"]
        show_agree_window <- map["show_agree_window"]
        
        boot_key <- map["boot_key"]
        ux <- map["ux"]
        sms_use <- map["sms_use"]
    }
    
  
    
    fileprivate func validCheck() throws {
//        if price <= 0 { throw "Price is not configured." }
        if application_id.isEmpty { throw "Application id is not configured." }
        if pg.isEmpty { throw "PG is not configured." }
        if order_id.isEmpty { throw "order_id is not configured." }
    }
    
    fileprivate func generateItems(items: [BootpayItem]?) -> String {
        guard let items = items else { return "" }
        if items.count == 0 { return "" }
        let str = items.map { $0.toString() }.reduce("", {$0 + "," + $1})
        return str[1..<str.count]
    }
    
    fileprivate func listToJson(_ list: [String]) -> String {
        var result = ""
        for v in list {
            if result.count == 0 {
                result += "'\(v)'"
            } else {
                result += ",'\(v)'"
            }
        }
        return "[\(result)]"
    }
    
    fileprivate func clear() {
//        if self.items.count > 0 { self.items.removeAll() }
        
        self.price = Double(0)
        self.application_id = ""
        self.name = ""
        self.pg = ""
//        self.phone = ""
//        self.items = [BootpayItem]()
        self.method = ""
        self.order_id = ""
        self.use_order_id = false
        self.params = [:]
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
    
    func generateScript(_ bridgeName: String, items: [BootpayItem]?, user: BootpayUser?, extra: BootpayExtra?) -> String {
        //        print(name)
        //        print(name.replace(target: "'", withString: "\'"))
        
        let userPhone = user?.phone ?? ""
        let itemsString = generateItems(items: items)
        let expire_month = extra?.expire_month ?? 0
        let vbank_result = extra?.vbank_result ?? false
        let quota = extra?.quotas.compactMap{String($0)}.joined(separator: ",") ?? ""
        
        
        var array = ["BootPay.request({",
                     "price: '\(price)',",
            "application_id: '\(application_id)',",
            "name: '\(name.replace(target: "\"", withString: "'").replace(target: "'", withString: "\\'"))',",
            "pg:'\(pg)',",
            "phone:'\(userPhone)',",
//            "show_agree_window: \(show_agree_window),",
            "show_agree_window: \(show_agree_window == true ? 1 : 0),",
            "items: [\(itemsString)],",
            "params: \(Bootpay.dicToJsonString(params).replace(target: "'", withString: "\\'")),",
            "order_id: '\(order_id)',",
            "use_order_id: '\(use_order_id)',",
            "account_expire_at: '\(account_expire_at)',",
            "extra: {",
            "app_scheme:'\(getURLSchema())',",
            "expire_month:'\(expire_month)',",
            "vbank_result:\(vbank_result),",
            "quota:'\(quota)'",
            "}",
            ]
        
        if !method.isEmpty {
            array.append(",method: '\(method)'")
        }
        
        if !methods.isEmpty {
            array.append(",methods: \(listToJson(methods))")
        }
        
        let userJson = user?.toJSONString()?.replace(target: "'", withString: "\\'") ?? ""
        array.append(",user_info: \(userJson)")
        
        
        let result = array +
            ["}).error(function (data) {",
             "webkit.messageHandlers.\(bridgeName).postMessage(data);",
                "}).confirm(function (data) {",
                "webkit.messageHandlers.\(bridgeName).postMessage(data);",
                "}).ready(function (data) {",
                "webkit.messageHandlers.\(bridgeName).postMessage(data);",
                "}).cancel(function (data) {",
                "webkit.messageHandlers.\(bridgeName).postMessage(data);",
                "}).close(function () {",
                "webkit.messageHandlers.\(bridgeName).postMessage('close');",
                "}).done(function (data) {",
                "webkit.messageHandlers.\(bridgeName).postMessage(data);",
                "});"]
        
        return result.reduce("", +)
    }
    
//    @objc public var expire_month = 12 // 정기결제 실행 기간
//    @objc public var vbank_result = 1 // 가상계좌 결과창 안보이게 하기
//    @objc public var quotas = [0,2,3,4,5,6,7,8,9,10,11,12] // 할부 개월 수
    
    
}
