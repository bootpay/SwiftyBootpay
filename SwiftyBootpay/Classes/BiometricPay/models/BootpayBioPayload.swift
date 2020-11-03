//
//  BootpayBioPayload.swift
//  SwiftyBootpay
//
//  Created by Taesup Yoon on 14/10/2020.
//


import Foundation
import ObjectMapper

public class BootpayBioPayload: BootpayPayload {
    @objc public var names = [String]()
    @objc public var prices = [BootpayBioPrice]()
    @objc public var logoImage: UIImage?
    
    public override init() {
        super.init()
    }
    public required init?(map: Map) {
        super.init(map: map)
    }
    override public func mapping(map: Map) {
        super.mapping(map: map)
        names <- map["names"]
        prices <- map["prices"]
        logoImage <- map["logoImage"]
    }
}

