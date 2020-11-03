//
//  CardInfo.swift
//  SwiftyBootpay
//
//  Created by Taesup Yoon on 13/10/2020.
//

import ObjectMapper

public class CardInfo: NSObject, Mappable, Decodable {
    public override init() {}
    @objc public var wallet_id = ""
    @objc public var type = 0
    
    @objc public var card_name = ""
    @objc public var card_no = ""
    @objc public var card_code = ""
    @objc public var card_type = 0 //0: 기존 카드, 1: 신규카드, 2: 다른 결제수단
    @objc public var tag = 0
    
    
    public required init?(map: Map) {}
    
    public func setData(_ data: [String: AnyObject]) {
        if let wallet_id = data["wallet_id"] as? String,
            let type = data["type"] as? Int,
            let d = data["d"] as? [String: AnyObject] {
            
            self.wallet_id = wallet_id
            self.type = type
            
            if let card_name = d["card_name"] as? String,
                let card_no = d["card_no"] as?  String,
                let card_code = d["card_code"] as? String {
                
                self.card_name = card_name
                self.card_no = card_no
                self.card_code = card_code
                
            }
        }
    }
  
    public func mapping(map: Map) {
        wallet_id <- map["wallet_id"]
        type <- map["type"]
        
        card_name <- map["d"]["card_name"]
        card_no <- map["d"]["card_no"]
        card_code <- map["d"]["card_code"]
    }
    
    func toString() -> String {
        return [
            "{",
            "wallet_id: '\(wallet_id)',",
            "type: \(type),",
            "d: {",
            "card_name: '\(card_name)',",
            "card_no: '\(card_no)',",
            "card_code: '\(card_code)',",
            "}}",
        ].reduce("", +)
    }
}
