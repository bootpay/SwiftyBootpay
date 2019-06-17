//
//  ValidRequest.swift
//  Alamofire
//
//  Created by YoonTaesup on 2019. 6. 17..
//

import Foundation

public class ValidRequest {
    
//    static func validUXAvailablePG(_ request: BootpayRequest) -> BootpayRequest {
//
//        guard let ux = BootpayUX(rawValue: request.ux) else { return request }
//        if(PGAvailable.isUXPGDefault(ux)) { return validPGDialog(request) }
//        if(PGAvailable.isUXPGSubscript(ux)) { return validPGDialog(request) }
//        if(PGAvailable.isUXBootpayApi(ux)) { return validPGDialog(request) }
//        if(PGAvailable.isUXApp2App(ux)) { return validPGDialog(request) }
//        return request
//    }
//
//    private static func validPGDialog(_ request: BootpayRequest) -> BootpayRequest {
//        if(request.pg == "") { return request } // 통합결제창
//        if(request.methods.count > 0) { return request }
//        let methods = PGAvailable.getDefaultMethods(request.pg)
//        if(methods.count == 0) { return request }
//        if(methods.count == 1) {
//            request.method = methods[0].rawValue
//        }
////        let contain = methods.filter{ $0.rawValue == request.method }.count > 0
//        if let method = Method(rawValue: request.method) {
//            if !methods.contains(method) {
//                let msg = "\(request.pg)'s \(request.method) is not supported"
//                try! throwException(msg)
//            }
//        }
//      
//        return request
//    }
//
//    private static func validPGSubscript(_ request: BootpayRequest) -> BootpayRequest {
//        if(request.pg == "nicepay") {
//            let msg = "\(request.pg) 정기결제는 클라이언트 UI 연동방식이 아닌, REST API를 통해 진행해주셔야 합니다"
//            try! throwException(msg)
//        }
//        return request
//    }
//
//    private static func throwException(_ msg: String) throws {
//        NSLog("bootpay", msg)
//        throw "Application id is not configured."
//    }
}
