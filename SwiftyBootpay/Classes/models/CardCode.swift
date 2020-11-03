//
//  CardCode.swift
//  SwiftyBootpay
//
//  Created by Taesup Yoon on 13/10/2020.
//

import Foundation

public struct CardCode {
    public static let BC = "01" //BC카드
    public static let KB = "02" //국민카드
    public static let HN = "03" //하나카드
    public static let SS = "04" //삼성카드
    public static let SH = "06" //신한카드
    public static let HD = "07" //현대카드
    public static let LT = "08" //롯데카드
    public static let CT = "11" //씨티카드
    public static let NH = "12" //농협카드
    public static let SH2 = "13" //수협카드
    public static let SH3 = "14" //신협카드
    public static let GJ = "21" //광주카드
    public static let JB = "22" //전북카드
    public static let JJ = "23" //제주카드
    public static let SHCPT = "24" //신한캐피탈카드
    public static let GVS = "25" //해외비자
    public static let GMST = "26" //해외마스터
    
    public static let GDNS = "27" //해외디아너스카드
    public static let GAMX = "28" //해외AMX
    public static let GJCB = "29" //해외JCB
    public static let SKOK = "31" //SK OK Cashbag
    public static let POST = "32" //우체국
    
    public static let SM = "33" //새마을체크카드
    public static let CH = "34" //중국은행 체크카드
    public static let KDB = "35" //KDB체크카드
    public static let HD2 = "36" //현대증권 체크카드
    public static let JC = "37" //저축은행
    
