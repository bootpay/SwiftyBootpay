//
//  ViewController.swift
//  SwiftyBootpay
//
//  Created by ehowlsla on 10/30/2017.
//  Copyright (c) 2017 ehowlsla. All rights reserved.
//

import UIKit
import SwiftyBootpay
import Alamofire

//MARK: ViewController Init
class NativeController: UIViewController {
    var vc: BootpayController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.view.backgroundColor = UIColor.white
        setUI()
        sendAnaylticsUserLogin() // 유저 로그인 시점에 호출
        sendAnaylticsPageCall() // 페이지 유입(추적) 시점에 호출, 로그인 통신이 완료된 후에 호출해야 함
    }
   
    func setUI() {
      let titles = ["Native 결제요청", "RemoteLink 결제", "RemoteOrder 결제", "RemotePre 결제"]
      let selectors = [#selector(nativeClick), #selector(remoteLinkClick), #selector(remoteOrderClick), #selector(remotePreClick)]
      let array = 0...3
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
      presentBootpayController()
   }
//   @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
  
   @objc func remoteLinkClick() {
      let item1 = BootpayItem().params {
         $0.item_name = "미\"키's 마우스" // 주문정보에 담길 상품명
         $0.qty = 1 // 해당 상품의 주문 수량
         $0.unique = "ITEM_CODE_MOUSE" // 해당 상품의 고유 키
         $0.price = 1000 // 상품의 가격
      }
      let item2 = BootpayItem().params {
         $0.item_name = "키보드" // 주문정보에 담길 상품명
         $0.qty = 1 // 해당 상품의 주문 수량
         $0.unique = "ITEM_CODE_KEYBOARD" // 해당 상품의 고유 키
         $0.price = 10000 // 상품의 가격
         $0.cat1 = "패션"
         $0.cat2 = "여\"성'상의"
         $0.cat3 = "블라우스"
      }
      
      // 커스텀 변수로, 서버에서 해당 값을 그대로 리턴 받음
      let customParams: [String: String] = [
         "callbackParam1": "value12",
         "callbackParam2": "value34",
         "callbackParam3": "value56",
         "callbackParam4": "value78",
         ]
      
      // 구매자 정보
      let bootUser = BootpayUser()
      bootUser.params {
         $0.username = "사용자 이름"
         $0.email = "user1234@gmail.com"
         $0.area = "서울" // 사용자 주소
         $0.phone = "010-1234-4567"
      }
      
      let payload = BootpayPayload()
      //         $0.application_id = "5a52cc39396fa6449880c0f0"
      // 주문정보 - 실제 결제창에 반영되는 정보
      payload.params {
         $0.price = 1000 // 결제할 금액
         $0.name = "블링\"블링's 마스카라" // 결제할 상품명
         $0.order_id = "1234_1234_124" // 결제 고유번호
         $0.params = customParams // 커스텀 변수
         $0.application_id = "5b9f51264457636ab9a07cdd"
//         $0.user_info = bootUser
         $0.pg = "danal" // 결제할 PG사
         //            $0.account_expire_at = "2018-09-25" // 가상계좌 입금기간 제한 ( yyyy-mm-dd 포멧으로 입력해주세요. 가상계좌만 적용됩니다. 오늘 날짜보다 더 뒤(미래)여야 합니다 )
         //            $0.method = "card" // 결제수단
         $0.methods = ["card", "phone"]
         $0.sms_use = true
         $0.ux = "BOOTPAY_REMOTE_LINK"
      }
      var items = [BootpayItem]()
      items.append(item1)
      items.append(item2)
      
      let smsPayload = SMSPayload()
      smsPayload.params {
         $0.msg = "결제링크 안내입니다\n[결제링크]"
         $0.sp = "010-1234-4678"
         $0.rps = ["010-1234-4678"]
      }
      
      
      Bootpay.request(self, sendable: self, payload: payload, user: bootUser, items: items, smsPayload: smsPayload)
//      Bootpay.request_link(request, items: items, user: bootUser, extra: nil, smsPayload: smsPayload)
   }
   
   @objc func remoteOrderClick() {
      let item1 = BootpayItem().params {
         $0.item_name = "미\"키's 마우스" // 주문정보에 담길 상품명
         $0.qty = 1 // 해당 상품의 주문 수량
         $0.unique = "ITEM_CODE_MOUSE" // 해당 상품의 고유 키
         $0.price = 1000 // 상품의 가격
      }
      let item2 = BootpayItem().params {
         $0.item_name = "키보드" // 주문정보에 담길 상품명
         $0.qty = 1 // 해당 상품의 주문 수량
         $0.unique = "ITEM_CODE_KEYBOARD" // 해당 상품의 고유 키
         $0.price = 10000 // 상품의 가격
         $0.cat1 = "패션"
         $0.cat2 = "여\"성'상의"
         $0.cat3 = "블라우스"
      }
      
      // 커스텀 변수로, 서버에서 해당 값을 그대로 리턴 받음
      let customParams: [String: String] = [
         "callbackParam1": "value12",
         "callbackParam2": "value34",
         "callbackParam3": "value56",
         "callbackParam4": "value78",
         ]
      
      // 구매자 정보
      let bootUser = BootpayUser()
      bootUser.params {
         $0.username = "사용자 이름"
         $0.email = "user1234@gmail.com"
         $0.area = "서울" // 사용자 주소
         $0.phone = "010-1234-4567"
      }
      
      let payload = BootpayPayload()
      
      
      //         $0.application_id = "5a52cc39396fa6449880c0f0"
      
      // 주문정보 - 실제 결제창에 반영되는 정보
      payload.params {
         $0.price = 1000 // 결제할 금액
         $0.name = "블링\"블링's 마스카라" // 결제할 상품명
         $0.order_id = "1234_1234_124" // 결제 고유번호
         $0.params = customParams // 커스텀 변수
         $0.application_id = "5b9f51264457636ab9a07cdd"
         //         $0.user_info = bootUser
         $0.pg = "payletter" // 결제할 PG사
         //            $0.account_expire_at = "2018-09-25" // 가상계좌 입금기간 제한 ( yyyy-mm-dd 포멧으로 입력해주세요. 가상계좌만 적용됩니다. 오늘 날짜보다 더 뒤(미래)여야 합니다 )
         //            $0.method = "card" // 결제수단
         $0.method = "card"
//         $0.methods = ["card", "phone"]
         $0.sms_use = true
         $0.ux = "BOOTPAY_REMOTE_FORM"
      }
      var items = [BootpayItem]()
      items.append(item1)
      items.append(item2)
      
      let smsPayload = SMSPayload()
      smsPayload.params {
         $0.msg = "결제링크 안내입니다\n[결제링크]"
         $0.sp = "010-1234-4678"
         $0.rps = ["010-1234-4678"]
      }
      
      Bootpay.request(self, sendable: self, payload: payload, user: bootUser, items: items, smsPayload: smsPayload)
//      Bootpay.request_form(request, user: bootUser, items: items, extra: nil, smsPayload: smsPayload, remoteForm: nil)
   
   }
   
   @objc func remotePreClick() {
      let item1 = BootpayItem().params {
         $0.item_name = "미\"키's 마우스" // 주문정보에 담길 상품명
         $0.qty = 1 // 해당 상품의 주문 수량
         $0.unique = "ITEM_CODE_MOUSE" // 해당 상품의 고유 키
         $0.price = 1000 // 상품의 가격
      }
      let item2 = BootpayItem().params {
         $0.item_name = "키보드" // 주문정보에 담길 상품명
         $0.qty = 1 // 해당 상품의 주문 수량
         $0.unique = "ITEM_CODE_KEYBOARD" // 해당 상품의 고유 키
         $0.price = 10000 // 상품의 가격
         $0.cat1 = "패션"
         $0.cat2 = "여\"성'상의"
         $0.cat3 = "블라우스"
      }
      
      // 커스텀 변수로, 서버에서 해당 값을 그대로 리턴 받음
      let customParams: [String: String] = [
         "callbackParam1": "value12",
         "callbackParam2": "value34",
         "callbackParam3": "value56",
         "callbackParam4": "value78",
         ]
      
      // 구매자 정보
      let bootUser = BootpayUser()
      bootUser.params {
         $0.username = "사용자 이름"
         $0.email = "user1234@gmail.com"
         $0.area = "서울" // 사용자 주소
         $0.phone = "010-1234-4567"
      }
      
      let payload = BootpayPayload()
      
      
      //         $0.application_id = "5a52cc39396fa6449880c0f0"
      
      // 주문정보 - 실제 결제창에 반영되는 정보
      payload.params {
         $0.price = 1000 // 결제할 금액
         $0.name = "블링\"블링's 마스카라" // 결제할 상품명
         $0.order_id = "1234_1234_124" // 결제 고유번호
         $0.params = customParams // 커스텀 변수
         $0.application_id = "5b9f51264457636ab9a07cdd"
         //         $0.user_info = bootUser
         $0.pg = "danal" // 결제할 PG사
         //            $0.account_expire_at = "2018-09-25" // 가상계좌 입금기간 제한 ( yyyy-mm-dd 포멧으로 입력해주세요. 가상계좌만 적용됩니다. 오늘 날짜보다 더 뒤(미래)여야 합니다 )
         //            $0.method = "card" // 결제수단
         $0.methods = ["card", "phone"]
         $0.sms_use = true
         $0.ux = "BOOTPAY_REMOTE_PRE"
      }
      var items = [BootpayItem]()
      items.append(item1)
      items.append(item2)
      
      let smsPayload = SMSPayload()
      smsPayload.params {
         $0.msg = "결제링크 안내입니다\n[결제링크]"
         $0.sp = "010-1234-4678"
         $0.rps = ["010-1234-4678"]
      }
      
      Bootpay.request(self, sendable: self, payload: payload, user: bootUser, items: items, smsPayload: smsPayload)
//      Bootpay.request_pre(request, user: bootUser, items: items, extra: nil, smsPayload: smsPayload, remotePre: nil)
      
   }
    
   override func didReceiveMemoryWarning() {
       super.didReceiveMemoryWarning()
       // Dispose of any resources that can be recreated.
   }
}


