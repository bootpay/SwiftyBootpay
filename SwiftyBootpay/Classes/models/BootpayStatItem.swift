//
//  BootpayStatItem.swift
//  SwiftyBootpay
//
//  Created by YoonTaesup on 2019. 4. 12..
//
import ObjectMapper

public class BootpayStatItem: NSObject, Mappable, BootpayParams {
    public override init() {}
    
    @objc public var item_name = "" //상품명
    @objc public var item_img = "" //상품이미지 주소 
    @objc public var unique = "" //상품의 고유 PK
    @objc public var cat1 = "" //카테고리 상
    @objc public var cat2 = "" //카테고리 중
    @objc public var cat3 = "" //카테고리 하
     
    public required init?(map: Map) {
    }
    
    public func mapping(map: Map) {
        item_name <- map["item_name"]
        item_img <- map["item_img"]
        unique <- map["unique"]
        cat1 <- map["cat1"]
        cat2 <- map["cat2"]
        cat3 <- map[cat3]
    }
    
//    @objc func toJson() -> String {
//        do {
//            let jsonEncoder = JSONEncoder()
//            let jsonData = try jsonEncoder.encode(self)
//            return String(data: jsonData, encoding: String.Encoding.utf16) ?? ""
//        } catch {
//            return ""
//        }
//    }
}
