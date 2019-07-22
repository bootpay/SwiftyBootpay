//
//  SMSPayload.swift
//  SwiftyBootpay
//
//  Created by YoonTaesup on 2019. 4. 12..
//
import ObjectMapper

@objc public class SMSPayload: NSObject, BootpayParams, Mappable  {
    static let REMOTE_ORDER_TYPE_FORM = 1
    static let REMOTE_ORDER_TYPE_PRE = 2
    
    @objc public var o_id = ""
    @objc public var o_t = SMSPayload.REMOTE_ORDER_TYPE_FORM
    
    @objc public var sj = ""
    @objc public var msg = ""
    @objc public var pt = PushType.SMS
    
    @objc public var sp = ""
    @objc public var rps = [String]()
    @objc public var rq_at = Date()
    @objc public var s_at = Date()
    
    // 알림톡 관련
    @objc public var k_tp_id = "" // 템플릿 코드
    @objc public var k_msg = ""  // 알림톡 메시지
    @objc public var k_vals = [String: String]()
    @objc public var k_btns = [String: String]()
    @objc public var k_sms_t = PushType.SMS
    
    // 친구톡 관련
    @objc public var img_url = ""
    @objc public var img_link = ""
    @objc public var ad = 1 //1: 표기함, 0: 표기안함, default 1
    
    // MMS 관련
    @objc public var files = [String]()
    
    public override init() {}
    public required init?(map: Map) {
    }
    
    public func mapping(map: Map) {
        o_id <- map["o_id"]
        o_t <- map["o_t"]
        
        sj <- map["sj"]
        msg <- map["msg"]
        pt <- map["pt"]
        
        sp <- map["sp"]
        rps <- map["rps"]
        rq_at <- map["rq_at"]
        s_at <- map["s_at"]
        
        k_tp_id <- map["k_tp_id"]
        k_msg <- map["k_msg"]
        k_vals <- map["k_vals"]
        k_btns <- map["k_btns"]
        k_sms_t <- map["k_sms_t"]
        
        img_url <- map["img_url"]
        img_link <- map["img_link"]
        ad <- map["ad"]
        files <- map["files"]
    }
}
 
