//
//  BootpayMethod.swift
//  Alamofire
//
//  Created by YoonTaesup on 2019. 7. 22..
//

public struct BootpayMethod {
    public static let CARD = "card"; // card isp
    public static let CARD_SIMPLE = "card_simple"; // card 수기결제
    public static let BANK = "bank"; // 계좌이체
    public static let VBANK = "vbank"; // 가상계좌
    public static let PHONE = "phone"; // 휴대폰 소액결제
    public static let SUBSCRIPT_CARD = "card_rebill"; // 카드 정기결제
    public static let SUBSCRIPT_PHONE = "phone_rebill"; // 휴대폰 정기결제
    public static let AUTH = "auth"; // 본인인증
    public static let EASY = "easy"; // 간편결제
    
}
