//
//  BootpayUX.swift
//  SwiftyBootpay
//
//  Created by YoonTaesup on 2019. 4. 12..
//

public struct UX {
    public static let PG_DIALOG = "PG_DIALOG" // 일반 PG 결제
    public static let PG_SUBSCRIPT = "PG_SUBSCRIPT" // 일반 PG사 정기결제
//    case PG_SUBSCRIPT_RESERVE // 일반 PG사 정기결제지만 예약결제처럼 사용할 때 사용
//    case BOOTPAY_DIALOG // 부트페이 통합 결제창
//    case BOOTPAY_ROCKET // 부트페이 로켓결제
//    case BOOTPAY_ROCKET_TEMPORARY // 부트페이 로켓결제 - 카드수기처럼 쓸 수 있는 형태
    public static let BOOTPAY_REMOTE_LINK = "BOOTPAY_REMOTE_LINK" // 결제링크 바로 생성
    public static let BOOTPAY_REMOTE_FORM = "BOOTPAY_REMOTE_FORM" // 결제폼 생성
    public static let BOOTPAY_REMOTE_PRE = "BOOTPAY_REMOTE_PRE" // 사전예약 생성
    
    //    BOOTPAY_CARD_SIMPLE, // 부트페이 로켓결제 일부
    //    BOOTPAY_SUBSCRIPT_ROCKET, // 부트페이 로켓결제
    //    BOOTPAY_SUBSCRIPT_SERVER, // PG 정기결제와 동일
    //    BOOTPAY_CHARGE_SERVER, //PG 정기결제와 동일
    //    BOOTPAY_CHARGE_LINK, // 링크결제, 발행 개념
    //    BOOTPAY_CHARGE_LINK_SUBSCRIPT, // 청구형 - 링크결제, 정기적으로 결제하는 형태지만, 결제를 강요하는 형태는 아님. 그러나 결제하지 않으면 사용한 만큼 돈이 계속 쌓이는 형태 (PG사 입장에서도 리스크는 없다!)
    //    BOOTPAY_RESERVE_LINK, // 예약 - 링크 (현재 지불 의사가 있으나 결제를 하진 않고(공동구매 등), 미래시점에 결제를 결정하기 위해 SMS를 받고자 설정함, 가격 또한 미래시점에 통지할 수 있다)
    //    BOOTPAY_RESERVE_SERVER, // 예약 - 미래시점에 1회 결제 (텀블벅과 같은 조건부 기금모음 사이트, 특정 조건이 되면 지불할것을 미리 승인하는 서비스)
    //    BOOTPAY_IC, // IC 단말 결제
    //    BOOTPAY_SWIPE, // SWIPE 결제
    //    BOOTPAY_NFC, // NFC
    //    BOOTPAY_SAMSUNGPAY, // 삼성페이
    public static let APP2APP_REMOTE = "APP2APP_REMOTE" // 원격결제, 리모트
    public static let APP2APP_CARD_SIMPLE = "APP2APP_CARD_SIMPLE"// 외부앱 - 수기결제
    public static let APP2APP_NFC = "APP2APP_NFC"// 외부앱 - NFC
    public static let APP2APP_SAMSUNGPAY = "APP2APP_SAMSUNGPAY" // 외부앱 - 삼성페이
    public static let APP2APP_SUBSCRIPT = "APP2APP_SUBSCRIPT" // 외부앱 - 정기결제
    public static let APP2APP_CASH_RECEIPT = "APP2APP_CASH_RECEIPT" // 현금영수증
    public static let APP2APP_OCR = "APP2APP_OCR" // 외부앱
    public static let NONE = "NONE"
}

@objc public class BootpayUX: NSObject {
    @objc public static let PG_DIALOG = UX.PG_DIALOG
    @objc public static let PG_SUBSCRIPT = UX.PG_SUBSCRIPT
    
    @objc public static let BOOTPAY_REMOTE_LINK = UX.BOOTPAY_REMOTE_LINK
    @objc public static let BOOTPAY_REMOTE_FORM = UX.BOOTPAY_REMOTE_FORM
    @objc public static let BOOTPAY_REMOTE_PRE = UX.BOOTPAY_REMOTE_PRE
    
    @objc public static let APP2APP_REMOTE = UX.APP2APP_REMOTE
    @objc public static let APP2APP_CARD_SIMPLE = UX.APP2APP_CARD_SIMPLE
    @objc public static let APP2APP_NFC = UX.APP2APP_NFC
    
    @objc public static let APP2APP_SAMSUNGPAY = UX.APP2APP_SAMSUNGPAY
    @objc public static let APP2APP_SUBSCRIPT = UX.APP2APP_SUBSCRIPT
    @objc public static let APP2APP_CASH_RECEIPT = UX.APP2APP_CASH_RECEIPT
    @objc public static let APP2APP_OCR = UX.APP2APP_OCR
    @objc public static let NONE = UX.NONE
}

