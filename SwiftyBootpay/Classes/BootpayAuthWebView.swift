//
//  BootpayAuthWebView.swift
//  Alamofire
//
//  Created by Taesup Yoon on 12/10/2020.
//

import UIKit
import WebKit

@objc public protocol BootpayAuthProtocol {
    @objc(verifyCancel:) func verifyCancel(data: [String: Any])
    @objc(verifyError:) func verifyError(data: [String: Any])
    @objc(verifySuccess:) func verifySuccess(data: [String: Any])
}


@objc class BootpayAuthWebView: UIView {
    var wv: WKWebView!
    let configuration = WKWebViewConfiguration()
    final let BASE_URL = Bootpay.URL
    final let bridgeName = "Bootpay_iOS"
    var userToken = ""
    var firstLoad = false
    var sendable: BootpayAuthProtocol?
    
    func request() {
       
        HTTPCookieStorage.shared.cookieAcceptPolicy = HTTPCookie.AcceptPolicy.always  // 현대카드 등 쿠키설정 이슈 해결을 위해 필요
        configuration.userContentController.add(self, name: bridgeName)
        wv = WKWebView(frame: self.bounds, configuration: configuration)
        wv.uiDelegate = self
        wv.navigationDelegate = self
        self.addSubview(wv)
        self.loadUrl(BASE_URL)
   }
}

extension BootpayAuthWebView {
    
    
    internal func doJavascript(_ script: String) {
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
        let app_id = "5b9f51264457636ab9a07cdd"
        doJavascript("window.BootPay.setApplicationId('\(app_id)');")
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
    
    func generateScript() -> String {
        if userToken == "" {
            print("userToken이 없습니다")
            return ""
        }
        
        let array = [
            "BootPay.verifyPassword({",
            "userToken: '\(self.userToken)',",
            "deviceId: '\(Bootpay.getUUID())',",
                "message: '생체인식결제를 활성화합니다'",
            "}).verifyCancel(function (data) {",
            "webkit.messageHandlers.\(self.bridgeName).postMessage(data);",
            "}).verifyError(function (data) {",
            "webkit.messageHandlers.\(self.bridgeName).postMessage(data);",
            "}).verifySuccess(function (data) {",
            "webkit.messageHandlers.\(self.bridgeName).postMessage(data);",
            "});"
        ]
        return array.reduce("", +)
    }
    
    func authStart() {
        print(generateScript())
        doJavascript(generateScript())
    }
}

extension BootpayAuthWebView: WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler  {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if firstLoad == false {
        
            firstLoad = true
            registerAppId()
            setDevelopMode()
            setDevice()
            setAnalytics()
            authStart()
        }
    }
    
     
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if(message.name == self.bridgeName) {
            guard let body = message.body as? [String: Any] else { return }
            guard let action = body["action"] as? String else { return }
            
            if action == "BootpayVerifyCancel" {
                sendable?.verifyCancel(data: body)
            } else if action == "BootpayVerifyError" {
                sendable?.verifyError(data: body)
            } else if action == "BootpayVerifySuccess" {
                sendable?.verifySuccess(data: body)
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
