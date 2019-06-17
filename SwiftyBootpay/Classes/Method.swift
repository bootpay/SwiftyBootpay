//
//  Method.swift
//  SwiftyBootpay
//
//  Created by YoonTaesup on 2019. 6. 14..
//

enum Method : String {
    case CARD
    case CARD_SIMPLE
    case BANK
    case VBANK
    case PHONE
    case AUTH // 본인인증
    //    CARD_REBILL,
    case SUBSCRIPT_CARD // 정기결제
    case SUBSCRIPT_PHONE // 정기결제
    case EASY // 간편결제
    case SELECT
    case NONE 
}

