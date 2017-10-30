//
//  ViewController.swift
//  SwiftyBootpay
//
//  Created by ehowlsla on 10/30/2017.
//  Copyright (c) 2017 ehowlsla. All rights reserved.
//

import UIKit
import SwiftyBootpay

//MARK: ViewController Init
class ViewController: UIViewController {
    var vc: BootpayController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        sendAnaylticsUserLogin()
        sendAnaylticsCall()
        setUI()
    }
    
    func setUI() {
        let btn = UIButton(type: .roundedRect)
        btn.frame = CGRect(x: 0, y:0, width: self.view.frame.width, height: self.view.frame.height)
        btn.setTitle("Request", for: .normal)
        btn.addTarget(self, action: #selector(btnClick), for: .touchUpInside)
        self.view.addSubview(btn)
    }
    
    @objc func btnClick() {
        presentBootpayController()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


//MARK: Bootpay Event Handle
extension ViewController {
    func sendAnaylticsUserLogin() {
        BootpayAnalytics.sharedInstance.user.params {
            $0.user_id = "1"
            $0.username = "광명섹시남"
            $0.email = "sexyking@gmail.com"
            $0.gender = 1
            $0.birth = "861014"
            $0.phone = "01040334678"
            $0.area = "서울"
        }
    }
    
    func sendAnaylticsCall() {
        BootpayAnalytics.sharedInstance.postCall(url: "http://www.test.com",
                                                 page_type: "test",
                                                 img_url: "",
                                                 item_unique: "1",
                                                 item_name: "철산동핫도그")
    }
    
    func presentBootpayController() {
        let item = BootpayItem().params {
            $0.item_name = "B사 마스카라"
            $0.qty = 1
            $0.unique = "123"
            $0.price = 1000
        }
        
        let customParams: [String: String] = [
            "callbackParam1": "value12",
            "callbackParam2": "value34",
            "callbackParam3": "value56",
            "callbackParam4": "value78",
            ]
        
        vc = BootpayController()
        vc.params {
            $0.price = 1000
            $0.name = "블링블링 마스카라"
            $0.order_id = "1234"
            $0.params = customParams
            $0.method = "card"
            $0.pg = "danal"
            $0.sendable = self
        }
        vc.addItem(item: item)
        
        self.present(vc, animated: true, completion: nil)
    }
}


//MARK: Bootpay Callback Protocol
extension ViewController: BootpayRequestProtocol {
    func onError(data: [String: Any]) {
        print(data)
        vc.dismiss()
    }
    
    func onConfirm(data: [String: Any]) {
        print(data)
        
        let iWantPay = true
        if iWantPay == true {
            vc.transactionConfirm(data: data)
        } else {
            vc.dismiss()
        }
    }
    
    func onCancel(data: [String: Any]) {
        print(data)
        vc.dismiss()
    }
    
    func onDone(data: [String: Any]) {
        print(data)
        vc.dismiss()
    }
}
