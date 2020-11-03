//
//  BootpayBioPrice.swift
//  SwiftyBootpay
//
//  Created by Taesup Yoon on 14/10/2020.
//


import Foundation
import ObjectMapper

public class BootpayBioPrice: NSObject, BootpayParams, Mappable {
    @objc public var name = ""
    @objc public var price = Double(0)
    @objc public var price_stroke = Double(0)
    
    public override init() {}
    public required init?(map: Map) {}
    
    public func mapping(map: Map) {
        name <- map["name"]
        price <- map["price"]
        price_stroke <- map["price_stroke"] 
    }
}


