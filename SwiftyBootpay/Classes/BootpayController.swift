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
    @objc public var ux = ""
    @objc public var items = [BootpayItem]()
    @objc public var isModalButNoFullScreen = false //팝업이긴 하지만 풀 스크린이 아닐 경우
     
    var isPaying = false
    @objc public var sendable: BootpayRequestProtocol?
//    @objc public weak var sendable: BootpayRequestProtocol?
    
    internal var wv: BootpayWebView!
}


extension BootpayController: BootpayParams {
    
    @objc(didBecomeActive)
    public func didBecomeActive() {
        wv.didBecomeActive()
    }
    
    @objc(transactionConfirm:)
    public func transactionConfirm(data: [String: Any]) {
        let json = Bootpay.dicToJsonString(data).replace(target: "'", withString: "\\'") 
        wv.doJavascript("window.BootPay.transactionConfirm(\(json));")
    }
    
    @objc(removePaymentWindow)
    public func removePaymentWindow() {
        wv.doJavascript("window.BootPay.removePaymentWindow();")
        dismiss()
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
            
        var topPadding = CGFloat(0.0)
        var bottomPadding = CGFloat(0.0)
        var btnMarginTop = CGFloat(0.0)
        if(extra.iosCloseButton) {
            btnMarginTop = 20.0
        }
        
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.keyWindow
            topPadding = window?.safeAreaInsets.top ?? 0.0
            bottomPadding = window?.safeAreaInsets.bottom ?? 0.0
        }
        if(isModalButNoFullScreen == true) { topPadding = CGFloat(0) }
        
     
        
        wv.frame = CGRect(x: 0,
                          y: topPadding + btnMarginTop,
                          width: self.view.frame.width,
                          height: self.view.frame.height - topPadding - bottomPadding - btnMarginTop
        )
        
        let script = payload.generateScript(wv.bridgeName, items: items, user: user, extra: extra, isPasswordPay: false)
        
        
        
        // 필요한 PG는 팝업으로 띄운다
        var quick_popup = extra.quick_popup;
        if(quick_popup == -1 && payload.pg != "payapp" && payload.method == "card") {
            quick_popup = 1;
        }

        if(quick_popup == 1) {
            wv.bootpayRequest(script, quick_popup: quick_popup)
        } else {
            wv.bootpayRequest(script)
        }
        
        wv.sendable = self.sendable
        wv.parentController = self
        self.view.addSubview(wv)
        
        if(extra.iosCloseButton) {
            if(extra.iosCloseButtonView == nil) {
                let close = UIButton()
                close.setTitle("X", for: .normal)
                close.addTarget(self, action: #selector(removePaymentWindow), for: .touchUpInside)
                close.frame = CGRect(x: self.view.frame.width - 40, y: topPadding, width: 40, height: 30)
                close.setTitleColor(.darkGray, for: .normal)
                self.view.addSubview(close)
            } else {
                extra.iosCloseButtonView!.addTarget(self, action: #selector(removePaymentWindow), for: .touchUpInside)
                if(extra.iosCloseButtonView!.frame == CGRect.null) { extra.iosCloseButtonView!.frame = CGRect(x: self.view.frame.width - 40, y: topPadding, width: 40, height: 30) }
                self.view.addSubview(extra.iosCloseButtonView!)
            }
        }
    }
}


