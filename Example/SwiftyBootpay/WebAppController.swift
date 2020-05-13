//
//  WebAppController.swift
//  SwiftyBootpay_Example
//
//  Created by YoonTaesup on 2018. 10. 1..
//  Copyright © 2018년 CocoaPods. All rights reserved.
//

import UIKit
import WebKit


class WebAppController: UIViewController {
    var webView: WKWebView!
    final let bridgeName = "Bootpay_iOS"
    final let ios_application_id = "5b8f6a4d396fa665fdc2b5e9" // iOS 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }
    
    func setUI() {
        HTTPCookieStorage.shared.cookieAcceptPolicy = HTTPCookie.AcceptPolicy.always // 현대카드 등 쿠키설정 이슈 해결을 위해 필요
        let configuration = WKWebViewConfiguration() //wkwebview <-> javasscript function(bootpay callback)
        configuration.userContentController.add(self, name: bridgeName)
        webView = WKWebView(frame: self.view.bounds, configuration: configuration)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        self.view.addSubview(webView)
        
        
        let url = URL(string: "https://www.xn--v52b27q9ubg9u.com/app/user/auth/login.php")
//        let url = URL(string: "https://test-shop.bootpay.co.kr") 
         
        
        
        
        if let url = url {
            let request = URLRequest(url: url)
            webView.load(request)
        } 
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension WebAppController:  WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler  {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
//        registerAppId() //필요시 App ID를 아이폰 값으로 바꿉니다
//        setDevice() //기기환경을 IOS로 등록합니다. 이 작업을 수행해야 통계에 iOS로 잡히며, iOS Application ID 값을 호출하여 결제를 사용할 수 있습니다.
//        startTrace() // 통계 - 페이지 방문
//        registerAppIdDemo() //필요시 App ID를 아이폰 값으로 바꿉니다
    }
    
    func registerAppId() {
        doJavascript("BootPay.setApplicationId('\(ios_application_id)');")
    }
    
    func registerAppIdDemo() {
        doJavascript("window.setApplicationId('\(ios_application_id)');")
    }
    
    internal func setDevice() {
        doJavascript("window.BootPay.setDevice('IOS');") 
    }
    
    internal func startTrace() {
        doJavascript("BootPay.startTrace();")
    }
    
    func isMatch(_ urlString: String, _ pattern: String) -> Bool {
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
//        let result = regex.matches(in: urlString, options: [], range: NSRange(location: 0, length: urlString.characters.count))
        let result = regex.matches(in: urlString, options: [], range: NSRange(location: 0, length: urlString.count))
        return result.count > 0
    }
    
    func isItunesURL(_ urlString: String) -> Bool {
        return isMatch(urlString, "\\/\\/itunes\\.apple\\.com\\/")
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        
        
        if let url = navigationAction.request.url {
            
            print("--------------- \(url.absoluteString)");
            
            if(isItunesURL(url.absoluteString)) {
                if #available(iOS 10, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
                decisionHandler(.cancel)
            } else if url.scheme != "http" && url.scheme != "https" {
                if #available(iOS 10, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
                decisionHandler(.cancel)
            } else {
                decisionHandler(.allow)
            }
        } else {
            decisionHandler(.allow)
        }
    }
    
//    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
//        let alertController = UIAlertController(title: message, message: nil, preferredStyle: .alert)
//        let confirmAction = UIAlertAction(title: "확인", style: .default) { _ in
//            completionHandler()
//        }
//        let cancelAction = UIAlertAction(title: "결제창 닫기", style: .default) { _ in
//            completionHandler()
////            dismiss()
//        }
//        alertController.addAction(confirmAction)
//        alertController.addAction(cancelAction)
//        DispatchQueue.main.async { self.present(alertController, animated: true, completion: nil) }
//    }
//
//    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo,
//                 completionHandler: @escaping (Bool) -> Void) {
//        let alertController = UIAlertController(title: "", message: message, preferredStyle: .alert)
//        alertController.addAction(UIAlertAction(title: "확인", style: .default, handler: { (action) in
//            completionHandler(true)
//        }))
//        alertController.addAction(UIAlertAction(title: "취소", style: .default, handler: { (action) in
//            completionHandler(false)
//        }))
//
//        DispatchQueue.main.async { self.present(alertController, animated: true, completion: nil) }
//    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if(message.name == self.bridgeName) {
            guard let body = message.body as? [String: Any] else {
                if message.body as? String == "close" {
                    onClose()
                }
                return
            }
            guard let action = body["action"] as? String else {
                return
            }
            
            // 해당 함수 호출
            if action == "BootpayCancel" {
                onCancel(data: body)
            } else if action == "BootpayError" {
                onError(data: body)
            } else if action == "BootpayBankReady" {
                onReady(data: body)
            } else if action == "BootpayConfirm" {
                onConfirm(data: body)
            } else if action == "BootpayDone" {
                onDone(data: body)
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
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil {
            if let url = navigationAction.request.url {
                if #available(iOS 10, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        }
        return nil
    }
}


//MARK: Bootpay Callback Protocol
extension WebAppController {
    // 에러가 났을때 호출되는 부분
    func onError(data: [String: Any]) {
        print(data)
    }
    
    // 가상계좌 입금 계좌번호가 발급되면 호출되는 함수입니다.
    func onReady(data: [String: Any]) {
//        print("ready")
        print(data)
    }
    
    // 결제가 진행되기 바로 직전 호출되는 함수로, 주로 재고처리 등의 로직이 수행
    func onConfirm(data: [String: Any]) {
        print(data)
        
        let iWantPay = true
        if iWantPay == true {  // 재고가 있을 경우.
            let json = dicToJsonString(data).replace(target: "'", withString: "\\'")
            doJavascript("BootPay.transactionConfirm( \(json) );"); // 결제 승인
        } else { // 재고가 없어 중간에 결제창을 닫고 싶을 경우
            doJavascript("BootPay.removePaymentWindow();");
        }
    }
    
    // 결제 취소시 호출
    func onCancel(data: [String: Any]) {
        print(data)
    }
    
    // 결제완료시 호출
    // 아이템 지급 등 데이터 동기화 로직을 수행합니다
    func onDone(data: [String: Any]) {
        print(data)
//        self.navigationController?.popViewController(animated: true)
    }
    
    //결제창이 닫힐때 실행되는 부분
    func onClose() {
        print("close")
    }
}



extension WebAppController {
    internal func doJavascript(_ script: String) {
        webView.evaluateJavaScript(script, completionHandler: nil)
    }
    
    fileprivate func dicToJsonString(_ data: [String: Any]) -> String {
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
}
