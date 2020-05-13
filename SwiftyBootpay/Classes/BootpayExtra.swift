//
//  BootpayExtra.swift
//  SwiftyBootpay
//
//  Created by YoonTaesup on 2019. 4. 12..
//
import ObjectMapper

public class BootpayExtra: NSObject, BootpayParams, Mappable {
    @objc public var start_at = "" // 정기 결제 시작일 - 시작일을 지정하지 않으면 그 날 당일로부터 결제가 가능한 Billing key 지급
    @objc public var end_at = "" // 정기결제 만료일 -  기간 없음 - 무제한
    @objc public var expire_month = 0 //정기결제가 적용되는 개월 수 (정기결제 사용시)
    @objc public var vbank_result = true //가상계좌 결과창을 볼지 말지 (가상계좌 사용시)
    @objc public var quotas = [Int]() //할부허용 범위 (5만원 이상 구매시)
    @objc public var app_scheme = "" //app2app 결제시 return 받을 intent scheme
    @objc public var app_scheme_host = "" //app2app 결제시 return 받을 intent scheme host
//    @objc public var ux = "" //다양한 결제시나리오를 지원하기 위한 용도로 사용됨
    @objc public var locale = "ko" //결제창 언어지원
    @objc public var popup = -1
    @objc public var disp_cash_result = "Y"; // 현금영수증 보일지 말지.. 가상계좌 KCP 옵션
    @objc public var escrow = 0;
    @objc public var iosCloseButton = false;
    @objc public var onestore = BootpayOneStore()
    
    public override init() {}
    public required init?(map: Map) {
    }
    
    public func mapping(map: Map) {
        start_at <- map["start_at"]
        end_at <- map["end_at"]
        expire_month <- map["expire_month"]
        vbank_result <- map["vbank_result"]
        quotas <- map["quotas"]
        app_scheme <- map["app_scheme"]
        app_scheme_host <- map["app_scheme_host"]
//        ux <- map["ux"]
        locale <- map["locale"]
        popup <- map["popup"]
        disp_cash_result <- map["disp_cash_result"]
        escrow <- map["escrow"]
        onestore <- map["onestore"]
        iosCloseButton <- map["iosCloseButton"]
    }
    
    public func getJson(pg: String) -> String {
        let quota = quotas.compactMap{String($0)}.joined(separator: ",")
        
        var extra = [
            "{",
                "app_scheme:'\(getURLSchema())',",
                "expire_month:'\(expire_month)',",
                "vbank_result:\(vbank_result),",
                "start_at: '\(start_at)',",
                "end_at: '\(end_at)',",
                "quota:'\(quota)',",
                "popup: \(getPopup(pg: pg)),",
                "locale:'\(locale)',",
                "disp_cash_result:'\(disp_cash_result)',",
                "escrow:'\(escrow)',",
                "iosCloseButton: \(iosCloseButton)",
        ]
        
        if(pg == "onestore") {
            let oneStore = BootpayOneStore()
            extra.append(",onestore: \(oneStore.toString())")
        }
        extra.append("}")
        
        
        return extra.reduce("", +)
    }
    
    func getURLSchema() -> String{
        guard let schemas = Bundle.main.object(forInfoDictionaryKey: "CFBundleURLTypes") as? [[String:Any]],
            let schema = schemas.first,
            let urlschemas = schema["CFBundleURLSchemes"] as? [String],
            let urlschema = urlschemas.first
            else {
                return ""
        }
        return urlschema
    }
    
    fileprivate func getPopup(pg: String) -> Int {
        if pg == "nicepay" && popup == 0 {
            let floatVersion = (UIDevice.current.systemVersion as NSString).floatValue
            if floatVersion < 13 {
                return 1
            }
        }
        return popup
    }
}