//MARK: Bootpay Event Handle
extension NativeController {
    func sendAnaylticsUserLogin() {
        Bootpay.sharedInstance.user.params {
            $0.id = "testUser" // user 고유 id 혹은 로그인 아이디
            $0.username = "홍\"길'동" // user 이름
            $0.email = "testUser@gmail.com" // user email
            $0.gender = 1 // 1: 남자, 0: 여자
            $0.birth = "861014" // user 생년월일 앞자리
            $0.phone = "01012345678" // user 휴대폰 번호
            $0.area = "서울" // 서울|인천|대구|대전|광주|부산|울산|경기|강원|충청북도|충북|충청남도|충남|전라북도|전북|전라남도|전남|경상북도|경북|경상남도|경남|제주|세종 중 택 1
        }
        BootpayAnalytics.postLogin()
    }
    
    func sendAnaylticsPageCall() {
        let item1 = BootpayStatItem().params {
            $0.item_name = "마\"우'스" // 주문정보에 담길 상품명
            $0.item_img = "https://image.mouse.com/1234" // 해당 상품의 주문 수량
            $0.unique = "ITEM_CODE_MOUSE" // 해당 상품의 고유 키
        }
        let item2 = BootpayStatItem().params {
            $0.item_name = "키보드" // 주문정보에 담길 상품명
            $0.item_img = "https://image.keyboard.com/12345" // 해당 상품의 주문 수량
            $0.unique = "ITEM_CODE_KEYBOARD" // 해당 상품의 고유 키
            $0.cat1 = "패션"
            $0.cat2 = "여성상의"
            $0.cat3 = "블라우스"
        }
        
        //        BootpayAnalytics.sharedInstance.start("ItemViewController", "ItemDetail")
        BootpayAnalytics.start("ItemViewController", "ItemDetail", items: [item1, item2])
    }
    
