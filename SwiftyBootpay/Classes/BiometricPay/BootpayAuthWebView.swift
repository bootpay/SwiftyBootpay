//
//  BootpayAuthWebView.swift
//  Alamofire
//
//  Created by Taesup Yoon on 12/10/2020.
//

import UIKit
import WebKit

@objc public protocol BootpayAuthProtocol { 
    
    @objc(easyCancel:) func easyCancel(data: [String: Any])
    @objc(easyError:) func easyError(data: [String: Any])
    @objc(easySuccess:) func easySuccess(data: [String: Any])
}


@objc class BootpayAuthWebView: UIView {
    var wv: WKWebView!
    
    public static let REQUEST_TYPE_VERIFY_PASSWORD = 1 // 생체인식 활성화용도
    public static let REQUEST_TYPE_VERIFY_PASSWORD_FOR_PAY = 2 //비밀번호로 결제 용도
    public static let REQUEST_TYPE_REGISTER_CARD = 3 //카드 생성
    public static let REQUEST_TYPE_PASSWORD_CHANGE = 4 //카드 삭제
    public static let REQUEST_TYPE_ENABLE_DEVICE = 5 //해당 기기 활성화
    
    public static let REQUEST_TYPE_ENABLE_OTHER = 6 //통합결제
    public static let REQUEST_TYPE_PASSWORD_PAY = 7 //카드 간편결제 (비밀번호) - 생체인증 정보가 기기에 없을때
    
    
    
    
    public var request_type = BootpayAuthWebView.REQUEST_TYPE_VERIFY_PASSWORD
    
    final let BASE_URL = Bootpay.URL
    final let bridgeName = "Bootpay_iOS"
    var userToken = ""
    var firstLoad = false
    var sendable: BootpayAuthProtocol?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        
        HTTPCookieStorage.shared.cookieAcceptPolicy = HTTPCookie.AcceptPolicy.always  // 현대카드 등 쿠키설정 이슈 해결을 위해 필요
        let configuration = WKWebViewConfiguration()
        configuration.userContentController.add(self, name: bridgeName)
        wv = WKWebView(frame: frame, configuration: configuration)
//        wv.
        wv.uiDelegate = self
        wv.navigationDelegate = self
        self.addSubview(wv)
    }
       
   
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadFirst() {
        wv.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
//            WKWebView(frame: CGRect(x: 0, y: 0, width: 200, height: 300), configuration: configuration)
        self.loadUrl(BASE_URL)
   }
}

extension BootpayAuthWebView {
    
    
    internal func doJavascript(_ script: String) {
        if(script == "" ) { return }
        wv.evaluateJavaScript(script, completionHandler: nil)
    }
    
    internal func loadUrl(_ urlString: String) {
        let url = URL(string: urlString)
        if let url = url {
            let request = URLRequest(url: url)
            wv.load(request)
        }
    }
    
    func registerAppId() {
//        let app_id = "5b8f6a4d396fa665fdc2b5e9"
//        let app_id = "5b9f51264457636ab9a07cdd"
        doJavascript("window.BootPay.setApplicationId('\(Bootpay.sharedInstance.application_id)');")
    }
    
    func setDevelopMode() {
        doJavascript("window.BootPay.setMode('development');")
    }
    
    internal func setDevice() {
        doJavascript("window.BootPay.setDevice('IOS');")
    }
    
    internal func setAnalytics() {
        if Bootpay.sharedInstance.sk_time == 0 {
            NSLog("Bootpay Analytics Warning: setAnalytics() not Work!! Please session active in AppDelegate")
            return
        }
        
        doJavascript("window.BootPay.setAnalyticsData({"
            + "sk: '\(Bootpay.sharedInstance.sk)', "
            + "sk_time: \(Bootpay.sharedInstance.sk_time), "
            + "uuid: '\(Bootpay.sharedInstance.uuid)'"
            + "});")
    }
}

extension BootpayAuthWebView: WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler  {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if firstLoad == false {
        
