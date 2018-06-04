//
//  BootpayAnalytics.swift
//  client_bootpay_swift
//
//  Created by YoonTaesup on 2017. 10. 27..
//  Copyright © 2017년 bootpay.co.kr. All rights reserved.
//
import Foundation

//MARK: UserDefault Standard For Session
class BootpayDefault {
    static func getInt(key: String) -> Int {
        return UserDefaults.standard.integer(forKey: key)
    }
    
    static func getString(key: String) -> String {
        guard let value = UserDefaults.standard.string(forKey: key) else { return "" }
        return value
    }
    
    static func setValue(_ key: String, value: Any) {
        UserDefaults.standard.set(value, forKey: key)
    }
}

//MARK: Bootpay Models
public class BootpayUser: Params {
    public init() {}
    var user_id = ""
    
    public var id = ""
    public var username = ""
    public var email = ""
    public var gender = 0
    public var birth = ""
    public var phone = ""
    public var area = ""
}

public class BootpayAnalytics {
    public init() {}
    
    public static let sharedInstance = BootpayAnalytics()
    var application_id = ""
    public var uuid = ""
    var sk = ""
    var sk_time = 0 // session 유지시간 기본 30분
    var last_time = 0 // 접속 종료 시간
    var time = 0 // 미접속 시간
    public var user = BootpayUser()
}

extension BootpayAnalytics {
    open func getApplicationId() -> String {
        if self.application_id == "" { return BootpayDefault.getString(key: "application_id") }
        return self.application_id
    }
    
    open func getUuId() -> String {
        if self.uuid == "" { return BootpayDefault.getString(key: "uuid") }
        return self.uuid
    }
    
    open func getSk() -> String {
        if self.sk == "" { return BootpayDefault.getString(key: "sk") }
        return self.sk
    }
    
    open func getSkTime() -> Int {
        if self.sk_time == 0 { return BootpayDefault.getInt(key: "sk_time") }
        return self.sk_time
    }
}

//MARK: Bootpay Model Update
extension BootpayAnalytics {    
    fileprivate func loadSessionValues() {
        loadUuid()
        loadSkTime()
    }
    
    fileprivate func loadUuid() {
        self.uuid = BootpayDefault.getString(key: "uuid")
        if uuid == "" {
            self.uuid = UUID().uuidString
            BootpayDefault.setValue("uuid", value: self.uuid)
        }
    }
    
    fileprivate func loadLastTime() {
        self.last_time = BootpayDefault.getInt(key: "last_time")
    }
    
    fileprivate func loadSkTime() {
        func updateSkTime(time: Int) {
            self.sk_time = time
            self.sk = "\(uuid)_\(self.sk_time)"
            BootpayDefault.setValue("sk", value: sk)
            BootpayDefault.setValue("sk_time", value: sk_time)
        }
        
        loadLastTime()
        let currentTime = currentTimeInMiliseconds()
        if self.last_time != 0 && Swift.abs(self.last_time - currentTime) >= 30 * 60 * 1000 {
            self.time = currentTime - self.last_time
            self.last_time = currentTime
            BootpayDefault.setValue("last_time", value: self.last_time)
            updateSkTime(time: currentTime)
        } else if self.sk_time == 0 {
            updateSkTime(time: currentTime)
        }
    }
    
    fileprivate func currentTimeInMiliseconds() -> Int {
        let currentDate = Date()
        let since1970 = currentDate.timeIntervalSince1970
        return Int(since1970 * 1000)
    }
}

//MARK: Bootpay LifeCycle Fpr Analytics
extension BootpayAnalytics {
    open func appLaunch(application_id: String) {
        HTTPCookieStorage.shared.cookieAcceptPolicy = HTTPCookie.AcceptPolicy.always
        self.application_id = application_id
        BootpayDefault.setValue("application_id", value: self.application_id)
    }
    
    open func sessionActive(active: Bool) {
        if active == true {
            loadSessionValues()
        } else {
            let currentTime = currentTimeInMiliseconds()
            self.last_time = currentTime
            BootpayDefault.setValue("last_time", value: self.last_time)
        }
    }
}

//MARK: Bootpay Rest Api for Analytics
extension BootpayAnalytics {
    open func postLogin(id: String, email: String, gender: Int,
                        birth: String, phone: String, area: String) {
        var components = URLComponents(string: "https://analytics.bootpay.co.kr/login")
        components?.queryItems = [
            URLQueryItem(name: "application_id", value: getApplicationId()),
            URLQueryItem(name: "id", value: id),
            URLQueryItem(name: "email", value: email),
            URLQueryItem(name: "gender", value: "\(gender)"),
            URLQueryItem(name: "birth", value: birth),
            URLQueryItem(name: "phone", value: phone),
            URLQueryItem(name: "area", value: area)
        ]
        
        if BootpayAnalytics.sharedInstance.user.id == "" { BootpayAnalytics.sharedInstance.user.id = id }
        if BootpayAnalytics.sharedInstance.user.email == "" { BootpayAnalytics.sharedInstance.user.email = email }
        if BootpayAnalytics.sharedInstance.user.gender == 0 { BootpayAnalytics.sharedInstance.user.gender = gender }
        if BootpayAnalytics.sharedInstance.user.birth == "" { BootpayAnalytics.sharedInstance.user.birth = birth }
        if BootpayAnalytics.sharedInstance.user.phone == "" { BootpayAnalytics.sharedInstance.user.phone = phone }
        if BootpayAnalytics.sharedInstance.user.area == "" { BootpayAnalytics.sharedInstance.user.area = area }
        
        post(components: components, isLogin: true)
    }
    
    open func postLogin() {
        if(BootpayAnalytics.sharedInstance.user.id == "") {
            NSLog("Bootpay Analytics Warning: postLogin() not Work!! Please check id is not empty")
            return
        }
        postLogin(id: BootpayAnalytics.sharedInstance.user.id,
                  email: BootpayAnalytics.sharedInstance.user.email,
                  gender: BootpayAnalytics.sharedInstance.user.gender,
                  birth: BootpayAnalytics.sharedInstance.user.birth,
                  phone: BootpayAnalytics.sharedInstance.user.phone,
                  area: BootpayAnalytics.sharedInstance.user.area)
    }
    
    open func postCall(url: String, page_type: String, img_url: String, item_unique: String, item_name: String) { 
        var components = URLComponents(string: "https://analytics.bootpay.co.kr/call")
        components?.queryItems = [
            URLQueryItem(name: "application_id", value: getApplicationId()),
            URLQueryItem(name: "uuid", value: getUuId()),
            URLQueryItem(name: "referer", value: ""),
            URLQueryItem(name: "url", value: url),
            URLQueryItem(name: "sk", value: getSk()),
            URLQueryItem(name: "user_id", value: BootpayAnalytics.sharedInstance.user.user_id),
            URLQueryItem(name: "page_type", value: page_type),
            URLQueryItem(name: "img", value: img_url),
            URLQueryItem(name: "unique", value: item_unique),
            URLQueryItem(name: "item_name", value: item_name)
        ]
        post(components: components, isLogin: false)
    }
    
    open func post(components: URLComponents?, isLogin: Bool) {
        guard let url = components?.url else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            guard error == nil else { return }
            if isLogin == false { return }
            guard let data = data else { return }
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] { 
                    if let data = json["data"] as? [String : Any], let user_id = data["user_id"] as? String { 
                        BootpayAnalytics.sharedInstance.user.user_id = user_id
                    }
                }
            } catch let error {
                print(error.localizedDescription)
            }
        })
        task.resume()
    }
}
