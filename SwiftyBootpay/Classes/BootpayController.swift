//
//  BootpayController.swift
//  client_bootpay_swift
//
//  Created by YoonTaesup on 2017. 10. 27..
//  Copyright © 2017년 bootpay.co.kr. All rights reserved.
//

import UIKit
import WebKit

//import Nativ

//import BootpayItem


extension String: LocalizedError {
    public var errorDescription: String? { return self }
}

extension String
{
    func replace(target: String, withString: String) -> String
    {
        return self.replacingOccurrences(of: target, with: withString, options: NSString.CompareOptions.literal, range: nil)
    }
}

extension String {
    subscript (bounds: CountableClosedRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start...end])
    }

    subscript (bounds: CountableRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start..<end])
    }
}

extension URL {
    public var queryItems: [String: Any] {
        var params = [String: Any]()
        return URLComponents(url: self, resolvingAgainstBaseURL: false)?
            .queryItems?
            .reduce([:], { (_, item) -> [String: Any] in
                params[item.name] = item.value
                return params
            }) ?? [:]
    }
}



@objc public class BootpayController: UIViewController {
    @objc public var payload = BootpayPayload()
    @objc public var user = BootpayUser()
    @objc public var extra = BootpayExtra()
    @objc public var items = [BootpayItem]()  
    
//    @objc public var price = Double(0)
//    @objc public var application_id = Bootpay.sharedInstance.getApplicationId()
//    @objc public var name = ""
//    @objc public var pg = ""
//    @objc public var phone = ""
//    @objc public var show_agree_window = 0
//    @objc public var items = [BootpayItem]()
//    @objc public var method = ""
//    @objc public var methods = [String]()
//    @objc public var user_info: [String: String] = [:]
//    @objc public var params: [String: Any] = [:]
//    @objc public var order_id = ""
//    @objc public var use_order_id = 0
//    @objc public var expire_month = 12 // 정기결제 실행 기간
//    @objc public var vbank_result = 1 // 가상계좌 결과창 안보이게 하기
//    @objc public var account_expire_at = "" // 가상계좌 입금 만료 기한
//    @objc public var quotas = [0,2,3,4,5,6,7,8,9,10,11,12] // 할부 개월 수
    var isPaying = false
    @objc public var sendable: BootpayRequestProtocol?
    
    internal var wv: BootpayWebView!
}


extension BootpayController: BootpayParams {
//    @objc(addItem:)
//    public func addItem(item: BootpayItem) {
//        self.request.items.append(item)
//    }
    
    
//    @objc(setBootpayItems:)
//    public func setItems(items: [BootpayItem]) {
//        self.request.items = items
//    }
    
    @objc(transactionConfirm:)
    public func transactionConfirm(data: [String: Any]) {
        let json = Bootpay.dicToJsonString(data).replace(target: "'", withString: "\\'") 
        wv.doJavascript("window.BootPay.transactionConfirm(\(json));")
    }
    
    @objc(removePaymentWindow)
    public func removePaymentWindow() {
        wv.doJavascript("window.BootPay.removePaymentWindow();")
    }
    
    @objc(dismiss)
    public func dismiss() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func isPayingNow() -> Bool {
        return self.isPaying
    }
}

//MARK: Bootpay Data Setting
extension BootpayController {
   
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        self.isPaying = true
        if wv == nil { wv = BootpayWebView() }
        wv.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        
        let script = payload.generateScript(wv.bridgeName, items: items, user: user, extra: extra)
        
        wv.bootpayRequest(script)
        wv.sendable = self.sendable
        wv.parentController = self
        self.view.addSubview(wv)
    }
}


