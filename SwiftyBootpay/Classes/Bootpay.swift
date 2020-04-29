//
//  Bootpay.swift
//  SwiftyBootpay
//
//  Created by YoonTaesup on 2019. 4. 12..
//

import Foundation
import CryptoSwift
import Alamofire
import SwiftUI

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
    
    
    private static func checkValid(payload: BootpayPayload,  user: BootpayUser? = nil, items: [BootpayItem]? = nil, extra: BootpayExtra? = nil, smsPayload: SMSPayload? = nil, remoteForm: RemoteOrderForm? = nil, remotePre: RemoteOrderPre? = nil) -> Bool {
        
        
        return true
    }
    
    
        public static func request(_ viewController: UIViewController, sendable: BootpayRequestProtocol?, payload: BootpayPayload,  user: BootpayUser? = nil, items: [BootpayItem]? = nil, extra: BootpayExtra? = nil, smsPayload: SMSPayload? = nil, remoteForm: RemoteOrderForm? = nil, remotePre: RemoteOrderPre? = nil, addView: Bool? = false, _ gameObject: String = "") {
        
        if(!checkValid(payload: payload, user: user, items: items, extra: extra, smsPayload: smsPayload, remoteForm: remoteForm, remotePre: remotePre)) { return }
        
        switch payload.ux {
        case UX.PG_DIALOG:
            request_dialog(viewController, sendable: sendable, payload: payload, user: user, items: items, extra: extra, smsPayload: smsPayload, addView: addView)
        case UX.PG_SUBSCRIPT:
            request_dialog(viewController, sendable: sendable, payload: payload, user: user, items: items, extra: extra, smsPayload: smsPayload)
//        case UX.BOOTPAY_REMOTE_LINK:
//            request_link(payload, items: items, user: user, extra: extra, smsPayload: smsPayload)
        case UX.BOOTPAY_REMOTE_FORM:
            request_form(payload, user: user, items: items, extra: extra, smsPayload: smsPayload, remoteForm: remoteForm)
        case UX.BOOTPAY_REMOTE_PRE:
            request_pre(payload, user: user, items: items, extra: extra, smsPayload: smsPayload, remotePre: remotePre)
        default:
            return
        }
    }
    
    private static func request_dialog(_ viewController: UIViewController, sendable: BootpayRequestProtocol?, payload: BootpayPayload,  user: BootpayUser? = nil, items: [BootpayItem]? = nil, extra: BootpayExtra? = nil, smsPayload: SMSPayload? = nil, addView: Bool? = false) {
        
//        sharedInstance.vc.request = request
//        if let user = user { sharedInstance.vc.user = user }
//        if let extra = extra { sharedInstance.vc.extra = extra }
//        if let sendable = sendable { sharedInstance.vc.sendable = sendable }
//        if let items = items { sharedInstance.vc.items = items }
//        viewController.present(sharedInstance.vc, animated: true, completion: nil)
//        if sharedInstance.vc == nil {
//            sharedInstance.vc = BootpayController()
//        }
        sharedInstance.vc = BootpayController() 
        
        sharedInstance.vc?.payload = payload
        if(payload.application_id.isEmpty) { sharedInstance.vc?.payload.application_id = sharedInstance.application_id }
         
        
        if let user = user { sharedInstance.vc?.user = user }
        if let extra = extra { sharedInstance.vc?.extra = extra }
        if let sendable = sendable { sharedInstance.vc?.sendable = sendable }
        if let items = items { sharedInstance.vc?.items = items }
        if (addView == true) {
            viewController.view.addSubview(sharedInstance.vc!.view)
        } else {
            viewController.modalPresentationStyle = .fullScreen
            viewController.present(sharedInstance.vc!, animated: true, completion: nil)
        }
    }
    