    func presentBootpayController() {
      
        // 통계정보를 위해 사용되는 정보
        // 주문 정보에 담길 상품정보로 배열 형태로 add가 가능함
        let item1 = BootpayItem().params {
            $0.item_name = "미\"키's 마우스" // 주문정보에 담길 상품명
            $0.qty = 1 // 해당 상품의 주문 수량
            $0.unique = "ITEM_CODE_MOUSE" // 해당 상품의 고유 키
            $0.price = 1000 // 상품의 가격
        }
        let item2 = BootpayItem().params {
            $0.item_name = "키보드" // 주문정보에 담길 상품명
            $0.qty = 1 // 해당 상품의 주문 수량
            $0.unique = "ITEM_CODE_KEYBOARD" // 해당 상품의 고유 키
            $0.price = 10000 // 상품의 가격
            $0.cat1 = "패션"
            $0.cat2 = "여\"성'상의"
            $0.cat3 = "블라우스"
        }
        
        // 커스텀 변수로, 서버에서 해당 값을 그대로 리턴 받음
        let customParams: [String: String] = [
            "callbackParam1": "value12",
            "callbackParam2": "value34",
            "callbackParam3": "value56",
            "callbackParam4": "value78",
            ]
        
        // 구매자 정보
        let bootUser = BootpayUser()
         bootUser.params {
            $0.username = "사용자 이름"
            $0.email = "user1234@gmail.com"
            $0.area = "서울" // 사용자 주소
            $0.phone = "010-1234-4567"
         }
      
         let payload = BootpayPayload()
         payload.params {
            $0.price = 1000 // 결제할 금액
            $0.name = "블링블링's 마스카라" // 결제할 상품명
            $0.order_id = "1234_1234_124" // 결제 고유번호
            $0.params = customParams // 커스텀 변수
            $0.application_id = "5b8f6a4d396fa665fdc2b5e9"
//            $0.application_id = "5b9f51264457636ab9a07cdd"
            
//
   //         $0.user_info = bootUser
            $0.pg = BootpayPG.NICEPAY // 결제할 PG사
            //            $0.account_expire_at = "2018-09-25" // 가상계좌 입금기간 제한 ( yyyy-mm-dd 포멧으로 입력해주세요. 가상계좌만 적용됩니다. 오늘 날짜보다 더 뒤(미래)여야 합니다 )
//                        $0.method = "card" // 결제수단
            $0.show_agree_window = false
            $0.method = Method.CARD
            $0.ux = UX.PG_DIALOG
         }
      
         let extra = BootpayExtra()
      
         extra.quotas = [0, 2, 3] // 5만원 이상일 경우 할부 허용범위 설정 가능, (예제는 일시불, 2개월 할부, 3개월 할부 허용)
//         extra.locale = "en"
      
         var items = [BootpayItem]()
         items.append(item1)
         items.append(item2)
      
      Bootpay.request(self, sendable: self, payload: payload, user: bootUser, items: items, extra: extra, addView: true)
    }
}


//MARK: Bootpay Callback Protocol
extension NativeController: BootpayRequestProtocol {
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
            Bootpay.transactionConfirm(data: data) // 결제 승인
        } else { // 재고가 없어 중간에 결제창을 닫고 싶을 경우
            Bootpay.dismiss()
        }
    }
    
    // 결제 취소시 호출
    func onCancel(data: [String: Any]) {
        print(data)
    }
    
    // 결제완료시 호출
    // 아이템 지급 등 데이터 동기화 로직을 수행합니다
    func onDone(data: [String: Any]) {
        print("onDone")
        print(data)
    }
    
    //결제창이 닫힐때 실행되는 부분
    func onClose() {
        print("close")
        Bootpay.dismiss()
    }
}
