//
//  RemoteLink.swift
//  SwiftyBootpay
//
//  Created by YoonTaesup on 2019. 4. 12..
//
import ObjectMapper

@objc public class RemoteLink: NSObject, BootpayParams, Mappable {
    @objc public var member = "" // 부트페이에서 발급한 부계정 고유 키
    @objc public var is_receive_member = false // 구매자 이름 입력 허용할지 말지
    @objc public var seller_name = "" // 보여질 판매자명, 없으면 등록된 상점명이 보여짐
    @objc public var memo = "" // 판매자 메모, 없으면 보여주지 않음
    @objc public var img_url = "" // 상품 대표 이미지 URL, 없으면 보여주지 않음
    @objc public var desc_html = "" // 상품 설명, 없으면 보여주지 않음
    @objc public var delivery_area_price_jeju = Double(0) // 도서산간비용 제주
    @objc public var delivery_area_price_nonjeju = Double(0) // 도서산간비용 제주 외 지역
    
    // 링크결제에서는 전화번호는 필수다, user_phone 으로 채워지느냐 마느냐일 뿐이다
    @objc public var is_addr = false // 구매자에게 주소를 받을지 말지
    @objc public var is_delivery_area = false // 도서산간 지역 비용 추가 할지 말지
    @objc public var is_memo = false // 구매자에게 한줄메시지 받을지 말지
    
    // 세미 결제폼 관련 데이터
    @objc public var item_price = Double(0) // 본래 아이템 판매금액
    @objc public var promotion_price = Double(0) // 본래 아이템 판매금액
    @objc public var delivery_price = Double(0) // 배달 금액
    @objc public var push_policy_type = 0
    
    public override init() {}
    public required init?(map: Map) {
    }
    
    public func mapping(map: Map) {
        member <- map["member"]
        is_receive_member <- map["is_receive_member"]
        seller_name <- map["seller_name"]
        memo <- map["memo"]
        img_url <- map["img_url"]
        desc_html <- map["desc_html"]
        delivery_area_price_jeju <- map["delivery_area_price_jeju"]
        delivery_area_price_nonjeju <- map["delivery_area_price_nonjeju"]
        
        is_addr <- map["is_addr"]
        is_delivery_area <- map["is_delivery_area"]
        is_memo <- map["is_memo"]
        
        item_price <- map["item_price"]
        promotion_price <- map["promotion_price"]
        delivery_price <- map["delivery_price"]
        push_policy_type <- map["push_policy_type"] 
    }
}
