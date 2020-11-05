//
//  NativeFingerController.swift
//  SwiftyBootpay_Example
//
//  Created by Taesup Yoon on 12/10/2020.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import WebKit
import SwiftyBootpay
import Alamofire

class NativeBioController: UIViewController {
    var payType = 1 //1:finter, 2:easy card
    let unique_user_id = Bootpay.getUUID() // 실제값을 적용하실 때에는, 관리하시는 user_id를 입력해주세요. 고객별로 유니크해야하며, 다른 고객과 절대로 중복되어서는 안됩니다
//    "user_2134_123457812345678901234"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }
    
    func setUI() {
        //set webview
        let configuration = WKWebViewConfiguration()
        var webView = WKWebView(frame: CGRect.init(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height - 60), configuration: configuration)
        self.view.addSubview(webView)
        
        let url =  URL(string: "https://devtest219.shop.blogpay.co.kr/view/good/2Fd3D")!
        let request = URLRequest(url: url)
        webView.load(request)
        
        //set button
        let btn1 = UIButton(type: .custom)
        btn1.frame = CGRect(x: 0, y: self.view.bounds.height - 60, width: self.view.bounds.width, height: 60)
        btn1.setTitle("결제하기", for: .normal)
        btn1.setTitleColor(.white, for: .normal)
        btn1.backgroundColor = UIColor.init(red: 254.0 / 255, green: 134.0 / 255, blue: 133.0 / 255, alpha: 1)
        btn1.addTarget(self, action: #selector(goFinerPay), for: .touchUpInside)
        self.view.addSubview(btn1)
    }
    
    @objc func goFinerPay() {
//        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
      
        
        payType = 1
        getRestToken()
    }
    
    @objc func goEasyPay() {
        payType = 2
        getRestToken()
    }
   
}

extension NativeBioController: BootpayRestProtocol {
    func callbackRestToken(resData: [String : Any]) {
        if let data = resData["data"], let token  = (data as! [String: Any])["token"]  {
//            let unique_user_id = "user_2134_123457890"
//                String(Date().timeIntervalSinceReferenceDate) // 이 값이 user_id로, user별로 고유해야한다. 겹칠경우 등록된 결제수단에 대해 다른 사용자가 결제를 하는 대참사가 벌어질 수 있다.
            
            let user = BootpayUser()
            user.id = self.unique_user_id
            user.area = "서울"
            user.gender = 1
            user.email = "test1234@gmail.com"
            user.phone = "010-1234-4567"
            user.birth = "1988-06-10"
            user.username = "홍길동"
            
            
            
            
            if let json = user.toJSONString() {
               BootpayRest.getEasyPayUserToken(sendable: self, restToken: token as! String, user: json)
            }
        }
    }
    
    func callbackEasyCardUserToken(resData: [String : Any]) {
        if let data = resData["data"], let userToken  = (data as! [String: Any])["user_token"] {
            //해당 기기에서 지문결제 등록을 안했으면
            presentFingerController(userToken: userToken as! String)
        }
    }
    
    func getRestToken () {
        let restApplicationId = "5b8f6a4d396fa665fdc2b5ea"
        let privateKey = "n9jO7MxVFor3o//c9X5tdep95ZjdaiDvVB4h1B5cMHQ="
        
//        let restApplicationId = "5b9f51264457636ab9a07cde"
//        let privateKey = "sfilSOSVakw+PZA+PRux4Iuwm7a//9CXXudCq9TMDHk="
           
         BootpayRest.getRestToken(sendable: self, restApplicationId: restApplicationId, privateKey: privateKey)
    }
    
    
    func presentFingerController(userToken: String) {
        let bioPayload = BootpayBioPayload()
        bioPayload.pg = BootpayPG.NICEPAY
        bioPayload.names = ["플리츠레이어 카라숏원피스", "블랙 (COLOR)", "55 (SIZE)"]
//        bioPayload.application_id = "5b9f51264457636ab9a07cdd"
        bioPayload.application_id = "5b8f6a4d396fa665fdc2b5e9"
        bioPayload.order_id = String(Date().timeIntervalSinceReferenceDate)
        bioPayload.price = 1000
        bioPayload.name = "Touch ID 인증 결제 테스트"
//        bioPayload.quotas = [0,1,2,3,4,5]
        
        let extra = BootpayExtra()
        extra.quotas = [0,1,2,3,4,5]
        
        
        
        let p1 = BootpayBioPrice()
        let p2 = BootpayBioPrice()
        let p3 = BootpayBioPrice()
        
        p1.name = "상품가격"
        p1.price = 89000
        
        p2.name = "쿠폰적용"
        p2.price = -2500
        
        p3.name = "배송비"
        p3.price = 2500
        
        bioPayload.prices = [p1, p2, p3]
        bioPayload.user_token = userToken
        
        let item1 = BootpayItem().params {
            $0.item_name = "미\"키's 마우스" // 주문정보에 담길 상품명
            $0.qty = 1 // 해당 상품의 주문 수량
            $0.unique = "ITEM_CODE_MOUSE" // 해당 상품의 고유 키
            $0.price = 9000 // 상품의 가격
        }
        let item2 = BootpayItem().params {
            $0.item_name = "키보드" // 주문정보에 담길 상품명
            $0.qty = 1 // 해당 상품의 주문 수량
            $0.unique = "ITEM_CODE_KEYBOARD" // 해당 상품의 고유 키
            $0.price = 80000 // 상품의 가격
            $0.cat1 = "패션"
            $0.cat2 = "여\"성'상의"
            $0.cat3 = "블라우스"
        }
        var items = [BootpayItem]()
        items.append(item1)
        items.append(item2)
        
         // 구매자 정보
        let bootUser = BootpayUser()
         bootUser.params {
//            $0.username = "사용자 이름"
            $0.email = "user1234@gmail.com"
            $0.area = "서울" // 사용자 주소
            $0.addr = "서울시 동작구 상도로";
            $0.phone = "010-1234-4567"
         }
        
        
        Bootpay.requestBio(self, sendable: self, payload: bioPayload, user: bootUser, items: items, extra: extra)
    }
}



//MARK: Bootpay Callback Protocol
extension NativeBioController: BootpayRequestProtocol {
    // 에러가 났을때 호출되는 부분
    func onError(data: [String: Any]) {
        print("------------ error \(data)")
    }
    
    // 가상계좌 입금 계좌번호가 발급되면 호출되는 함수입니다.
    func onReady(data: [String: Any]) {
      print("------------ ready \(data)")
    }
    
    // 결제가 진행되기 바로 직전 호출되는 함수로, 주로 재고처리 등의 로직이 수행
    func onConfirm(data: [String: Any]) {
        print("------------ confirm \(data)")
        Bootpay.transactionConfirm(data: data)
    }
    
    // 결제 취소시 호출
    func onCancel(data: [String: Any]) {
      print("------------ cancel \(data)")
        Bootpay.dismiss()
    }
    
    // 결제완료시 호출
    // 아이템 지급 등 데이터 동기화 로직을 수행합니다
    func onDone(data: [String: Any]) {
        print("onDone")
        Bootpay.dismiss()
    }
    
    //결제창이 닫힐때 실행되는 부분
    func onClose() {
        print("--------------   close")
    }
}
