//
//  BootpayAuthController.swift
//  Alamofire
//
//  Created by Taesup Yoon on 12/10/2020.
//

import UIKit
import Alamofire
import SwiftOTP
import SnapKit
import JGProgressHUD
import LocalAuthentication

@objc open class BootpayAuthController: UIViewController {
    @objc public var userToken = ""
    @objc public var sendable: BootpayRequestProtocol?
    @objc public var user = BootpayUser()
    @objc public var extra = BootpayExtra()
    @objc public var items = [BootpayItem]()
//    var quotaTextField : UITextField?
    var toolBar = UIToolbar()
    var picker  = UIPickerView()
    var btnPicker = UIButton()
    var selectedQuotaRow = -1
    var theme = BootpayBioTheme()
    
    var bioWebView = BootpayAuthWebView()
    var bootpayWebview: BootpayWebView?
    
    
    let hideBtn = UIButton()
    let actionView = UIView()
    var pay_server_unixtime = 0 //결제용
//    var bioAuthType = 1 //1: 결제, 2: 비밀번호로 결제, 3: 카드생성, 4: 카드삭제, 5: 이 기기에서 활성화
    var bottomTitle: UILabel?
    
    private let bt1 = "이 카드로 결제합니다"
    private let bt2 = "새로운 카드를 등록합니다"
    private let bt3 = "다른 결제수단으로 결제합니다"
    
    var selectedCardIndex = 0
    var actionViewHeight = CGFloat(0)
    var cardInfoList = [CardInfo]()
    var isEnableDeviceSoon = false
     
    var currentDeviceBioType = false
    
    
    @objc public var bioPayload: BootpayBioPayload?
    
    var cardSelectView: CardSelectView!
    let hud = JGProgressHUD()
    
    var isShowCloseMsg = true
    var isWebViewPay = false
    
