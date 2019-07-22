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
    @objc public var vbank_result = false //가상계좌 결과창을 볼지 말지 (가상계좌 사용시)
    @objc public var quotas = [Int]() //할부허용 범위 (5만원 이상 구매시)
    @objc public var app_scheme = "" //app2app 결제시 return 받을 intent scheme
    @objc public var app_scheme_host = "" //app2app 결제시 return 받을 intent scheme host
    @objc public var ux = "" //다양한 결제시나리오를 지원하기 위한 용도로 사용됨
    
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
        ux <- map["ux"]
    }
}
