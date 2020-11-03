//
//  RemoteOrderPre.swift
//  SwiftyBootpay
//
//  Created by YoonTaesup on 2019. 4. 12..
//

import ObjectMapper

//import "UnityCBootpay/BootpayCExtra.h"

//MARK: Bootpay Models
@objc public class RemoteOrderPre: NSObject, BootpayParams, Mappable {
    public override init() {}
    @objc public var e_p = "" //예상 가격, 미입력시 안보여줌
    @objc public var is_r_n = false //구매자명 받을지 말지
    @objc public var is_sale = false //세일기간 정할지 말지
    @objc public var s_at = Date() //예약 시작일
    @objc public var e_at = TimeInterval(0) //예약 종료일
    @objc public var desc_html = "" //상품설명 html
    @objc public var n = "" //상품명
    @objc public var cn = "" //보여질 업체명
    
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
