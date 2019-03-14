//
//  BootpayWebview.swift
//  client_bootpay_swift
//
//  Created by YoonTaesup on 2017. 8. 11..
//  Copyright © 2017년 bootpay.co.kr. All rights reserved.
//

import UIKit
import WebKit
//import CryptoSwift

@objc public protocol BootpayRequestProtocol {
    @objc(onError:) func onError(data: [String: Any])
    @objc(onReady:) func onReady(data: [String: Any])
    @objc func onClose()
    @objc(onConfirm:) func onConfirm(data: [String: Any])
    @objc(onCancel:) func onCancel(data: [String: Any])
    @objc(onDone:) func onDone(data: [String: Any])
}

class BootpayWebView: UIView {
    var wv: WKWebView!
    final let BASE_URL = "https://inapp.bootpay.co.kr/2.1.1/production.html"
    final let bridgeName = "Bootpay_iOS"
    var firstLoad = false
    var sendable: BootpayRequestProtocol?
    var bootpayScript = ""
    var parentController: BootpayController!
    func bootpayRequest(_ script: String) {
        let configuration = WKWebViewConfiguration()
        configuration.userContentController.add(self, name: bridgeName)
        wv = WKWebView(frame: self.bounds, configuration: configuration)
        wv.uiDelegate = self
        wv.navigationDelegate = self
        self.addSubview(wv)
        self.bootpayScript = script
        self.loadUrl(BASE_URL)
    }
}

extension BootpayWebView {
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
        doJavascript("window.BootPay.setApplicationId('\(BootpayAnalytics.sharedInstance.application_id)');")
    }
    
    internal func setDevice() {
        doJavascript("window.BootPay.setDevice('IOS');") 
    }
    
    internal func setAnalytics() {
        if BootpayAnalytics.sharedInstance.sk_time == 0 {
            NSLog("Bootpay Analytics Warning: setAnalytics() not Work!! Please session active in AppDelegate")
            return
        }
        
        doJavascript("window.BootPay.setAnalyticsData({"
            + "sk: '\(BootpayAnalytics.sharedInstance.sk)', "
            + "sk_time: \(BootpayAnalytics.sharedInstance.sk_time), "
            + "time: \(BootpayAnalytics.sharedInstance.time), "
            + "uuid: '\(BootpayAnalytics.sharedInstance.uuid)'"
            + "});")
    }
    
    internal func loadBootapyRequest() {
        doJavascript(self.bootpayScript)
    }
}

extension BootpayWebView: WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler  {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if firstLoad == false {
            firstLoad = true
            registerAppId()
            setDevice()
            setAnalytics()
            loadBootapyRequest()
        }
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
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alertController = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "확인", style: .default) { _ in
            completionHandler()
        }
        let cancelAction = UIAlertAction(title: "결제창 닫기", style: .default) { _ in
            completionHandler()
            self.parentController.dismiss()
        }
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        DispatchQueue.main.async { self.parentController.present(alertController, animated: true, completion: nil) }
    }
    
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping (Bool) -> Void) {
        let alertController = UIAlertController(title: "", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "확인", style: .default, handler: { (action) in
            completionHandler(true)
        }))
        alertController.addAction(UIAlertAction(title: "취소", style: .default, handler: { (action) in
            completionHandler(false)
        }))
        
        DispatchQueue.main.async { self.parentController.present(alertController, animated: true, completion: nil) }
    }
    
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if(message.name == self.bridgeName) {
            guard let body = message.body as? [String: Any] else {
                if message.body as? String == "close" {
                    sendable?.onClose()
                }
                return
            }
            guard let action = body["action"] as? String else { return }
            
            if action == "BootpayCancel" {
                sendable?.onCancel(data: body)
            } else if action == "BootpayError" {
                sendable?.onError(data: body)
            } else if action == "BootpayBankReady" {
                sendable?.onReady(data: body)
            } else if action == "BootpayConfirm" {
                sendable?.onConfirm(data: body)
            } else if action == "BootpayDone" {
                sendable?.onDone(data: body)
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
