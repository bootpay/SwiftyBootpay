//
//  BootpayItem.swift
//  CryptoSwift
//
//  Created by YoonTaesup on 2019. 4. 12..
//

//import "BootpayParams.swift"

import ObjectMapper

//MARK: Bootpay Models
public class BootpayItem: NSObject, BootpayParams, Mappable {
    public override init() {}
    @objc public var item_name = ""
    @objc public var qty: Int = 0
    @objc public var unique = ""
    @objc public var price = Double(0)
    @objc public var cat1 = ""
    @objc public var cat2 = ""
    @objc public var cat3 = ""
    
//    public override init() {}
    public required init?(map: Map) {
    }
    
    public func mapping(map: Map) {
        item_name <- map["item_name"]
        qty <- map["qty"]
        unique <- map["unique"]
        price <- map["price"]
        cat1 <- map["cat1"]
        cat2 <- map["cat2"]
        cat3 <- map["cat3"]
    }
    
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

