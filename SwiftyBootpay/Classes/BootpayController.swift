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
     
    var isPaying = false
    @objc public var sendable: BootpayRequestProtocol?
//    @objc public weak var sendable: BootpayRequestProtocol?
    
    internal var wv: BootpayWebView!
}


extension BootpayController: BootpayParams {
    
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
        
//        let rootViewController = UIApplication.shared.keyWindow?.rootViewController
//        rootViewController?.present(UIViewController(), animated: true, completion: nil)
        
        self.isPaying = true
        if wv == nil { wv = BootpayWebView() }
         
        
        if #available(iOS 11.0, *) {
//            print(self.view.safeAreaInsets.bottom)

            let window = UIApplication.shared.keyWindow
            let topPadding = window?.safeAreaInsets.top ?? 0.0
            let bottomPadding = window?.safeAreaInsets.bottom ?? 0.0
            
            wv.frame = CGRect(x: 0, y: topPadding, width: self.view.frame.width, height: self.view.frame.height - topPadding - bottomPadding)
//            wv.frame = CGRect(x: self.view.safeAreaInsets.left, y: self.view.safeAreaInsets.top, width: self.view.safeAreaInsets.right, height: self.view.safeAreaInsets.bottom)
        } else {
            wv.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
            // Fallback on earlier versions
        }
        
        let script = payload.generateScript(wv.bridgeName, items: items, user: user, extra: extra)
        
        wv.bootpayRequest(script)
        wv.sendable = self.sendable
        wv.parentController = self
        self.view.addSubview(wv) 
    }
}


