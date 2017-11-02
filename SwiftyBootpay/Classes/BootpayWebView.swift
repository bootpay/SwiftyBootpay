//
//  BootpayWebview.swift
//  client_bootpay_swift
//
//  Created by YoonTaesup on 2017. 8. 11..
//  Copyright © 2017년 bootpay.co.kr. All rights reserved.
//

import UIKit
import WebKit

public protocol BootpayRequestProtocol {
    func onError(data: [String: Any])
    func onConfirm(data: [String: Any])
    func onCancel(data: [String: Any])
    func onDone(data: [String: Any])
}

class BootpayWebView: UIView {
    var wv: WKWebView!
 
    final let BASE_URL = "https://inapp.bootpay.co.kr/1.0.0/production.html"
    final let bridgeName = "Bootpay_iOS"
 
    var firstLoad = false
    
    var sendable: BootpayRequestProtocol?
    var bootpayScript = ""
    var parentController: UIViewController!
    
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
        doJavascript("$('script[data-boot-app-id]').attr('data-boot-app-id', '\(BootpayAnalytics.sharedInstance.application_id)');")
    }
    
    internal func setDevice() {
        doJavascript("window.BootPay.setDevice('IOS');")
        doJavascript("console.log(window.BootPay.deviceType);")
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
        } else { decisionHandler(.allow) }
    }
    
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alertController = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "확인", style: .cancel) { _ in completionHandler() }
        alertController.addAction(cancelAction)
        DispatchQueue.main.async { self.parentController.present(alertController, animated: true, completion: nil) }
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if(message.name == self.bridgeName) {
            print(message.body)
            guard let body = message.body as? [String: Any] else { return }
            guard let action = body["action"] as? String else { return }
            
            if action == "BootpayCancel" {
                sendable?.onCancel(data: body)
            } else if action == "BootpayError" {
                sendable?.onError(data: body)
            } else if action == "BootpayConfirm" {
                sendable?.onConfirm(data: body)
            } else if action == "BootpayDone" {
                sendable?.onDone(data: body)
            }
        }
    }
}
