//
//  BootpayStatItem.swift
//  SwiftyBootpay
//
//  Created by YoonTaesup on 2019. 4. 12..
//
import ObjectMapper

public class BootpayStatItem: NSObject, Mappable, BootpayParams {
    public override init() {}
    
    @objc public var item_name = ""
    @objc public var item_img = ""
    @objc public var unique = ""
    @objc public var cat1 = ""
    @objc public var cat2 = ""
    @objc public var cat3 = ""
     
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
