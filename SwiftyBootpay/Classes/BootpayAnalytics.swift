//
//  BootpayAnalytics.swift
//  client_bootpay_swift
//
//  Created by YoonTaesup on 2017. 10. 27..
//  Copyright © 2017년 bootpay.co.kr. All rights reserved.
//
import Foundation

 

//MARK: Bootpay Rest Api for Analytics
@objc public class BootpayAnalytics:  NSObject {
    @objc public static func postLogin(id: String, email: String, gender: Int,
                        birth: String, phone: String, area: String) {
        if Bootpay.sharedInstance.user.id == "" { Bootpay.sharedInstance.user.id = id }
        if Bootpay.sharedInstance.user.email == "" { Bootpay.sharedInstance.user.email = email }
        if Bootpay.sharedInstance.user.gender == 0 { Bootpay.sharedInstance.user.gender = gender }
        if Bootpay.sharedInstance.user.birth == "" { Bootpay.sharedInstance.user.birth = birth }
        if Bootpay.sharedInstance.user.phone == "" { Bootpay.sharedInstance.user.phone = phone }
        if Bootpay.sharedInstance.user.area == "" { Bootpay.sharedInstance.user.area = area }
        
        let uri = "https://analytics.bootpay.co.kr/login"
        var params: [String: Any]
        params = [
            "ver": Bootpay.sharedInstance.ver,
            "application_id": Bootpay.sharedInstance.getApplicationId(),
            "id": id,
            "email": email,
            "gender": "\(gender)",
            "birth": birth,
            "phone": phone,
            "area": area
        ]
        
        let json = Bootpay.stringify(params)
        do {
            let aesBody = try json.aesEncrypt(key: Bootpay.sharedInstance.key, iv: Bootpay.sharedInstance.iv)
            params = [
                "data": aesBody,
                "session_key": Bootpay.sharedInstance.getSessionKey()
            ]
            post(url: uri, params: params, isLogin: true)
            
        } catch {}
    }
    
    @objc public static func postLogin() {
        if(Bootpay.sharedInstance.user.id == "") {
            NSLog("Bootpay Analytics Warning: postLogin() not Work!! Please check id is not empty")
            return
        }
        postLogin(id: Bootpay.sharedInstance.user.id,
                  email: Bootpay.sharedInstance.user.email,
                  gender: Bootpay.sharedInstance.user.gender,
                  birth: Bootpay.sharedInstance.user.birth,
                  phone: Bootpay.sharedInstance.user.phone,
                  area: Bootpay.sharedInstance.user.area)
    }
    
    @objc public static  func start(_ url: String, _ page_type: String) {
        start(url, page_type, items: [])
    }
    
    @objc public static  func start(_ url: String, _ page_type: String, items: [BootpayStatItem]) {
        let uri = "https://analytics.bootpay.co.kr/call"
        var params: [String: Any]
        
        do {
//            let jsonEncoder = JSONEncoder()
//            let jsonData = try jsonEncoder.encode(items)
//            let json = String(data: jsonData, encoding: String.Encoding.utf8)
            
            
            
            if let json = items.toJSONString() {
                params = [
                    "ver": Bootpay.sharedInstance.ver,
                    "application_id": Bootpay.sharedInstance.getApplicationId(),
                    "uuid": Bootpay.sharedInstance.getUUId(),
                    "referer": "",
                    "sk": Bootpay.sharedInstance.getSk(),
                    "user_id": Bootpay.sharedInstance.user.user_id,
                    "url": url,
                    "page_type": page_type,
                    "items": json
                ]
                
                let json = Bootpay.stringify(params)
                do {
                    let aesBody = try json.aesEncrypt(key: Bootpay.sharedInstance.key, iv: Bootpay.sharedInstance.iv)
                    params = [
                        "data": aesBody,
                        "session_key": Bootpay.sharedInstance.getSessionKey()
                    ]
                    post(url: uri, params: params, isLogin: false)
                    
                } catch {}
            }
        } catch {
            NSLog("BootpayStatItem model to json parsing error")
        }
    }
    
    @objc public static func post(url: String, params: [String: Any], isLogin: Bool) {
        let session = URLSession.shared
        let request = NSMutableURLRequest(url: NSURL(string: url)! as URL)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        do{
            let jsonData = try JSONSerialization.data(withJSONObject: params, options: JSONSerialization.WritingOptions())
            request.httpBody = jsonData
            let task = session.dataTask(with: request as URLRequest as URLRequest, completionHandler: {(data, response, error) in
                guard error == nil else { return }
                if isLogin == false { return }
                guard let data = data else { return }
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                        if let data = json["data"] as? [String : Any], let user_id = data["user_id"] as? String {
                            Bootpay.sharedInstance.user.user_id = user_id
                        }
                    }
                } catch let error {
                    print(error.localizedDescription)
                }
            })
            task.resume()
        }catch _ {
            print ("Oops something happened buddy")
        }
    }
}
