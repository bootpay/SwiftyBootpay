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

class NativeFingerController: UIViewController {
    var payType = 1 //1:finter, 2:easy card
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }
    
    func setUI() {
        //set webview
        let configuration = WKWebViewConfiguration()
        var webView = WKWebView(frame: CGRect.init(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height - 60), configuration: configuration)
        self.view.addSubview(webView)
        
        let url =  URL(string: "https://www.imvely.com/product/detail.html?product_no=17831&cate_no=649&display_group=1&src=image&kw=000010&utm_source=both_none_etc&utm_medium=sa_google_shopping&utm_campaign=current_imvely_google&utm_content=feed&gclid=Cj0KCQjw2or8BRCNARIsAC_ppybpAkF_3qJPCM3Q6L98yfQ00HHtk10BwjCzecLjzuj3ipJzaji6OKoaAk4EEALw_wcB")!
        let request = URLRequest(url: url)
        webView.load(request)
        
        //set button
        let btn1 = UIButton(type: .custom)
        btn1.frame = CGRect(x: 0, y: self.view.bounds.height - 60, width: self.view.bounds.width/2, height: 60)
        btn1.setTitle("결제하기", for: .normal)
        btn1.setTitleColor(.white, for: .normal)
        btn1.backgroundColor = UIColor.init(red: 254.0 / 255, green: 134.0 / 255, blue: 133.0 / 255, alpha: 1)
        btn1.addTarget(self, action: #selector(goFinerPay), for: .touchUpInside)
        self.view.addSubview(btn1)
        
        
        let btn2 = UIButton(type: .custom)
        btn2.frame = CGRect(x: self.view.bounds.width/2, y: self.view.bounds.height - 60, width: self.view.bounds.width/2, height: 60)
        btn2.setTitle("카드등록", for: .normal)
        btn2.setTitleColor(.white, for: .normal)
        btn2.backgroundColor = UIColor.init(red: 202.0 / 255, green: 109.0 / 255, blue: 108.0 / 255, alpha: 1.0)
        btn2.addTarget(self, action: #selector(goEasyPay), for: .touchUpInside)
        self.view.addSubview(btn2)
    }
    
    @objc func goFinerPay() {
        payType = 1
        getRestToken()
    }
    
    @objc func goEasyPay() {
        payType = 2
        getRestToken()
    }
   
}

extension NativeFingerController: BootpayRestProtocol {
    func callbackRestToken(resData: [String : Any]) {
        if let data = resData["data"], let token  = (data as! [String: Any])["token"]  {
            let unique_user_id = "user_2134_1234"
//                String(Date().timeIntervalSinceReferenceDate) // 이 값이 user_id로, user별로 고유해야한다. 겹칠경우 등록된 결제수단에 대해 다른 사용자가 결제를 하는 대참사가 벌어질 수 있다.
            
            let user = BootpayUser()
            user.id = unique_user_id
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
            if(payType == 1) {
                presentFinterController(userToken: userToken as! String)
            } else {
                presentEasyCard(userToken: userToken as! String)
//                presentFinterController(userToken: userToken as! String)
            }
            
//            presentFinterController(userToken: "5f83decf85cd5803be749683")
        }
    }
    
    func getRestToken () {
//        let restApplicationId = "5b8f6a4d396fa665fdc2b5ea"
//        let privateKey = "n9jO7MxVFor3o//c9X5tdep95ZjdaiDvVB4h1B5cMHQ="
        
        let restApplicationId = "5b9f51264457636ab9a07cde"
        let privateKey = "sfilSOSVakw+PZA+PRux4Iuwm7a//9CXXudCq9TMDHk="
           
         BootpayRest.getRestToken(sendable: self, restApplicationId: restApplicationId, privateKey: privateKey)
    }
    
    
    func presentFinterController(userToken: String) {
        let vc = BootpayAuthController()
        vc.userToken = userToken
        self.present(vc, animated: true, completion: nil)
    }
    
    func presentEasyCard(userToken: String) {
         let user = BootpayUser()
        user.phone = "010-1234-4567"
        
          let payload = BootpayPayload()
          payload.params {
             $0.price = 1000 // 결제할 금액
             $0.name = "블링블링's 마스카라" // 결제할 상품명
    //         $0.phone
             $0.order_id = String(Date().timeIntervalSinceReferenceDate) // 결제 고유번호
             $0.application_id = "5b9f51264457636ab9a07cdd"
//             $0.application_id = "5b8f6a4d396fa665fdc2b5e9"
             $0.user_token = userToken
             
    //
    //         $0.user_info = bootUser
             $0.pg = BootpayPG.NICEPAY // 결제할 PG사
             //            $0.account_expire_at = "2018-09-25" // 가상계좌 입금기간 제한 ( yyyy-mm-dd 포멧으로 입력해주세요. 가상계좌만 적용됩니다. 오늘 날짜보다 더 뒤(미래)여야 합니다 )
    //                        $0.method = "card" // 결제수단
             $0.show_agree_window = false
             $0.method = Method.EASY_CARD
//             $0.methods = [Method.EASY_CARD, Method.CARD, Method.EASY_BANK, Method.PHONE, Method.BANK, Method.VBANK]
             $0.ux = UX.PG_DIALOG
          }
              
                    
              Bootpay.request(self, sendable: self, payload: payload, user: user, items: [BootpayItem](), extra: BootpayExtra(), addView: true)
    }
}



//MARK: Bootpay Callback Protocol
extension NativeFingerController: BootpayRequestProtocol {
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
        
        let iWantPay = true
        if iWantPay == true {  // 재고가 있을 경우.
            Bootpay.transactionConfirm(data: data) // 결제 승인
        } else { // 재고가 없어 중간에 결제창을 닫고 싶을 경우
            Bootpay.dismiss()
        }
    }
    
    // 결제 취소시 호출
    func onCancel(data: [String: Any]) {
      print("------------ cancel \(data)")
    }
    
    // 결제완료시 호출
    // 아이템 지급 등 데이터 동기화 로직을 수행합니다
    func onDone(data: [String: Any]) {
//        print("onDone")
        print("------------ done \(data)")
    }
    
    //결제창이 닫힐때 실행되는 부분
    func onClose() {
        print("--------------   close")
        Bootpay.dismiss()
    }
}
