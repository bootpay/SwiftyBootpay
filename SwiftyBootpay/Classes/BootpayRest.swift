//
//  BootpayRest.swift
//  Alamofire
//
//  Created by Taesup Yoon on 01/04/2020.
//

import UIKit
import Alamofire

 
@objc public protocol BootpayRestProtocol {
    @objc(callbackRestToken:) func callbackRestToken(resData: [String: Any])
    @objc(callbackEasyCardUserToken:) func callbackEasyCardUserToken(resData: [String: Any])
}

@available(*, deprecated, message: "이 로직은 서버사이드에서 수행되어야 합니다. rest_application_id와 prviate_key는 보안상 절대로 노출되어서 안되는 값입니다. 개발자의 부주의로 고객의 결제가 무단으로 사용될 경우, 부트페이는 책임이 없음을 밝힙니다.")
@objc public class BootpayRest: NSObject {
    
    @objc(getRestToken::::)
    public static func getRestToken(sendable: BootpayRestProtocol, restApplicationId: String, privateKey: String, gameObject: String = "") {
        
        var params = [String: Any]()
        params["application_id"] = restApplicationId
        params["private_key"] = privateKey
        
        let headers: HTTPHeaders = [
            .init(name: "Authorization", value: "1234"),
                        ]
        
        AF.request("https://api.bootpay.co.kr/request/token", method: .post, parameters: params, encoding: URLEncoding.default, headers: headers)
                 .validate()
                 .responseJSON { response in
                     
                    if let value = response.value as? [String: AnyObject] {
                        sendable.callbackRestToken(resData: value)
                    }
             
        }
        
        
    }

    @objc(getEasyPayUserToken::::)
    public static func getEasyPayUserToken(sendable: BootpayRestProtocol, restToken: String, user: String, gameObject: String = "") {
        guard let user = BootpayUser(JSONString: user) else { return }
 
        var params = [String: Any]()
        params["user_id"] = user.id
        params["email"] = user.email
        params["name"] = user.username
        params["gender"] = user.gender
        params["birth"] = user.birth
        params["phone"] = user.phone
           
        
         let headers: HTTPHeaders = [
                    .init(name: "Authorization", value: restToken) 
                ]
        
        AF.request("https://api.bootpay.co.kr/request/user/token", method: .post, parameters: params,  encoding:  URLEncoding.default, headers: headers)
                   .validate()
                   .responseJSON { response in
                    
//                    print(response)
                    
                    if let value = response.value as? [String: AnyObject] {
                        sendable.callbackEasyCardUserToken(resData: value)
                    }
          }
    }
}