    override public func viewDidLoad() {
        super.viewDidLoad() 
        
        initUI()
        slideUpCardUI()
        
        currentDeviceBioType = BioMetricAuthenticator.canAuthenticate()
        
        if(currentDeviceBioType) {
            getWalletCardRequest()
        } else {
            goWebViewPay(isPasswordPay: true) 
        }
    }
     
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isShowCloseMsg == true {
            var data = [String : Any]()
            data["message"] = "사용자가 창을 닫았습니다."
            data["action"] = "BootpayCancel"
            data["code"] = -102            
            sendable?.onCancel(data: data)
            sendable?.onClose()
        }
    }
    
    func initUI() {
        hideBtn.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        hideBtn.addTarget(self, action: #selector(hideActionView), for: .touchUpInside)
        self.view.addSubview(hideBtn)
        
        
        var bottomPadding = CGFloat(0)
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.keyWindow
            bottomPadding = window?.safeAreaInsets.bottom ?? 0.0
        }
        if isShowQuota() {
            bottomPadding += 60
        }
        
        //line1 + line2 + line 3 + 170 + 28 + 50 + 28
        if let payload = bioPayload {
            actionViewHeight = CGFloat(50 + 21 + payload.names.count * 25 + 21 + 25 * payload.prices.count + 36 + 170 + 28 + 50 + 28 + 10 + 6) + bottomPadding
        } else {
            actionViewHeight = self.view.frame.height * 0.72
        }
        
        
        initCardUI()
        initWebViewUI()
    }
    
    func initCardUI() {
        actionView.backgroundColor = theme.bgColor
//            UIColor.init(red: 0.98, green: 0.98, blue: 0.98, alpha: 1.0)
        actionView.frame = CGRect(x: 0, y: self.view.frame.height, width: self.view.frame.width, height: actionViewHeight)
        self.view.addSubview(actionView)
        
    }
    
    func initWebViewUI() {
//        startBiometricPayUI([])
        
      

        bioWebView.frame = CGRect(x: self.view.frame.width,
                          y: 0,
                          width: self.view.frame.width,
                          height: self.view.frame.height - 50
        )
        bioWebView.userToken = userToken
        bioWebView.sendable = self
        bioWebView.alpha = 0
        self.view.addSubview(bioWebView)
        bioWebView.loadFirst()
    }
    
    func getOTPValue(_ biometricSecretKey: String, serverTime: Int) -> String {
        if let data = biometricSecretKey.base32DecodedData {
            if let totp = TOTP(secret: data, digits: 8, timeInterval: 30, algorithm: .sha512) {
                if let otpString = totp.generate(secondsPast1970: serverTime) {
                    return otpString;
                }
            }
        }
        return "";
    }
    
    func authRegisterBiometricOTP(_ biometricSecretKey: String, serverTime: Int) {
        
        let value = getOTPValue(biometricSecretKey, serverTime: serverTime)
        registerBiometricOTP(value)
    }
    
    func getWalletCardRequest() {
        let headers: HTTPHeaders = [
            "BOOTPAY-DEVICE-UUID": Bootpay.getUUID(),
            "BOOTPAY-USER-TOKEN": userToken,
            "Accept": "application/json"
        ]
        
         
        
        AF.request("https://api.bootpay.co.kr/app/easy/card/wallet", method: .get, headers: headers)
                 .validate()
                 .responseJSON { response in
                    switch response.result {
                    case .success(let value):
                        guard let res = value as? [String: AnyObject] else { return }
                        guard let data = res["data"] as? [String: AnyObject] else { return }
                        guard let user = data["user"] as? [String: AnyObject] else { return }
                        guard let wallets = data["wallets"] as? [String: AnyObject] else { return }
                        
                        if let use_biometric = user["use_biometric"] as? Int, let use_device_biometric = user["use_device_biometric"] as? Int {
                            BootpayDefault.setValue("use_biometric", value: use_biometric)
                            BootpayDefault.setValue("use_device_biometric", value: use_device_biometric)
                        }
                        
//                        print(user)
                        
                        if let server_unixtime = user["server_unixtime"] as? CLong {
                            self.pay_server_unixtime = server_unixtime
                        }
                       self.startBiometricPayUI(wallets["card"] as? NSArray)
                    case .failure(_):
                        if let data = response.data {
                            if let jsonString = String(data: data, encoding: String.Encoding.utf8), let json = jsonString.convertToDictionary() {
                                if let code = json["code"] as? Int, let msg = json["message"] as? String {
                                    self.showAlert(title: "에러코드: \(code)", message: msg)
                                }
                            }
                        }
                    }
             }
    }
    
    func startBiometricPayUI(_ cardList: NSArray?) {
        self.cardInfoList.removeAll()
        
        if let cardList = cardList {
            for card in cardList {
                if let obj = card as? [String: AnyObject] {
                    let cardInfo = CardInfo()
                    cardInfo.setData(obj)
                    self.cardInfoList.append(cardInfo)
                }
            }
        }
        
        appendCardUI()
        if let cardList = cardList {
            self.bottomTitle?.text = self.bt1
        } else {
            self.bottomTitle?.text = self.bt2
        }
        
        if isEnableDeviceSoon == true {
            goBiometricAuth()
        }
    }
    
    
    func slideUpCardUI() {
        UIView.animate(withDuration: 0.3, animations: {
            self.actionView.frame = CGRect(x: 0,
                                           y: self.view.frame.height - self.actionViewHeight,
                                           width: self.view.frame.width,
                                           height: self.actionViewHeight)
        })
    }
    
    func slideLeftCardUI() {
        bioWebView.alpha = 1
        UIView.animate(withDuration: 0.25, animations: {
            self.actionView.frame = CGRect(x: -self.view.frame.width,
                                           y: self.actionView.frame.origin.y,
                                           width: self.view.frame.width,
                                           height: self.actionView.frame.height)
            
            self.bioWebView.frame = CGRect(x: 0,
                                   y: 0,
                                   width: self.bioWebView.frame.width,
                                   height: self.bioWebView.frame.height)
            
            self.bootpayWebview?.frame = CGRect(x: 0,
                                   y: 0,
                                   width: self.bootpayWebview?.frame.width ?? 0,
                                   height: self.bootpayWebview?.frame.height ?? 0)
        })
    }
    
    func slideRightCardUI() {
        UIView.animate(withDuration: 0.25, animations: {
            self.actionView.frame = CGRect(x: 0,
                                           y: self.actionView.frame.origin.y,
                                           width: self.view.frame.width,
                                           height: self.actionView.frame.height)
            
            self.bioWebView.frame = CGRect(x: self.view.frame.width,
                                   y: 0,
                                   width: self.bioWebView.frame.width,
                                   height: self.bioWebView.frame.height)
            
            self.bootpayWebview?.frame = CGRect(x: self.view.frame.width,
                                   y: 0,
                                   width: self.bootpayWebview?.frame.width ?? 0,
                                   height: self.bootpayWebview?.frame.height ?? 0)
        }, completion: { finished in
            self.bioWebView.alpha = 0
            self.bootpayWebview?.alpha = 0
        })
    }
    
    func appendCardUI() {
        guard let payload = bioPayload else { return }
        
        for sub in actionView.subviews {
            sub.removeFromSuperview()
        }
        
        if let logo = payload.logoImage {
            let logoImage = UIImageView()
            logoImage.image = logo
            logoImage.contentMode = .scaleAspectFit
            actionView.addSubview(logoImage)
            logoImage.snp.makeConstraints { (make) -> Void in
                make.left.equalToSuperview().offset(10)
                make.top.equalToSuperview().offset(5)
                make.height.equalTo(25)
            }
        } else {
            let pgLabel = UILabel()
            pgLabel.text = PGName.getName(payload.pg)
            pgLabel.textColor = theme.fontColor
            actionView.addSubview(pgLabel)
            pgLabel.snp.makeConstraints { (make) -> Void in
                make.left.equalToSuperview().offset(10)
                make.top.equalToSuperview().offset(10)
                make.height.equalTo(30)
            }
        }
        
        
        
        
        let btnCancel = UIButton()
        btnCancel.setTitle("취소", for: .normal)
        btnCancel.addTarget(self, action: #selector(hideActionView), for: .touchUpInside)
        btnCancel.contentHorizontalAlignment = .right
        btnCancel.setTitleColor(theme.fontColor.withAlphaComponent(0.7), for: .normal)
        actionView.addSubview(btnCancel)
        btnCancel.snp.makeConstraints { (make) -> Void in
            make.right.equalToSuperview().offset(-10)
            make.top.equalToSuperview().offset(10)
            make.width.equalTo(100)
            make.height.equalTo(30)
        }
//        btnCancel.frame = CGRect(x: 10, y: 10, width: 100, height: 20)
        
        
        let line1 = UIView()
        line1.backgroundColor = theme.fontColor.withAlphaComponent(0.1)
//            UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.1)
        actionView.addSubview(line1)
        line1.snp.makeConstraints{ (make) -> Void in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalTo(50)
            make.height.equalTo(1)
        }
        
        for (index, value) in payload.names.enumerated() {
            if index == 0 {
                let left = UILabel()
                left.text = "결제정보"
                left.textColor = theme.fontColor.withAlphaComponent(0.7)
                actionView.addSubview(left)
                left.snp.makeConstraints { (make) -> Void in
                    make.left.equalToSuperview().offset(10)
                    make.top.equalTo(line1).offset(11)
                    make.height.equalTo(30)
                }
            }

            let right = UILabel()
            right.text = value
            right.textColor = theme.fontColor
            right.font = right.font.withSize(14.0)
            actionView.addSubview(right)
            right.snp.makeConstraints { (make) -> Void in
                make.right.equalToSuperview().offset(-10)
                make.top.equalTo(line1).offset(11 + index * 25)
                make.height.equalTo(20)
            }
        }
         
        
        
        let view2 = UIView()
        //        view.frame = CGRect(x: 0, y: 40, width: self.view.frame.width, height: 1)
        view2.backgroundColor = theme.fontColor.withAlphaComponent(0.1)
        actionView.addSubview(view2)
        view2.snp.makeConstraints{ (make) -> Void in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalTo(line1).offset(21 + payload.names.count * 25)
            make.height.equalTo(1)
        }
        
        for (index, priceInfo) in payload.prices.enumerated() {
            let left = UILabel()
            left.text = priceInfo.name
            left.textColor = theme.fontColor.withAlphaComponent(0.7)

            left.font = left.font.withSize(14.0)
            actionView.addSubview(left)
            left.snp.makeConstraints { (make) -> Void in
                make.left.equalToSuperview().offset(100)
                make.top.equalTo(view2).offset(16 + 25 * index)
                make.height.equalTo(20)
            }
           
            let right = UILabel()
            right.text = priceInfo.price.comma() + "원"
            right.textColor = theme.fontColor
            right.font = right.font.withSize(14.0)
            actionView.addSubview(right)
            right.snp.makeConstraints { (make) -> Void in
                make.right.equalToSuperview().offset(-10)
                make.top.equalTo(view2).offset(16 + index * 25)
                make.height.equalTo(20)
            }
        }
         
        let left = UILabel()
        left.text = "총 결제금액"
        left.textColor = theme.fontColor
        left.font = UIFont.boldSystemFont(ofSize: 14)
        actionView.addSubview(left)
        left.snp.makeConstraints { (make) -> Void in
            make.left.equalToSuperview().offset(100)
            make.top.equalTo(view2).offset(21 + 25 * payload.prices.count)
            make.height.equalTo(30)
        }

        let right = UILabel()
        right.text = payload.price.comma() + "원"
        right.textColor = theme.fontColor
        right.textAlignment = .right
        right.font = UIFont.boldSystemFont(ofSize: 16.0)
        actionView.addSubview(right)
        right.snp.makeConstraints { (make) -> Void in
            make.right.equalToSuperview().offset(-10)
            make.top.equalTo(left)
            make.height.equalTo(20)
        }
        
      
        
        if isShowQuota() {
            
            
            let view = UIView()
            view.backgroundColor = theme.fontColor.withAlphaComponent(0.1)
            actionView.addSubview(view)
            view.snp.makeConstraints{ (make) -> Void in
                make.left.equalToSuperview()
                make.right.equalToSuperview()
                make.top.equalTo(left).offset(38)
                make.height.equalTo(1)
            }
            
            let left = UILabel()
            left.text = "할부설정"
            left.textColor = theme.fontColor.withAlphaComponent(0.7)
            left.font = left.font.withSize(14.0)
            actionView.addSubview(left)
            left.snp.makeConstraints { (make) -> Void in
                make.left.equalToSuperview().offset(100)
                make.top.equalTo(view).offset(20)
                make.height.equalTo(20)
            }
            
            let pickerImg = UIImageView()
            pickerImg.image = UIImage.fromBundle("selectbox_icon")
            pickerImg.contentMode = .scaleAspectFit
            actionView.addSubview(pickerImg)
            pickerImg.snp.makeConstraints{ (make) -> Void in
                make.right.equalToSuperview().offset(-20)
                make.width.equalTo(20)
                make.top.equalTo(view).offset(20)
                make.height.equalTo(20)
            }

            btnPicker.setTitle(getPickerTitle(row: 0), for: .normal)
            btnPicker.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            btnPicker.addTarget(self, action: #selector(showQuotaPicker), for: .touchUpInside)
            btnPicker.contentHorizontalAlignment = .right
            btnPicker.layer.borderColor = theme.fontColor.withAlphaComponent(0.1).cgColor
            btnPicker.layer.borderWidth = 1
            btnPicker.layer.cornerRadius = 5
            btnPicker.setTitleColor(theme.fontColor, for: .normal)
            btnPicker.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 35)
            actionView.addSubview(btnPicker)
            btnPicker.snp.makeConstraints{ (make) -> Void in
//                make.left.equalTo(100)
                make.right.equalToSuperview().offset(-10)
                make.width.equalTo(160)
                make.top.equalTo(view).offset(10)
                make.height.equalTo(40)
            }
        }
        

        let view3 = UIView()
        //        view.frame = CGRect(x: 0, y: 40, width: self.view.frame.width, height: 1)
        view3.backgroundColor = theme.fontColor.withAlphaComponent(0.1)
        actionView.addSubview(view3)
        view3.snp.makeConstraints{ (make) -> Void in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            if isShowQuota() {
                make.top.equalTo(left).offset(98)
            } else {
                make.top.equalTo(left).offset(38)
            }
            make.height.equalTo(1)
        }
         
        cardSelectView = CardSelectView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 150))
        cardSelectView.parent = self 
        actionView.addSubview(cardSelectView)
        cardSelectView.snp.makeConstraints{ (make) -> Void in
            make.centerX.equalToSuperview()
            make.top.equalTo(view3)
            make.width.equalToSuperview()
            make.height.equalTo(150)
        }
        cardSelectView.setData(cardInfoList)
        cardSelectView.addCarousel()



        let bottomTitle = UILabel()
        bottomTitle.text = self.bt2
        bottomTitle.font =  bottomTitle.font.withSize(14)
        bottomTitle.textColor = theme.fontColor.withAlphaComponent(0.7)
        actionView.addSubview(bottomTitle)
        self.bottomTitle = bottomTitle
        bottomTitle.snp.makeConstraints{ (make) -> Void in
            make.centerX.equalToSuperview()
            make.top.equalTo(cardSelectView).offset(152)
            make.height.equalTo(20)
        }




        let btnBarcode = UIButton()
        if let image =  UIImage.fromBundle("barcode") {
            btnBarcode.setImage(image, for: .normal)
        }


        actionView.addSubview(btnBarcode)
        btnBarcode.snp.makeConstraints{ (make) -> Void in
            make.centerX.equalToSuperview()
            make.top.equalTo(bottomTitle).offset(30)
            make.width.height.equalTo(50)
        }
        btnBarcode.addTarget(self, action: #selector(clickBarcode), for: .touchUpInside)
    }
    
    @objc func clickBarcode() {
        goClickCard(cardSelectView.scalingCarousel.lastCurrentCenterCellIndex?.row ?? 0)
    }
    
    @objc public func clickCard(_ tag: Int) {
        goClickCard(tag)
    }
    
    func goClickCard(_ index: Int) {
        if index < cardInfoList.count {
            isWebViewPay = false
            //결제수단 선택
            self.selectedCardIndex = index
            if isEnableBioPayThisDevice() {
                goBiometricAuth()
            } else {
                goEnableThisDevice()
            }
            
            
        } else if index == cardInfoList.count {
            //new card
            goBiometricAddNewCard()
        } else if index == cardInfoList.count + 1 {
            //etc
            goWebViewPay(isPasswordPay: false)
        }
    }
    
    func goBiometricAddNewCard() {
        self.bioWebView.request_type = BootpayAuthWebView.REQUEST_TYPE_REGISTER_CARD
        slideLeftCardUI()
        self.bioWebView.alpha = 1.0
        self.bioWebView.registerCard()
    }
    
    func goWebViewPay(isPasswordPay: Bool) {
        isWebViewPay = true
        isShowCloseMsg = false
        if let wv = bootpayWebview {
            wv.removeFromSuperview()
        }
        
        if bootpayWebview == nil { bootpayWebview = BootpayWebView() }
//
       var bottomPadding = CGFloat(0.0)
       if #available(iOS 11.0, *) {
           let window = UIApplication.shared.keyWindow
           bottomPadding = window?.safeAreaInsets.bottom ?? 0.0
       }


       bootpayWebview?.frame = CGRect(x: self.view.frame.width,
                         y: 0,
                         width: self.view.frame.width,
                         height: self.view.frame.height - bottomPadding - 50
       )
        if(isPasswordPay == true) { bioPayload?.user_token = userToken; }
        else { bioPayload?.user_token = "" }
        
        let script = bioPayload?.generateScript(bootpayWebview?.bridgeName ?? "", items: items, user: user, extra: extra, isPasswordPay: isPasswordPay)


