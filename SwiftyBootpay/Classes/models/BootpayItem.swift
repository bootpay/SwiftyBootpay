//
//  BootpayItem.swift
//  CryptoSwift
//
//  Created by YoonTaesup on 2019. 4. 12..
//

//import "BootpayParams.swift"

import ObjectMapper

//MARK: Bootpay Models
public class BootpayItem: NSObject, BootpayParams, Mappable, Decodable {
    public override init() {}
    @objc public var item_name = "" //아이템 이름
    @objc public var qty: Int = 0  //상품 판매된 수량
    @objc public var unique = "" //상품의 고유 PK
    @objc public var price = Double(0) //상품 하나당 판매 가격
    @objc public var cat1 = "" //카테고리 상
    @objc public var cat2 = "" //카테고리 중
    @objc public var cat3 = "" //카테고리 하
    
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
            "item_name: '\(item_name.replace(target: "\"", withString: "'").replace(target: "'", withString: "\\'").replace(target: "'\n", withString: ""))',",
            "qty: \(qty),",
            "unique: '\(unique)',",
            "price: \(Int(price)),",
            "cat1: '\(cat1.replace(target: "\"", withString: "'").replace(target: "'", withString: "\\'").replace(target: "'\n", withString: ""))',",
            "cat2: '\(cat2.replace(target: "\"", withString: "'").replace(target: "'", withString: "\\'").replace(target: "'\n", withString: ""))',",
            "cat3: '\(cat3.replace(target: "\"", withString: "'").replace(target: "'", withString: "\\'").replace(target: "'\n", withString: ""))'",
            "}"
            ].reduce("", +)
    }
}

