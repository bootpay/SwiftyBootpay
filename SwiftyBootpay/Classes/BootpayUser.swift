//
//  BootpayUser.swift
//  CryptoSwift
//
//  Created by YoonTaesup on 2019. 4. 12..
//

import ObjectMapper

//MARK: Bootpay Models
public class BootpayUser: NSObject, BootpayParams, Mappable {
    public required init?(map: Map) {
    }
    
    public func mapping(map: Map) {
        id <- map["id"]
        username <- map["username"]
        email <- map["email"]
        gender <- map["gender"]
        birth <- map["birth"]
        phone <- map["phone"]
        area <- map["area"]
        addr <- map["addr"]
    }
    
    public override init() {}
    var user_id = ""    
    @objc public var id = ""
    @objc public var username = ""
    @objc public var email = ""
    @objc public var gender = 0
    @objc public var birth = ""
    @objc public var phone = ""
    @objc public var area = ""
    @objc public var addr = ""
    
    func toString() -> String {
        return [
            "{",
            "id: '\(id.replace(target: "\"", withString: "'").replace(target: "'", withString: "\\'").replace(target: "'\n", withString: ""))',",
            "username: '\(username.replace(target: "\"", withString: "'").replace(target: "'", withString: "\\'").replace(target: "'\n", withString: ""))',",
            "user_id: '\(user_id.replace(target: "\"", withString: "'").replace(target: "'", withString: "\\'").replace(target: "'\n", withString: ""))',",
            "email: '\(email.replace(target: "\"", withString: "'").replace(target: "'", withString: "\\'").replace(target: "'\n", withString: ""))',",
            "gender: \(Int(gender)),",
            "birth: '\(birth.replace(target: "\"", withString: "'").replace(target: "'", withString: "\\'").replace(target: "'\n", withString: ""))',",
            "phone: '\(phone.replace(target: "\"", withString: "'").replace(target: "'", withString: "\\'").replace(target: "'\n", withString: ""))',",
            "area: '\(area.replace(target: "\"", withString: "'").replace(target: "'", withString: "\\'").replace(target: "'\n", withString: ""))',",
            "addr: '\(addr.replace(target: "\"", withString: "'").replace(target: "'", withString: "\\'").replace(target: "'\n", withString: ""))'",
            "}"
            ].reduce("", +)
    }
    
//    @objc public func toJson() -> String {
//        do {
//            let jsonEncoder = JSONEncoder()
//            let jsonData = try jsonEncoder.encode(self)
//            return String(data: jsonData, encoding: String.Encoding.utf16) ?? ""
//        } catch {
//            return ""
//        }
//    }
}