//       // 필요한 PG는 팝업으로 띄운다
       var quick_popup = extra.quick_popup;
       if(quick_popup == -1 && bioPayload?.pg != "payapp" && bioPayload?.method == "card") {
           quick_popup = 1;
       }

       if(quick_popup == 1) {
        
        bootpayWebview?.bootpayRequest(script ?? "", quick_popup: quick_popup)
       } else {
        bootpayWebview?.bootpayRequest(script ?? "")
       }

       bootpayWebview?.sendable = self.sendable
       bootpayWebview?.parentController = self
       self.view.addSubview(bootpayWebview!)
        
       slideLeftCardUI()
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
    //            $0.username = "사용자 이름"
                $0.email = "user1234@gmail.com"
                $0.area = "서울" // 사용자 주소
                $0.addr = "서울시 동작구 상도로";
                $0.phone = "010-1234-4567"
             }
          
             let payload = BootpayPayload()
             payload.params {
                $0.price = 1000 // 결제할 금액, 정기결제시 0 혹은 주석
                $0.name = "테스트's 마스카라" // 결제할 상품명
                $0.order_id = "1234_1234_124" // 결제 고유번호
                $0.params = customParams // 커스텀 변수
                $0.application_id = "5b8f6a4d396fa665fdc2b5e9"
                
                
                $0.pg = BootpayPG.KCP // 결제할 PG사
                //            $0.account_expire_at = "2018-09-25" // 가상계좌 입금기간 제한 ( yyyy-mm-dd 포멧으로 입력해주세요. 가상계좌만 적용됩니다. 오늘 날짜보다 더 뒤(미래)여야 합니다 )
    //                        $0.method = "card" // 결제수단
                $0.show_agree_window = false
                $0.methods = [Method.BANK, Method.CARD, Method.PHONE, Method.VBANK]
    //            $0.method = Method.CARD
                $0.ux = UX.PG_DIALOG
             }
          
             let extra = BootpayExtra()
             extra.popup = 1
          
    //         extra.offer_period = "1년치"
    //         extra.quick_popup = 1;
             extra.quotas = [0, 2, 3] // 5만원 이상일 경우 할부 허용범위 설정 가능, (예제는 일시불, 2개월 할부, 3개월 할부 허용)
             extra.theme = "red"
    //         extra.app_scheme = "test://"; // 페이레터와 같은 특정 PG사의 경우 :// 값을 붙여야 할 수도 있습니다.


          //   close 버튼을 커스텀하기
    //         let close = UIButton()
    //         close.setTitle("XX", for: .normal)
    //         close.frame = CGRect(x: self.view.frame.width - 40, y: 20, width: 40, height: 30)
    //         close.setTitleColor(.darkGray, for: .normal)
    //         extra.iosCloseButtonView = close
    //         extra.iosCloseButton = true
          
             var items = [BootpayItem]()
             items.append(item1)
             items.append(item2)
          
        Bootpay.request(self, sendable: self.sendable, payload: payload, user: bootUser, items: items, extra: extra, addView: true)
        }
    
    
    
    
    @objc func hideActionView() {
        isShowCloseMsg = true 
        self.dismiss(animated: true, completion: nil)
    }
    
    func goBiometricPayRequest(_ token: String?) {
        if cardInfoList.count == 0 {
            print("등록된 카드가 없습니다")
            return
        }
        guard let bioPayload = bioPayload else {
            print("bioPayload 값이 없습니다")
            return
        }
        if bioPayload.name.count == 0 {
            print("bioPayload.name 값이 없습니다")
            return
        }
//        guard let application_id = bioPayload.application_id else {
//            print("bioPayload.application_id 값이 없습니다")
//            return
//        }
        
        var params = [String: Any]()
        if let token = token {
            params["password_token"] = token
        } else {
            params["otp"] = getOTPValue(BootpayDefault.getString(key: "biometric_secret_key"), serverTime: self.pay_server_unixtime)
        }
        
        params["wallet_id"] = cardInfoList[selectedCardIndex].wallet_id
        params["request_data"] = [
            "application_id": bioPayload.application_id,
            "order_id": bioPayload.order_id,
            "price": bioPayload.price,
            "name": bioPayload.name
        ]
        
        let headers: HTTPHeaders = [
            "BOOTPAY-DEVICE-UUID": Bootpay.getUUID(),
            "BOOTPAY-USER-TOKEN": userToken,
            "Accept": "application/json"
        ]
         
         
        
        hud.textLabel.text = "결제 요청중"
        hud.show(in: self.view)
        
        isShowCloseMsg = false
        
        AF.request("https://api.bootpay.co.kr/app/easy/card/request", method: .post, parameters: params, headers: headers)
                 .validate() 
                 .responseJSON { response in
                    self.hud.dismiss(afterDelay: 0.5)
                    switch response.result {
                    case .success(let value):
                        guard let res = value as? [String: AnyObject] else { return }
                        self.sendable?.onConfirm(data: res)
                    case .failure(_):
                        if let data = response.data {
                            if let jsonString = String(data: data, encoding: String.Encoding.utf8), let json = jsonString.convertToDictionary() {
                                if let code = json["code"] as? Int, let msg = json["message"] as? String {
                                    self.showAlert(title: "에러코드: \(code)", message: msg)
                                }
                                self.sendable?.onConfirm(data: json)
                            }
                        }
                    }
        }
    }
}

