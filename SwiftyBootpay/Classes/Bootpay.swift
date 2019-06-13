//
//  Bootpay.swift
//  SwiftyBootpay
//
//  Created by YoonTaesup on 2019. 4. 12..
//

import Foundation
import CryptoSwift
import Alamofire

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

@objc public class Bootpay: NSObject {
    public static func dicToJsonString(_ data: [String: Any]) -> String {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
            let jsonStr = String(data: jsonData, encoding: .utf8)
            if let jsonStr = jsonStr {
                return jsonStr
            }
            return ""
        } catch {
            print(error.localizedDescription)
            return ""
        }
    }
    
    public static func jsonStringToDic(_ text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    public static func request_link(_ request: BootpayRequest, items: [BootpayItem]?, user: BootpayUser?, extra: BootpayExtra?, smsPayload: SMSPayload?) {
        
        let requestString = request.toJSONString() ?? ""
        let itemsString = items?.toJSONString() ?? ""
        let userString = user?.toJSONString() ?? ""
        let extraString = extra?.toJSONString() ?? ""
        let smsPayloadString = smsPayload?.toJSONString() ?? ""
        
        var params = jsonStringToDic(requestString) ?? [:]
        params["items"] = itemsString
        params["user_info"] = userString
        params["params"] = extraString
        params["sms_payload"] = smsPayloadString
        
        Alamofire.request("https://api-ehowlsla.bootpay.co.kr/app/rest/remote_link", method: .post, parameters: params)
            .validate()
            .responseJSON { response in
                print(response.result.value ?? "")
        }
    }
    
    public static func request_form(_ request: BootpayRequest, items: [BootpayItem]?, user: BootpayUser?, extra: BootpayExtra?, smsPayload: SMSPayload?, remoteForm: RemoteOrderForm?) {
        
        let requestString = request.toJSONString() ?? ""
        let itemsString = items?.toJSONString() ?? ""
        let userString = user?.toJSONString() ?? ""
        let extraString = extra?.toJSONString() ?? ""
        let smsPayloadString = smsPayload?.toJSONString() ?? ""
        var remoteFormString = remoteForm?.toJSONString() ?? ""
        if remoteFormString.count == 0 {
            let form = RemoteOrderForm()
            form.params {
                $0.n = request.name
                $0.ip = request.price
                $0.pg = request.pg
            }
            remoteFormString = form.toJSONString() ?? ""
        }
        
        var params = jsonStringToDic(requestString) ?? [:]
        params["items"] = itemsString
        params["user_info"] = userString
        params["params"] = extraString
        params["sms_payload"] = smsPayloadString
        params["remote_form"] = remoteFormString
        
        Alamofire.request("https://api-ehowlsla.bootpay.co.kr/app/rest/remote_form", method: .post, parameters: params)
            .validate()
            .responseJSON { response in
                print(response.result.value ?? "")
        }
    }
    
    public static func request_pre(_ request: BootpayRequest, items: [BootpayItem]?, user: BootpayUser?, extra: BootpayExtra?, smsPayload: SMSPayload?, remotePre: RemoteOrderPre?) {
        
        let requestString = request.toJSONString() ?? ""
        let itemsString = items?.toJSONString() ?? ""
        let userString = user?.toJSONString() ?? ""
        let extraString = extra?.toJSONString() ?? ""
        let smsPayloadString = smsPayload?.toJSONString() ?? ""
        var remotePreString = remotePre?.toJSONString() ?? ""
        if remotePreString.count == 0 {
            let pre = RemoteOrderPre()
            pre.params {
                $0.n = request.name
                $0.e_p = "\(request.price)"
//                $0.pg = request.pg
            }
            remotePreString = pre.toJSONString() ?? ""
        }
        
        var params = jsonStringToDic(requestString) ?? [:]
        params["items"] = itemsString
        params["user_info"] = userString
        params["params"] = extraString
        params["sms_payload"] = smsPayloadString
        params["remote_pre"] = remotePreString
        
        Alamofire.request("https://api-ehowlsla.bootpay.co.kr/app/rest/remote_pre", method: .post, parameters: params)
            .validate()
            .responseJSON { response in
                print(response.result.value ?? "")
        }
    }

    
    public override init() {
        super.init()
        self.key = getRandomKey(32)
        self.iv = getRandomKey(16)
    }
    
    @objc public static let sharedInstance = Bootpay()
    var application_id = ""
    public var uuid = ""
    let ver = "3.0.4"
    var sk = ""
    var sk_time = 0 // session 유지시간 기본 30분
    var last_time = 0 // 접속 종료 시간
    var time = 0 // 미접속 시간
    @objc public var user = BootpayUser()
    
    var key = ""
    var iv = ""
    
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
extension Bootpay {
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
            BootpayDefault.setValue("time", value: self.time)
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
        for _ in 0..<size {
            let ran = Int(arc4random_uniform(UInt32(keys.count)))
            let index = keys.index(keys.startIndex, offsetBy: ran)
            result += String(keys[index])
        }
        return result
    }
    
    func getSessionKey() -> String {
        return "\(self.key.toBase64())##\(self.iv.toBase64())"
    }
    
    static func stringify(_ json: Any, prettyPrinted: Bool = false) -> String {
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
extension Bootpay {
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