    public static func getColor(code: String) -> [UIColor] { 
        switch code {
        case CardCode.BC:
            return [
                UIColor.init(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0),
                UIColor.init(red: 88.0 / 255, green: 86.0 / 255, blue: 87.0 / 255, alpha: 1.0)
            ]
        case CardCode.KB:
            return [
                UIColor.init(red: 254.0 / 255, green: 205.0 / 255, blue: 46.0 / 255, alpha: 1.0),
                UIColor.init(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0),
//                UIColor.init(red: 115.0 / 255, green: 105.0 / 255, blue: 95.0 / 255, alpha: 1.0)
            ]
        case CardCode.HN:
            return [
                UIColor.init(red: 10.0 / 255, green: 122.0 / 255, blue: 108.0 / 255, alpha: 1.0),
                UIColor.init(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0),
            ]
        case CardCode.SS:
            return [
                UIColor.init(red: 50.0 / 255, green: 129.0 / 255, blue: 245.0 / 255, alpha: 1.0),
                UIColor.init(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0),
            ]
        case CardCode.SH:
            return [
                UIColor.init(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0),
                UIColor.init(red: 17.0 / 255, green: 34.0 / 255, blue: 105.0 / 255, alpha: 1.0),
            ]
        case CardCode.HD:
            return [
                UIColor.init(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0),
                UIColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0),
            ]
        case CardCode.LT:
            return [
                UIColor.init(red: 247.0 / 255, green: 247.0 / 255, blue: 247.0 / 255, alpha: 1.0),
                UIColor.init(red: 217.0 / 255, green: 24.0 / 255, blue: 34.0 / 255, alpha: 1.0)
            ]
        case CardCode.CT:
            return [
                UIColor.init(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0),
                UIColor.init(red: 3.0 / 255, green: 57.0 / 255, blue: 124.0 / 255, alpha: 1.0)
            ]
        case CardCode.NH:
            return [
                UIColor.init(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0),
                UIColor.init(red: 8.0 / 255, green: 91.0 / 255, blue: 170.0 / 255, alpha: 1.0)
            ]
        case CardCode.SH2:
            return [
                UIColor.init(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0),
                UIColor.init(red: 14.0 / 255, green: 117.0 / 255, blue: 198.0 / 255, alpha: 1.0)
            ]
        case CardCode.SH3:
            return [
                UIColor.init(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0),
                UIColor.init(red: 12.0 / 255, green: 97.0 / 255, blue: 174.0 / 255, alpha: 1.0)
            ]
        case CardCode.GJ:
            return [
                UIColor.init(red: 73.0 / 255, green: 199.0 / 255, blue: 230.0 / 255, alpha: 1.0),
                UIColor.init(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0),
            ]
        case CardCode.JB:
            return [
                UIColor.init(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0),
                UIColor.init(red: 5.0 / 255, green: 41.0 / 255, blue: 103.0 / 255, alpha: 1.0),
            ]
        case CardCode.JJ:
            return [
                UIColor.init(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0),
                UIColor.init(red: 17.0 / 255, green: 34.0 / 255, blue: 105.0 / 255, alpha: 1.0),
            ]
        case CardCode.SHCPT:
            return [
                UIColor.init(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0),
                UIColor.init(red: 17.0 / 255, green: 34.0 / 255, blue: 105.0 / 255, alpha: 1.0),
            ]
        case CardCode.GVS:
            return [
                UIColor.init(red: 247.0 / 255, green: 247.0 / 255, blue: 247.0 / 255, alpha: 1.0),
                UIColor.init(red: 7.0 / 255, green: 84.0 / 255, blue: 152.0 / 255, alpha: 1.0),
                
            ]
        case CardCode.GMST:
            return [
                UIColor.init(red: 247.0 / 255, green: 247.0 / 255, blue: 247.0 / 255, alpha: 1.0),
                UIColor.init(red: 14.0 / 255, green: 14.0 / 255, blue: 14.0 / 255, alpha: 1.0),
                
            ]
        case CardCode.GDNS:
            return [
                UIColor.init(red: 247.0 / 255, green: 247.0 / 255, blue: 247.0 / 255, alpha: 1.0),
                UIColor.init(red: 14.0 / 255, green: 14.0 / 255, blue: 14.0 / 255, alpha: 1.0),
                
            ]
        case CardCode.GAMX:
            return [
                UIColor.init(red: 128.0 / 255, green: 128.0 / 255, blue: 128.0 / 255, alpha: 1.0),
                UIColor.init(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0),
            ]
        case CardCode.GJCB:
            return [
                UIColor.init(red: 4.0 / 255, green: 49.0 / 255, blue: 123.0 / 255, alpha: 1.0),
                UIColor.init(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0),
            ]
        case CardCode.SKOK:
            return [
                UIColor.init(red: 247.0 / 255, green: 247.0 / 255, blue: 247.0 / 255, alpha: 1.0),
                UIColor.init(red: 217.0 / 255, green: 34.0 / 255, blue: 60.0 / 255, alpha: 1.0),
            ]
        case CardCode.POST:
            return [
                UIColor.init(red: 128.0 / 255, green: 98.0 / 255, blue: 166.0 / 255, alpha: 1.0),
                UIColor.init(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0),
            ]
        case CardCode.SM:
            return [
                UIColor.init(red: 17.0 / 255, green: 24.0 / 255, blue: 34.0 / 255, alpha: 1.0),
                UIColor.init(red: 193.0 / 255, green: 161.0 / 255, blue: 106.0 / 255, alpha: 1.0),
            ]
        case CardCode.CH:
            return [
                UIColor.init(red: 179.0 / 255, green: 77.0 / 255, blue: 79.0 / 255, alpha: 1.0),
                UIColor.init(red: 196.0 / 255, green: 192.0 / 255, blue: 202.0 / 255, alpha: 1.0),
            ]
        case CardCode.KDB:
            return [
                UIColor.init(red: 29.0 / 255, green: 183.0 / 255, blue: 238.0 / 255, alpha: 1.0),
                UIColor.init(red: 208.0 / 255, green: 247.0 / 255, blue: 254.0 / 255, alpha: 1.0),
            ]
        case CardCode.HD2:
            return [
                UIColor.init(red: 128.0 / 255, green: 140.0 / 255, blue: 173.0 / 255, alpha: 1.0),
                UIColor.init(red: 226.0 / 255, green: 233.0 / 255, blue: 252.0 / 255, alpha: 1.0),
            ]
        case CardCode.JC:
            return [
                UIColor.init(red: 66.0 / 255, green: 60.0 / 255, blue: 60.0 / 255, alpha: 1.0),
                UIColor.init(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0),
            ]
        default:
            return [
                UIColor.init(red: 247.0 / 255, green: 247.0 / 255, blue: 247.0 / 255, alpha: 1.0),
                UIColor.init(red: 14.0 / 255, green: 14.0 / 255, blue: 14.0 / 255, alpha: 1.0),
            ]
        }
    }
}