extension BootpayAuthController: BootpayAuthProtocol {
    public func easyCancel(data: [String : Any]) {
        slideRightCardUI()
        if let msg = data["message"] as? String {
            self.showAlert(title: "취소", message: msg)
        }
    }
    
    public func easyError(data: [String : Any]) {
        slideRightCardUI()
        getWalletCardRequest()
        
        if let msg = data["message"] as? String {
            self.showAlert(title: "에러", message: msg)
        }
    }
    
    public func easySuccess(data: [String : Any]) {
        if (self.bioWebView.request_type == BootpayAuthWebView.REQUEST_TYPE_VERIFY_PASSWORD) {
            if let sub = data["data"], let token = (sub as! [String: Any])["token"] {
                 registerBiometricRequest(token as! String)
            }
        } else if(self.bioWebView.request_type == BootpayAuthWebView.REQUEST_TYPE_VERIFY_PASSWORD_FOR_PAY) {
            if let sub = data["data"], let token = (sub as! [String: Any])["token"] {
                goBiometricPayRequest(token as? String)
            }
        }
        else if(self.bioWebView.request_type == BootpayAuthWebView.REQUEST_TYPE_REGISTER_CARD) {
            slideRightCardUI()
            getWalletCardRequest()
        } else if(self.bioWebView.request_type == BootpayAuthWebView.REQUEST_TYPE_PASSWORD_CHANGE) {
            slideRightCardUI()
            getWalletCardRequest()
        } else if(self.bioWebView.request_type == BootpayAuthWebView.REQUEST_TYPE_ENABLE_DEVICE) {
            isEnableDeviceSoon = true 
            if let sub = data["data"], let token = (sub as! [String: Any])["token"] {
                registerBiometricRequest(token as! String)
            }
        }
        
        
//        if let d = data["data"] as? [String : Any], let wallet_id = d["wallet_id"] {
//            slideRightCardUI()
//            getWalletCardRequest()
//        } else {
//            //alert error
//            var error = ""
//            if let msg = data["message"] as? String { error = msg }
//            self.showGotoSettingsAlert(message: "등록 과정에서 에러가 발생하였습니다. \(error)")
//        }
        
//        ["data": {
//            "wallet_id" = 5f8906b885cd5803be749cee;
//        }, "message": 카드 등록이 완료되었습니다., "code": 0, "action": BootpayEasySuccess]
        //생체인식을 등록하시겠습니까? 하고 등록함
//        카드를 다시 불러온 후
//        slideRightCardUI()
    }
}

