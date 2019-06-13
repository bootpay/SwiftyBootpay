//
//  RemoteOrderPre.swift
//  SwiftyBootpay
//
//  Created by YoonTaesup on 2019. 4. 12..
//

import ObjectMapper

//import "UnityCBootpay/BootpayCExtra.h"

//MARK: Bootpay Models
public class RemoteOrderPre: NSObject, BootpayParams, Mappable {
    public override init() {}
    @objc public var e_p = ""
    @objc public var is_r_n = false
    @objc public var is_sale = false
    @objc public var s_at = Date()
    @objc public var e_at = TimeInterval(0)
    @objc public var desc_html = ""
    @objc public var n = ""
    @objc public var cn = ""
//    public var BootpayCExtra;
    
    public required init?(map: Map) {
    }
    
    public func mapping(map: Map) {
        e_p <- map["e_p"]
        is_r_n <- map["is_r_n"]
        is_sale <- map["is_sale"]
        s_at <- map["s_at"]
        e_at <- map["e_at"]
        desc_html <- map["desc_html"]
        n <- map["n"]
        cn <- map["cn"]
    } 
}
