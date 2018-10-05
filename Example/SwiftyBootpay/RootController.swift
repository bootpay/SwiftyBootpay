//
//  RootController.swift
//  SwiftyBootpay_Example
//
//  Created by YoonTaesup on 2018. 10. 1..
//  Copyright © 2018년 CocoaPods. All rights reserved.
//

import UIKit

extension String
{
    func replace(target: String, withString: String) -> String
    {
        return self.replacingOccurrences(of: target, with: withString, options: NSString.CompareOptions.literal, range: nil)
    }
}

class RootController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Bootpay 연동 샘플"
        setUI()
    }
    
    func setUI() {
        let titles = ["Native 연동", "LocalHtml 연동", "WebApp 연동"]
        let selectors = [#selector(nativeClick), #selector(localHtmlClick), #selector(webappClick)]
        let array = 0...2
        let unitHeight = self.view.frame.height / CGFloat(array.count)
        for i in array {
            let btn = UIButton(type: .roundedRect)
            btn.frame = CGRect(x: 0, y: unitHeight * CGFloat(i), width: self.view.frame.width, height: unitHeight)
            btn.setTitle(titles[i], for: .normal)
            btn.addTarget(self, action: selectors[i], for: .touchUpInside)
            self.view.addSubview(btn)
        }
    }
    
    @objc func nativeClick() {
        let vc = NativeController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func localHtmlClick() {
        let vc = LocalHtmlController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func webappClick() {
        let vc = WebAppController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