extension BootpayAuthController {
    
//    func registerBiometric(_ token: String) {
//        //지문을 받는다
//        //성공시 등록한다
//        registerBiometricRequest(token)
//    }
    
    //지문결제를 하기 위한 기기 활성화
    func registerBiometricRequest(_ token: String) {
       
        
        var params = [String: Any]()
        params["password_token"] = token
        params["os"] = "ios"
        
        let headers: HTTPHeaders = [
            "BOOTPAY-DEVICE-UUID": Bootpay.getUUID(),
            "BOOTPAY-USER-TOKEN": userToken,
            "Accept": "application/json"
        ]
        
        hud.textLabel.text = "보안 강화중"
        hud.show(in: self.view)
        
        
        AF.request("https://api.bootpay.co.kr/app/easy/biometric", method: .post, parameters: params, headers: headers)
                 .validate()
                 .responseJSON { response in
                    self.hud.dismiss(afterDelay: 0.5)
                    switch response.result {
                    case .success(let value):
                        guard let res = value as? [String: AnyObject] else { return }
                        guard let data = res["data"] as? [String: AnyObject] else { return }
                        if let biometric_secret_key = data["biometric_secret_key"] as? String, let biometric_device_id = data["biometric_device_id"] as? String, let server_unixtime = data["server_unixtime"] as? CLong {
                             
                            BootpayDefault.setValue("biometric_secret_key", value: biometric_secret_key)
                            BootpayDefault.setValue("biometric_device_id", value: biometric_device_id)
                            
                            self.slideRightCardUI()
                            
                            self.authRegisterBiometricOTP(biometric_secret_key, serverTime: server_unixtime)
                            
                        }
                        
                    case .failure(_):
                        if let data = response.data {
                            if let jsonString = String(data: data, encoding: String.Encoding.utf8),  let json = jsonString.convertToDictionary() {
                                if let code = json["code"] as? Int, let msg = json["message"] as? String {
                                    self.showAlert(title: "에러코드: \(code)", message: msg)
                                }
                            }
                        }
                    }
 
             }
    }
    