//    private static func request_link(_ payload: BootpayPayload, items: [BootpayItem]?, user: BootpayUser?, extra: BootpayExtra?, smsPayload: SMSPayload?) {
//        
//        let requestString = payload.toJSONString() ?? ""
//        let itemsString = items?.toJSONString() ?? ""
//        let userString = user?.toJSONString() ?? ""
//        let extraString = extra?.toJSONString() ?? ""
//        let smsPayloadString = smsPayload?.toJSONString() ?? ""
//        
//        var params = jsonStringToDic(requestString) ?? [:]
//        params["items"] = itemsString
//        params["user_info"] = userString
//        params["params"] = extraString
//        params["sms_payload"] = smsPayloadString
//        
////        Alamofire.Request
//        
//        AF.request("https://api.bootpay.co.kr/app/rest/remote_link", method: .post, parameters: params)
//            .validate()
//            .responseJSON { response in
//                print(response.value ?? "")
//        }
//    }
    
    private static func request_form(_ payload: BootpayPayload, user: BootpayUser?, items: [BootpayItem]?, extra: BootpayExtra?, smsPayload: SMSPayload?, remoteForm: RemoteOrderForm?) {
        
        let requestString = payload.toJSONString() ?? ""
        let itemsString = items?.toJSONString() ?? ""
        let userString = user?.toJSONString() ?? ""
        let extraString = extra?.toJSONString() ?? ""
        let smsPayloadString = smsPayload?.toJSONString() ?? ""
        var remoteFormString = remoteForm?.toJSONString() ?? ""
        if remoteFormString.count == 0 {
            let form = RemoteOrderForm()
            form.params {
                $0.n = payload.name
                $0.ip = payload.price
                $0.pg = payload.pg
            }
            remoteFormString = form.toJSONString() ?? ""
        }
        
        var params = jsonStringToDic(requestString) ?? [:]
        params["items"] = itemsString
        params["user_info"] = userString
        params["params"] = extraString
        params["sms_payload"] = smsPayloadString
        params["remote_form"] = remoteFormString
        
        AF.request("https://api-ehowlsla.bootpay.co.kr/app/rest/remote_form", method: .post, parameters: params)
            .validate()
            .responseJSON { response in
                print(response.value ?? "")
        }
    }
    
    public static func request_pre(_ payload: BootpayPayload, user: BootpayUser?, items: [BootpayItem]?, extra: BootpayExtra?, smsPayload: SMSPayload?, remotePre: RemoteOrderPre?) {
        
        let requestString = payload.toJSONString() ?? ""
        let itemsString = items?.toJSONString() ?? ""
        let userString = user?.toJSONString() ?? ""
        let extraString = extra?.toJSONString() ?? ""
        let smsPayloadString = smsPayload?.toJSONString() ?? ""
        var remotePreString = remotePre?.toJSONString() ?? ""
        if remotePreString.count == 0 {
            let pre = RemoteOrderPre()
            pre.params {
                $0.n = payload.name
                $0.e_p = "\(payload.price)"
            }
            remotePreString = pre.toJSONString() ?? ""
        }
        
        var params = jsonStringToDic(requestString) ?? [:]
        params["items"] = itemsString
        params["user_info"] = userString
        params["params"] = extraString
        params["sms_payload"] = smsPayloadString
        params["remote_pre"] = remotePreString
        
        AF.request("https://api-ehowlsla.bootpay.co.kr/app/rest/remote_pre", method: .post, parameters: params)
            .validate()
            .responseJSON { response in
                print(response.value ?? "")
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
    @objc public var vc: BootpayController?
    
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


//MARK: Bootpay LifeCycle For Analytics
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
    
    @objc(transactionConfirm:)
    public static func transactionConfirm(data: [String: Any]) {
        sharedInstance.vc?.transactionConfirm(data: data)
    }
    
    @objc(removePaymentWindow)
    public static func removePaymentWindow() {
           sharedInstance.vc?.removePaymentWindow()
    }
    
    @objc(dismiss)
    public static func dismiss() {
        sharedInstance.vc?.dismiss()
        sharedInstance.vc?.view.removeFromSuperview()
    }
    
    
    //for unity
    @objc(request_objc:::::::::)
    public static func request_objc(_ viewController: UIViewController, sendable: BootpayRequestProtocol?, payload: BootpayPayload,  user: BootpayUser? = nil, items: [BootpayItem]? = nil, extra: BootpayExtra? = nil, smsPayload: SMSPayload? = nil, remoteForm: RemoteOrderForm? = nil, remotePre: RemoteOrderPre? = nil) {
        
        request(viewController, sendable: sendable, payload: payload, user: user, items: items, extra: extra, smsPayload: smsPayload, addView: false) 
    }
    
   
    
    
     @objc(request_objc_json:::::::)
     public static func request_objc(_ viewController: UIViewController, sendable: BootpayRequestProtocol?, payload: String,  user: String, items: String, extra: String, _ gameObject: String) {

        guard let payload = BootpayPayload(JSONString: payload) else { return }
        guard let user = BootpayUser(JSONString: user) else { return }


//        let items = BootpayUser(JSONString: user)
        guard let extra = BootpayExtra(JSONString: extra) else { return }
        do {
          let items = try JSONDecoder().decode([BootpayItem].self, from: items.data(using: .utf8)!)
            request(viewController, sendable: sendable, payload: payload, user: user, items: items, extra: extra, smsPayload: nil, addView: true, gameObject)

        } catch let error as NSError {
//            print(error)
            request(viewController, sendable: sendable, payload: payload, user: user, items: nil, extra: extra, smsPayload: nil, addView: true, gameObject)
        }
     }
    
//    @objc(request_objc_json:::::::)
//    public static func request_objc(_ viewController: UIViewController, sendable: BootpayRequestProtocol?, payload: String,  user: String, items: String, extra: String, gameObject: String) {
//
//        guard let payload = BootpayPayload(JSONString: payload) else { return }
//        guard let user = BootpayUser(JSONString: user) else { return }
//
//
////        let items = BootpayUser(JSONString: user)
//        guard let extra = BootpayExtra(JSONString: extra) else { return }
//        do {
//          let items = try JSONDecoder().decode([BootpayItem].self, from: items.data(using: .utf8)!)
//            request(viewController, sendable: sendable, payload: payload, user: user, items: items, extra: extra, smsPayload: nil, addView: false, gameObject)
//
//        } catch let error as NSError {
////            print(error)
//            request(viewController, sendable: sendable, payload: payload, user: user, items: nil, extra: extra, smsPayload: nil, addView: false, gameObject)
//        }
//    }
}
