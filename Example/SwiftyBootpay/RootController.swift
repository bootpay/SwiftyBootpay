//
//  RootController.swift
//  SwiftyBootpay_Example
//
//  Created by YoonTaesup on 2018. 10. 1..
//  Copyright © 2018년 CocoaPods. All rights reserved.
//

import UIKit

class RootController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Bootpay 연동 샘플"
        setUI()
    }
    
    func setUI() {
        let btn1 = UIButton(type: .roundedRect)
        btn1.frame = CGRect(x: 0, y:0, width: self.view.frame.width, height: self.view.frame.height/2)
        btn1.setTitle("Native 연동", for: .normal)
        btn1.addTarget(self, action: #selector(nativeClick), for: .touchUpInside)
        self.view.addSubview(btn1)
        
        let btn2 = UIButton(type: .roundedRect)
        btn2.frame = CGRect(x: 0, y:self.view.frame.height/2, width: self.view.frame.width, height: self.view.frame.height/2)
        btn2.setTitle("Webapp 연동", for: .normal)
        btn2.addTarget(self, action: #selector(webappClick), for: .touchUpInside)
        self.view.addSubview(btn2)
    }
    
    @objc func nativeClick() {
        let vc = NativeController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func webappClick() {
        let vc = WebAppController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