    func goDeleteCardAll(wallet_id: String) {
        let headers: HTTPHeaders = [
            "BOOTPAY-DEVICE-UUID": Bootpay.getUUID(),
            "BOOTPAY-USER-TOKEN": userToken,
            "Accept": "application/json"
        ]
        
        hud.textLabel.text = "초기화 진행중"
        hud.show(in: self.view)
        
        AF.request("https://api.bootpay.co.kr/app/easy/card/wallet/\(wallet_id)", method: .delete, headers: headers)
                 .validate()
                 .responseJSON { response in
                    self.hud.dismiss(afterDelay: 0.5)
                     
                    switch response.result {
                    case .success(let value):
                        guard let res = value as? [String: AnyObject] else { return }
                        
                        if(res["code"] as! Int != 0) { return }
                        self.getWalletCardRequest()
                        
                    case .failure(_):
                        if let data = response.data {
                            if let jsonString = String(data: data, encoding: String.Encoding.utf8), let json = jsonString.convertToDictionary() {
                                if let code = json["code"] as? Int, let msg = json["message"] as? String {
                                    self.showAlert(title: "에러코드: \(code)", message: msg)
                                }
                            }
                        }
                    }
        }
        
    }
    
    func registerBiometricOTP(_ otp: String) {        
        var params = [String: Any]()
        params["otp"] = otp
        
        let headers: HTTPHeaders = [
            "BOOTPAY-DEVICE-UUID": Bootpay.getUUID(),
            "BOOTPAY-USER-TOKEN": userToken,
            "Accept": "application/json"
        ]
        
//        print(params)
        
        hud.textLabel.text = "보안 추가중"
        hud.show(in: self.view)
        
        AF.request("https://api.bootpay.co.kr/app/easy/biometric/register", method: .post, parameters: params, headers: headers)
                 .validate()
                 .responseJSON { response in
                    self.hud.dismiss(afterDelay: 0.5)
                     
                    switch response.result {
                    case .success(let value):
                        guard let res = value as? [String: AnyObject] else { return }
                        guard let data = res["data"] as? [String: AnyObject] else { return }
                          
                        if let biometric_secret_key = data["biometric_secret_key"] as? String, let biometric_device_id = data["biometric_device_id"] as? String {
                            BootpayDefault.setValue("biometric_secret_key", value: biometric_secret_key)
                            BootpayDefault.setValue("biometric_device_id", value: biometric_device_id)
                                                
                            //카드리스트를 요청 후
                            self.slideRightCardUI()
                            self.getWalletCardRequest()
                                 
                                            
                        }
                    case .failure(_):
                        if let data = response.data {
                            if let jsonString = String(data: data, encoding: String.Encoding.utf8), let json = jsonString.convertToDictionary() {
                                if let code = json["code"] as? Int, let msg = json["message"] as? String {
                                    self.showAlert(title: "에러코드: \(code)", message: msg)
                                }
                            }
                        }
                    }
        }
    }
}


