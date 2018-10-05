//
//  WebAppController.swift
//  SwiftyBootpay_Example
//
//  Created by YoonTaesup on 2018. 10. 1..
//  Copyright © 2018년 CocoaPods. All rights reserved.
//

import UIKit
import WebKit


class LocalHtmlController: UIViewController {
    var webView: WKWebView!
    final let bridgeName = "Bootpay_iOS"
    final let ios_application_id = "5a52cc39396fa6449880c0f0" // iOS
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }
    
    func setUI() {
        let configuration = WKWebViewConfiguration() //wkwebview <-> javasscript function(bootpay callback)
        configuration.userContentController.add(self, name: bridgeName)
        webView = WKWebView(frame: self.view.bounds, configuration: configuration)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        self.view.addSubview(webView)
 
        let path = Bundle.main.url(forResource: "index", withExtension: "html")!
        webView.loadFileURL(path, allowingReadAccessTo: path)
        let request = URLRequest(url: path)
        webView.load(request)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension LocalHtmlController:  WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler  {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        registerAppId()
        setDevice()
        startTrace()
    }
    
    func registerAppId() {
        doJavascript("BootPay.setApplicationId('\(ios_application_id)');")
    }
    
    internal func setDevice() {
        doJavascript("window.BootPay.setDevice('IOS');") 
    }
    
    internal func startTrace() {
        doJavascript("BootPay.startTrace();")
    }
    
    func isMatch(_ urlString: String, _ pattern: String) -> Bool {
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        let result = regex.matches(in: urlString, options: [], range: NSRange(location: 0, length: urlString.characters.count))
        return result.count > 0
    }
    
    func isItunesURL(_ urlString: String) -> Bool {
        return isMatch(urlString, "\\/\\/itunes\\.apple\\.com\\/")
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url {
            if url.scheme == "file" {
                decisionHandler(.allow)
                return
            }
            
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
extension LocalHtmlController {
    // 에러가 났을때 호출되는 부분
    func onError(data: [String: Any]) {
        print(data)
    }
    
    // 가상계좌 입금 계좌번호가 발급되면 호출되는 함수입니다.
    func onReady(data: [String: Any]) {
        print("ready")
        print(data)
    }
    
    // 결제가 진행되기 바로 직전 호출되는 함수로, 주로 재고처리 등의 로직이 수행
    func onConfirm(data: [String: Any]) {
        print(data)
        
        let iWantPay = true
        if iWantPay == true {  // 재고가 있을 경우.
            let json = dicToJsonString(data).replace(target: "\"", withString: "'")
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
    }
    
    //결제창이 닫힐때 실행되는 부분
    func onClose() {
        print("close")
//        vc.dismiss() //결제창 종료
    }
}



extension LocalHtmlController {
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
