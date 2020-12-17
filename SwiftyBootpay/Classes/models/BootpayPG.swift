//
//  BootpayPG.swift
//  SwiftyBootpay
//
//  Created by YoonTaesup on 2019. 7. 22..
//
  
public struct PG {
    public static let KCP = "kcp"
    public static let DANAL = "danal"
    public static let INICIS = "inicis"
    public static let NICEPAY = "nicepay"
    public static let LGUP = "lgup"
    public static let PAYAPP = "payapp"
    public static let KAKAO = "kakao"
    public static let PAYCO = "payco"
    public static let KICC = "kicc"
    public static let EASYPAY = "kicc"
    public static let JTNET = "tpay"
    public static let TPAY = "tpay"
    public static let MOBILIANS = "mobilians"
    public static let PAYLETTER = "payletter"
    public static let BOOTPAY = "bootpay"
    public static let ONESTORE = "onestore"
    public static let WELCOME = "welcome"
    public static let TOSS = "toss"
}

@objc public class BootpayPG: NSObject {
    @objc public static let KCP = PG.KCP
    @objc public static let DANAL = PG.DANAL
    @objc public static let INICIS = PG.INICIS
    @objc public static let NICEPAY = PG.NICEPAY
    @objc public static let LGUP = PG.LGUP
    @objc public static let PAYAPP = PG.PAYAPP
    @objc public static let KAKAO = PG.KAKAO
    @objc public static let PAYCO = PG.PAYCO
    @objc public static let KICC = PG.KICC
    @objc public static let EASYPAY = PG.EASYPAY
    @objc public static let JTNET = PG.JTNET
    @objc public static let TPAY = PG.TPAY
    @objc public static let MOBILIANS = PG.MOBILIANS
    @objc public static let PAYLETTER = PG.PAYLETTER
    @objc public static let BOOTPAY = PG.BOOTPAY
    @objc public static let ONESTORE = PG.ONESTORE
    @objc public static let WELCOME = PG.WELCOME
    @objc public static let TOSS = PG.TOSS
}

class PGName {
    public static func getName(_ name: String) -> String {
        switch name {
        case PG.KCP:
            return "NHN KCP"
        case PG.DANAL:
            return "Danal"
        case PG.INICIS:
            return "KG 이니시스"
        case PG.NICEPAY:
            return "NICEPAY"
        case PG.LGUP:
            return "토스페이먼츠"
        case PG.TOSS:
            return "토스페이먼츠"
        case PG.PAYAPP:
            return "페이앱"
        case PG.KICC:
            return "EASY PAY"
        case PG.JTNET:
            return "tPAY"
        case PG.MOBILIANS:
            return "KG 모빌리언스"
        case PG.PAYLETTER:
            return "payletter"
        case PG.WELCOME:
            return "웰컴페이먼츠"
        default: 
            return ""
        }
    }
}