// MARK: - Alerts
extension BootpayAuthController {
    
    func showAlert(title: String, message: String) {
        let okAction = AlertAction(title: OKTitle)
        let alertController = getAlertViewController(type: .alert, with: title, message: message, actions: [okAction], showCancel: false) { (button) in
        }
        present(alertController, animated: true, completion: nil)
    }
    
    func showDeleteAlert(title: String, message: String, OKTitle: String = "초기화", wallet_id: String) {
        let okAction = AlertAction(title: OKTitle)
        let alertController = getAlertViewController(type: .alert, with: title, message: message, actions: [okAction], showCancel: true) { (button) in
            if(button == OKTitle) {
                self.goDeleteCardAll(wallet_id: wallet_id)
            }
//            self.dismiss()
        }
        present(alertController, animated: true, completion: nil)
    }
    
    func showLoginSucessAlert() {
        showAlert(title: "Success", message: "Login successful")
    }
    
    func showErrorAlert(message: String) {
        showAlert(title: "Error", message: message)
    }
    
    func showGotoSettingsAlert(message: String) {
        let settingsAction = AlertAction(title: "Go to settings")
        
        let alertController = getAlertViewController(type: .alert, with: "Error", message: message, actions: [settingsAction], showCancel: true, actionHandler: { (buttonText) in
            if buttonText == CancelTitle { return }
            
            // open settings
            let url = URL(string: UIApplication.openSettingsURLString)
            if UIApplication.shared.canOpenURL(url!) {
                UIApplication.shared.open(url!, options: [:])
            }
            
        })
        present(alertController, animated: true, completion: nil)
    }
    
    func goEnableThisDevice() {
        let okAction = AlertAction(title: OKTitle)
        let alertController = getAlertViewController(type: .alert, with: title, message: "이 기기에서 결제할 수 있도록 설정합니다\n(최초 1회)", actions: [okAction], showCancel: true) { (btnTitle) in
            if btnTitle == OKTitle {
                self.bioWebView.request_type = BootpayAuthWebView.REQUEST_TYPE_ENABLE_DEVICE
                self.slideLeftCardUI()
                self.bioWebView.verifyPassword()
            }
          }
        present(alertController, animated: true, completion: nil)
    }
    
}


extension BootpayAuthController {
     
    
    @objc func goBiometricAuth() {
           
        BioMetricAuthenticator.shared.allowableReuseDuration = nil
        BioMetricAuthenticator.authenticateWithBioMetrics(reason: "") { [weak self] (result) in

           
        switch result {
        case .success( _):
            self?.goBiometricPayRequest(nil)
           
        case .failure(let error):
            switch error {
               // device does not support biometric (face id or touch id) authentication
            case .biometryNotAvailable:
                self?.showErrorAlert(message: error.message())
               // No biometry enrolled in this device, ask user to register fingerprint or face
            case .biometryNotEnrolled:
                self?.showGotoSettingsAlert(message: error.message())
               // show alternatives on fallback button clicked
            case .fallback:
                print("fallback")
//                   self?.txtUsername.becomeFirstResponder() // enter username password manually
                   // Biometry is locked out now, because there were too many failed attempts.
               // Need to enter device passcode to unlock.
            case .biometryLockedout:
                
                let okAction = AlertAction(title: OKTitle)
                let alertController = self?.getAlertViewController(type: .alert, with: self?.title, message: "Touch ID 인식에 여러 번 실패하여, 비밀번호로 결제합니다.", actions: [okAction], showCancel: true) { (btnTitle) in
                    if btnTitle == OKTitle {
//                        self?.bioAuthType = 2
                        self?.bioWebView.request_type = BootpayAuthWebView.REQUEST_TYPE_VERIFY_PASSWORD_FOR_PAY
                        self?.slideLeftCardUI()
                        self?.bioWebView.verifyPassword()
                    }
                  }
                if let alertController = alertController {
                  self?.present(alertController, animated: true, completion: nil)
                }
//
                
//                print("biometryLockedout")
//                print("비밀번호로 결제를 진행하자")
//                   self?.showPasscodeAuthentication(message: error.message())
               // do nothing on canceled by system or user
            case .canceledBySystem, .canceledByUser:
                break
               // show error for any other reason
            default:
                self?.showErrorAlert(message: error.message())
               
            }
        }
        }
    }
    
