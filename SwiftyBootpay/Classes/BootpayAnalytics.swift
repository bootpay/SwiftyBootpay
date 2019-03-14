//
//  BootpayAnalytics.swift
//  client_bootpay_swift
//
//  Created by YoonTaesup on 2017. 10. 27..
//  Copyright © 2017년 bootpay.co.kr. All rights reserved.
//
import Foundation
import CryptoSwift

extension String {
    subscript (i: Int) -> Character {
        return self[index(startIndex, offsetBy: i)]
    }
    
    func aesEncrypt(key: String, iv: String) throws -> String {
        let data = self.data(using: .utf8)!
        let encrypted = try! AES(key: key.bytes, blockMode: CBC(iv: iv.bytes), padding: .pkcs7).encrypt([UInt8](data))
        let encryptedData = Data(encrypted)
        return encryptedData.base64EncodedString()
    }
    
    func aesDecrypt(key: String, iv: String) throws -> String {
        let data = Data(base64Encoded: self)!
        let decrypted = try! AES(key: key.bytes, blockMode: CBC(iv: iv.bytes), padding: .pkcs7).decrypt([UInt8](data))
        let decryptedData = Data(decrypted)
        return String(bytes: decryptedData.bytes, encoding: .utf8) ?? "Could not decrypt"
    }
    
    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }
        
        return String(data: data, encoding: .utf8)
    }
    
    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }
}



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
public class BootpayUser: NSObject, Params {
    public override init() {}
    var user_id = ""
    
    @objc public var id = ""
    @objc public var username = ""
    @objc public var email = ""
    @objc public var gender = 0
    @objc public var birth = ""
    @objc public var phone = ""
    @objc public var area = ""
}


public class BootpayAnalytics: NSObject {
    public override init() {
        super.init()
        self.key = getRandomKey(32)
        self.iv = getRandomKey(16)
    }
    
    @objc public static let sharedInstance = BootpayAnalytics()
    var application_id = ""
    public var uuid = ""
    let ver = "2.1.18"
    var sk = ""
    var sk_time = 0 // session 유지시간 기본 30분
    var last_time = 0 // 접속 종료 시간
    var time = 0 // 미접속 시간
    @objc public var user = BootpayUser()
    
    var key = ""
    var iv = ""
}

public class BootpayStatItem: NSObject, Codable, Params {
    public override init() {}
    
    @objc public var item_name = ""
    @objc public var item_img = ""
    @objc public var unique = ""
    @objc public var cat1 = ""
    @objc public var cat2 = ""
    @objc public var cat3 = ""
}

extension BootpayAnalytics {
    open func getApplicationId() -> String {
        if self.application_id == "" { return BootpayDefault.getString(key: "application_id") }
        return self.application_id
    }
    
    open func getUUId() -> String {
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
    
    
    fileprivate func getRandomKey(_ size: Int) -> String {
        let keys = "abcdefghijklmnopqrstuvwxyz1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ";
        var result = ""
        for i in 0..<size {
            let ran = Int(arc4random_uniform(UInt32(keys.count)))
            let index = keys.index(keys.startIndex, offsetBy: ran)
            result += String(keys[index])
        }
        return result
    }
    
    fileprivate func getSessionKey() -> String {
        return "\(self.key.toBase64())##\(self.iv.toBase64())"
    }
    
    fileprivate func stringify(_ json: Any, prettyPrinted: Bool = false) -> String {
        var options: JSONSerialization.WritingOptions = []
        if prettyPrinted {
            options = JSONSerialization.WritingOptions.prettyPrinted
        }
        
        do {
            let data = try JSONSerialization.data(withJSONObject: json, options: options)
            if let string = String(data: data, encoding: String.Encoding.utf8) {
                return string
            }
        } catch {
            print(error)
        }
        
        return ""
    }
}


//MARK: Bootpay LifeCycle Fpr Analytics
extension BootpayAnalytics {
    @objc(appLaunch:)
    open func appLaunch(application_id: String) {
        HTTPCookieStorage.shared.cookieAcceptPolicy = HTTPCookie.AcceptPolicy.always
        self.application_id = application_id
        BootpayDefault.setValue("application_id", value: self.application_id)
    }
    
    @objc(sessionActive:)
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
        if BootpayAnalytics.sharedInstance.user.id == "" { BootpayAnalytics.sharedInstance.user.id = id }
        if BootpayAnalytics.sharedInstance.user.email == "" { BootpayAnalytics.sharedInstance.user.email = email }
        if BootpayAnalytics.sharedInstance.user.gender == 0 { BootpayAnalytics.sharedInstance.user.gender = gender }
        if BootpayAnalytics.sharedInstance.user.birth == "" { BootpayAnalytics.sharedInstance.user.birth = birth }
        if BootpayAnalytics.sharedInstance.user.phone == "" { BootpayAnalytics.sharedInstance.user.phone = phone }
        if BootpayAnalytics.sharedInstance.user.area == "" { BootpayAnalytics.sharedInstance.user.area = area }
        
        let uri = "https://analytics.bootpay.co.kr/login"
        var params: [String: Any]
        params = [
            "ver": ver,
            "application_id": getApplicationId(),
            "id": id,
            "email": email,
            "gender": "\(gender)",
            "birth": birth,
            "phone": phone,
            "area": area
        ]
        
        let json = stringify(params)
        do {
            let aesBody = try json.aesEncrypt(key: self.key, iv: self.iv)
            params = [
                "data": aesBody,
                "session_key": self.getSessionKey()
            ]
            post(url: uri, params: params, isLogin: true)
            
        } catch {}
    }
    
    @objc public func postLogin() {
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
    
    @objc public func start(_ url: String, _ page_type: String) {
        start(url, page_type, items: [])
    }
    
    @objc public func start(_ url: String, _ page_type: String, items: [BootpayStatItem]) {
        let uri = "https://analytics.bootpay.co.kr/call"
        var params: [String: Any]
        
        do {
            let jsonEncoder = JSONEncoder()
            let jsonData = try jsonEncoder.encode(items)
            let json = String(data: jsonData, encoding: String.Encoding.utf8)
            
            if let json = json {
                params = [
                    "ver": ver,
                    "application_id": getApplicationId(),
                    "uuid": getUUId(),
                    "referer": "",
                    "sk": getSk(),
                    "user_id": BootpayAnalytics.sharedInstance.user.user_id,
                    "url": url,
                    "page_type": page_type,
                    "items": json
                ]
                
                let json = stringify(params)
                do {
                    let aesBody = try json.aesEncrypt(key: self.key, iv: self.iv)
                    params = [
                        "data": aesBody,
                        "session_key": self.getSessionKey()
                    ]
                    post(url: uri, params: params, isLogin: false)
                    
                } catch {}
            }
        } catch {
            NSLog("BootpayStatItem model to json parsing error")
        }
    }
    
    @objc public func post(url: String, params: [String: Any], isLogin: Bool) {
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
                            BootpayAnalytics.sharedInstance.user.user_id = user_id
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