            firstLoad = true
            registerAppId()
//            setDevelopMode()
            setDevice()
            setAnalytics() 
        }
    }
    
     
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if(message.name == self.bridgeName) {
            guard let body = message.body as? [String: Any] else { return }
            guard let action = body["action"] as? String else { return }
            
            
            if action == "BootpayEasyCancel" {
                //결제수단 등록 취소
                sendable?.easyCancel(data: body)
            } else if action == "BootpayEasyError" {
                //결제수단 등록 실패
                sendable?.easyError(data: body)
            } else if action == "BootpayEasySuccess" {
                //결제수단 등록 완료
                sendable?.easySuccess(data: body)
            }
        }
    }
   
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Swift.Void) {
        if(challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust) {
            let cred = URLCredential(trust: challenge.protectionSpace.serverTrust!)
            completionHandler(.useCredential, cred)
        } else {
            completionHandler(.performDefaultHandling, nil)
        }
    }
}


//verifyPassword
extension BootpayAuthWebView {
    
    func verifyPasswordScript() -> String {
        if userToken == "" {
            print("userToken이 없습니다")
            return ""
        }
        
        var msg = "이 기기에서 Touch ID 결제를 활성화합니다"
        if(request_type == BootpayAuthWebView.REQUEST_TYPE_VERIFY_PASSWORD_FOR_PAY) { msg = "비밀번호 입력방식으로 결제를 진행합니다" }
        
        let array = [
            "BootPay.verifyPassword({",
            "userToken: '\(self.userToken)',",
            "deviceId: '\(Bootpay.getUUID())',",
                "message: '\(msg)'",
            "}).easyCancel(function (data) {",
            "webkit.messageHandlers.\(self.bridgeName).postMessage(data);",
            "}).easyError(function (data) {",
            "webkit.messageHandlers.\(self.bridgeName).postMessage(data);",
            "}).easySuccess(function (data) {",
            "console.log(1234);",
            "webkit.messageHandlers.\(self.bridgeName).postMessage(data);",
            "});"
        ]
        return array.reduce("", +)
    }
    
    func verifyPassword() {
//        self.request_type = BootpayAuthWebView.REQUEST_TYPE_VERIFY_PASSWORD
        doJavascript(verifyPasswordScript())
    }
}

extension BootpayAuthWebView {
    func registerCardScript() -> String {
        if userToken == "" {
            print("userToken이 없습니다")
            return ""
        }
        
        let array = [
            "BootPay.registerCard({",
            "userToken: '\(self.userToken)',",
            "deviceId: '\(Bootpay.getUUID())',",
                "message: '새로운 카드를 등록합니다'",
            "}).easyCancel(function (data) {",
            "webkit.messageHandlers.\(self.bridgeName).postMessage(data);",
            "}).easyError(function (data) {",
            "webkit.messageHandlers.\(self.bridgeName).postMessage(data);",
            "}).easySuccess(function (data) {",
            "webkit.messageHandlers.\(self.bridgeName).postMessage(data);",
            "});"
        ]
        return array.reduce("", +)
    }
    
    func registerCard() {
//        self.request_type = BootpayAuthWebView.REQUEST_TYPE_REGISTER_CARD
        doJavascript(registerCardScript())
    }
}

extension BootpayAuthWebView {
    func changePasswordScript() -> String {
        if userToken == "" {
            print("userToken이 없습니다")
            return ""
        }
        
        let array = [
            "BootPay.changePassword({",
            "userToken: '\(self.userToken)',",
            "deviceId: '\(Bootpay.getUUID())',",
                "message: '비밀번호를 찾습니다'",
            "}).easyCancel(function (data) {",
            "webkit.messageHandlers.\(self.bridgeName).postMessage(data);",
            "}).easyError(function (data) {",
            "webkit.messageHandlers.\(self.bridgeName).postMessage(data);",
            "}).easySuccess(function (data) {",
            "webkit.messageHandlers.\(self.bridgeName).postMessage(data);",
            "});"
        ]
        return array.reduce("", +)
    }
    
    func changePassword() {
        self.request_type = BootpayAuthWebView.REQUEST_TYPE_PASSWORD_CHANGE
        doJavascript(changePasswordScript())
    }
}