    func isEnableBioPayThisDevice() -> Bool {
        return BootpayDefault.getString(key: "biometric_secret_key").count > 0 && BootpayDefault.getInt(key: "use_device_biometric") == 1 && BootpayDefault.getInt(key: "use_biometric") == 1
    }
}


extension BootpayAuthController {
    @objc public func lastIndexChanged(index: Int) {
        if index < cardInfoList.count {
            self.bottomTitle?.text = self.bt1
        } else if index == cardInfoList.count {
            self.bottomTitle?.text = self.bt2
        } else if index == cardInfoList.count + 1 {
            self.bottomTitle?.text = self.bt3
        }
    }
    
    @objc(transactionConfirm:)
    public func transactionConfirm(data: [String: Any]) {
        //rest api
        isShowCloseMsg = false
        if(isWebViewPay == false) {
            
            goTransactionConfirmRestApi(data: data)
        } else {
            let json = Bootpay.dicToJsonString(data).replace(target: "'", withString: "\\'")
            self.bootpayWebview?.doJavascript("window.BootPay.transactionConfirm(\(json));")
        }
    }
    
    func goTransactionConfirmRestApi(data: [String: Any]) {
        if let data = data["data"] as? [String: Any], let receipt_id = data["receipt_id"] as? String {
            
            var params = [String: Any]()
            params["receipt_id"] = receipt_id
                    
            let headers: HTTPHeaders = [
                "BOOTPAY-DEVICE-UUID": Bootpay.getUUID(),
                "BOOTPAY-USER-TOKEN": userToken,
                "Accept": "application/json"
            ]
            
            hud.textLabel.text = "결제 승인중"
            self.view.addSubview(hud)
            
            AF.request("https://api.bootpay.co.kr/app/easy/confirm", method: .post, parameters: params, headers: headers)
                     .validate()
                     .responseJSON { response in
                        self.hud.dismiss(afterDelay: 0.5)
                        
                        switch response.result {
                        case .success(let value):
                            guard let res = value as? [String: AnyObject] else { return }
                            self.sendable?.onDone(data: res)
                        case .failure(_):
                            if let data = response.data {
                                if let jsonString = String(data: data, encoding: String.Encoding.utf8), let json = jsonString.convertToDictionary() {
                                    self.sendable?.onError(data: json)
                                    if let code = json["code"] as? Int, let msg = json["message"] as? String {
                                        
                                        let wallet_id = self.cardInfoList[self.selectedCardIndex].wallet_id
                                       
                                        self.showDeleteAlert(title: "에러코드: \(code)\n\(msg)", message: "등록된 결제수단 정보를 초기화 합니다.", wallet_id: wallet_id)
                                    }
                                }
                            }
                        }
            }
        }
    }
    
    @objc(removePaymentWindow)
    public func removePaymentWindow() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc(dismiss)
    public func dismiss() {
        self.dismiss(animated: true, completion: nil)
    }
}


extension BootpayAuthController: UIPickerViewDataSource, UIPickerViewDelegate {
    @objc func showQuotaPicker() {
        picker = UIPickerView.init()
        picker.delegate = self
        picker.backgroundColor = theme.bgColor
        picker.setValue(theme.fontColor, forKey: "textColor")
        picker.autoresizingMask = .flexibleWidth
        picker.contentMode = .center
        if selectedQuotaRow != -1 { picker.selectRow(selectedQuotaRow, inComponent: 0, animated: true) }
        
        picker.frame = CGRect.init(x: 0.0, y: UIScreen.main.bounds.size.height - 300, width:
            UIScreen.main.bounds.size.width, height: 300)
        self.view.addSubview(picker)
        
        toolBar = UIToolbar.init(frame: CGRect.init(x: 0.0, y: UIScreen.main.bounds.size.height - 300, width: UIScreen.main.bounds.size.width, height: 45))
        toolBar.barStyle = .blackTranslucent
        toolBar.items = [UIBarButtonItem.init(title: "완료", style: .done, target: self, action: #selector(onDoneQuotaPicker))]
        self.view.addSubview(toolBar)
    }
    
    @objc func onDoneQuotaPicker() {
        toolBar.removeFromSuperview()
        picker.removeFromSuperview()
    }
    
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return extra.quotas.count
//        return bioPayload?.quotas.count ?? 0
    }
    
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return getPickerTitle(row: row)
    }
    
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//        quotaTextField?.text = "\(String(describing: bioPayload?.quotas[row]))"
//        if let payload = bioPayload {
//            btnPicker.setTitle("\(row)", for: .normal)
//
//        }
        
        selectedQuotaRow = row
        btnPicker.setTitle(getPickerTitle(row: row), for: .normal)
    }
    
    func getPickerTitle(row: Int) -> String { 
        if extra.quotas.count <= row { return "" }
        if extra.quotas[row] == 0 { return "일시불" }
        else { return "\(extra.quotas[row])개월" }
    }
    
    func isShowQuota() -> Bool {
        if let payload = bioPayload {
            return payload.price >= 50000 && extra.quotas.count > 0
        }
        return false
    }
}
