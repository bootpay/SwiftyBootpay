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

@objc public class BootpayAuthController: UIViewController {
    @objc public var userToken = ""
    var wv = BootpayAuthWebView()
    let actionView = UIView()
    var pay_server_unixtime = 0 //결제용
    var pay_wallet_id = "" //결제용
    var pay_card_name = "" //결제용
    var pay_card_no = "" //결제용
    var actionViewHeight = CGFloat(0)
    public var application_id = "5b9f51264457636ab9a07cdd"
    public var payload: BootpayPayload?
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        actionViewHeight = self.view.frame.height * 0.66
//        setUI()
        //만약 등록되어있다면,
        initCardUI()
        slideCardUI()
    }
    
    func setUI() {
        self.view.backgroundColor = UIColor.clear
//        startBiometricPayUI([])
        wv.frame = CGRect(x: 0,
                          y: 0,
                          width: self.view.frame.width,
                          height: self.view.frame.height
        )
        wv.userToken = userToken
        wv.sendable = self
        self.view.addSubview(wv)
        wv.request()
    }
    
    func getOTPValue(_ biometricSecretKey: String, serverTime: Int) -> String {
        if let data = biometricSecretKey.base32DecodedData {
            if let totp = TOTP(secret: data, timeInterval: 30, algorithm: .sha1) {
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
        ]
        
        AF.request("https://dev-api.bootpay.co.kr/app/easy/card/wallet", method: .get, headers: headers)
                 .validate()
                 .responseJSON { response in
                     print(response.value ?? "")
                    
                    guard let res = response.value as? [String: AnyObject] else { return }
                    guard let data = res["data"] as? [String: AnyObject] else { return }
                    guard let user = data["user"] as? [String: AnyObject] else { return }
                    guard let wallets = data["wallets"] as? [String: AnyObject] else { return }
                    guard let cardList = wallets["card"] as? NSArray else { return }
                    
                    if let server_unixtime = user["server_unixtime"] as? CLong {
                        self.pay_server_unixtime = server_unixtime
                    }
                    
                    self.startBiometricPayUI(cardList)
             }
    }
    
    func startBiometricPayUI(_ cardList: NSArray) {
        wv.removeFromSuperview()
        
        if(cardList.count > 0) {
            if let card = cardList[0] as? [String: AnyObject], let wallet_id = card["wallet_id"] as? String {
                self.pay_wallet_id = wallet_id
                if let d = card["d"] as? [String: AnyObject], let card_name = d["card_name"] as? String, let card_no = d["card_no"] as? String  {
                    self.pay_card_name = card_name
                    self.pay_card_no = card_no
                }
            }
        }
        
//        initCardUI()
//        slideCardUI()
        setCardUI()
    }
    
    func initCardUI() {
        actionView.backgroundColor = UIColor.init(red: 0.98, green: 0.98, blue: 0.98, alpha: 1.0)
        actionView.frame = CGRect(x: 0, y: self.view.frame.height, width: self.view.frame.width, height: actionViewHeight)
       self.view.addSubview(actionView)
        
     
       
        getWalletCardRequest()
    }
    
    func slideCardUI() {
        UIView.animate(withDuration: 0.3, animations: {
            self.actionView.frame = CGRect(x: 0,
                                           y: self.view.frame.height - self.actionViewHeight,
                                           width: self.view.frame.width,
                                           height: self.actionViewHeight)
        })
    }
    
    func setCardUI() {
        let pgLabel = UILabel()
        pgLabel.text = "KG 이니시스"
        pgLabel.textColor = UIColor.black
        actionView.addSubview(pgLabel)
        pgLabel.snp.makeConstraints { (make) -> Void in
            make.left.equalToSuperview().offset(10)
            make.top.equalToSuperview().offset(10)
            make.height.equalTo(30)
        }
        
        
        let btnCancel = UIButton()
        btnCancel.setTitle("Cancel", for: .normal)
        btnCancel.addTarget(self, action: #selector(hideActionView), for: .touchUpInside)
        btnCancel.contentHorizontalAlignment = .right
        btnCancel.setTitleColor(UIColor.darkGray, for: .normal)
        actionView.addSubview(btnCancel)
        btnCancel.snp.makeConstraints { (make) -> Void in
            make.right.equalToSuperview().offset(-10)
            make.top.equalToSuperview().offset(10)
            make.width.equalTo(100)
            make.height.equalTo(30)
        }
//        btnCancel.frame = CGRect(x: 10, y: 10, width: 100, height: 20)
        
        
        let view = UIView()
//        view.frame = CGRect(x: 0, y: 40, width: self.view.frame.width, height: 1)
        view.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.1)
        actionView.addSubview(view)
        view.snp.makeConstraints{ (make) -> Void in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalTo(50)
            make.height.equalTo(1)
        }
        
        let left1 = UILabel()
        left1.text = "결제정보"
        left1.textColor = .gray
        actionView.addSubview(left1)
        left1.snp.makeConstraints { (make) -> Void in
            make.left.equalToSuperview().offset(10)
            make.top.equalTo(view).offset(11)
            make.height.equalTo(30)
        }
        
        let right1 = UILabel()
        right1.text = "플리츠레이어 카라롱원피스"
        right1.textColor = .black
        right1.font = right1.font.withSize(14.0)
        actionView.addSubview(right1)
        right1.snp.makeConstraints { (make) -> Void in
            make.right.equalToSuperview().offset(-10)
            make.top.equalTo(view).offset(11)
            make.height.equalTo(20)
        }
        
       let right2 = UILabel()
       right2.text = "블랙 (COLOR)"
       right2.textColor = .black
       right2.font = right2.font.withSize(14.0)
       actionView.addSubview(right2)
       right2.snp.makeConstraints { (make) -> Void in
           make.right.equalToSuperview().offset(-10)
           make.top.equalTo(right1).offset(20)
           make.height.equalTo(20)
       }
        
        
       let right3 = UILabel()
       right3.text = "55 (SIZE)"
       right3.textColor = .black
       right3.font = right3.font.withSize(14.0)
       actionView.addSubview(right3)
       right3.snp.makeConstraints { (make) -> Void in
           make.right.equalToSuperview().offset(-10)
           make.top.equalTo(right2).offset(20)
           make.height.equalTo(20)
       }
        
        
        let view2 = UIView()
        //        view.frame = CGRect(x: 0, y: 40, width: self.view.frame.width, height: 1)
        view2.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.1)
        actionView.addSubview(view2)
        view2.snp.makeConstraints{ (make) -> Void in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalTo(right3).offset(30)
            make.height.equalTo(1)
        }
        
        let left2 = UILabel()
        left2.text = "상품가격"
        left2.textColor = .gray
    
        left2.font = left2.font.withSize(14.0)
        actionView.addSubview(left2)
        left2.snp.makeConstraints { (make) -> Void in
            make.left.equalToSuperview().offset(100)
            make.top.equalTo(view2).offset(11)
            make.height.equalTo(20)
        }
        
        let right22 = UILabel()
        right22.text = "89,000원"
        right22.textColor = .black
        right22.textAlignment = .right
        right22.font = right22.font.withSize(14.0)
        actionView.addSubview(right22)
        right22.snp.makeConstraints { (make) -> Void in
            make.right.equalToSuperview().offset(-10)
            make.top.equalTo(left2)
            make.height.equalTo(20)
        }
        
       let left3 = UILabel()
       left3.text = "배송비"
       left3.textColor = .gray
       left3.font = left3.font.withSize(14.0)
       actionView.addSubview(left3)
       left3.snp.makeConstraints { (make) -> Void in
           make.left.equalToSuperview().offset(100)
           make.top.equalTo(left2).offset(21)
           make.height.equalTo(20)
       }
        
        let right33 = UILabel()
        right33.text = "2,500원"
        right33.textColor = .black
        right33.textAlignment = .right
        right33.font = right33.font.withSize(14.0)
        actionView.addSubview(right33)
        right33.snp.makeConstraints { (make) -> Void in
            make.right.equalToSuperview().offset(-10)
            make.top.equalTo(left3)
            make.height.equalTo(20)
        }
        
        
        let left4 = UILabel()
        left4.text = "부가세"
        left4.textColor = .gray
        left4.font = left4.font.withSize(14.0)
        actionView.addSubview(left4)
        left4.snp.makeConstraints { (make) -> Void in
            make.left.equalToSuperview().offset(100)
            make.top.equalTo(left3).offset(21)
            make.height.equalTo(20)
        }
        
        let right44 = UILabel()
        right44.text = "9,150원"
        right44.textColor = .black
        right44.textAlignment = .right
        right44.font = right44.font.withSize(14.0)
        actionView.addSubview(right44)
        right44.snp.makeConstraints { (make) -> Void in
            make.right.equalToSuperview().offset(-10)
            make.top.equalTo(left4)
            make.height.equalTo(20)
        }
        
        
        let left5 = UILabel()
        left5.text = "총 결제금액"
        left5.textColor = .black
        left5.font = UIFont.boldSystemFont(ofSize: 14)
        actionView.addSubview(left5)
        left5.snp.makeConstraints { (make) -> Void in
            make.left.equalToSuperview().offset(100)
            make.top.equalTo(left4).offset(31)
            make.height.equalTo(30)
        }
        
        let right55 = UILabel()
        right55.text = "100,650원"
        right55.textColor = .black
        right55.textAlignment = .right
        right55.font = UIFont.boldSystemFont(ofSize: 16.0)
        actionView.addSubview(right55)
        right55.snp.makeConstraints { (make) -> Void in
            make.right.equalToSuperview().offset(-10)
            make.top.equalTo(left5)
            make.height.equalTo(20)
        }

        
        
        let view3 = UIView()
        //        view.frame = CGRect(x: 0, y: 40, width: self.view.frame.width, height: 1)
        view3.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.1)
        actionView.addSubview(view3)
        view3.snp.makeConstraints{ (make) -> Void in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalTo(left5).offset(36)
            make.height.equalTo(1)
        }
        
        let cardView = UIView()
        cardView.layer.cornerRadius = 5.0
        cardView.backgroundColor = UIColor.init(red: 254.0 / 255, green: 205.0 / 255, blue: 46.0 / 255, alpha: 1.0)
        actionView.addSubview(cardView)
        cardView.snp.makeConstraints{ (make) -> Void in
            make.centerX.equalToSuperview()
//            make.left.equalToSuperview().offset(10)
            make.top.equalTo(view3).offset(35)
            make.width.equalTo(160)
            make.height.equalTo(90)
        }
        
        let cardName = UILabel()
        cardName.text = self.pay_card_name
        cardName.font =  cardName.font.withSize(12)
        cardName.textColor = UIColor.init(red: 115.0 / 255, green: 105.0 / 255, blue: 95.0 / 255, alpha: 1.0)
        cardView.addSubview(cardName)
        cardName.snp.makeConstraints{ (make) -> Void in
            make.left.equalToSuperview().offset(10)
            make.top.equalToSuperview().offset(5)
            make.width.equalTo(100)
            make.height.equalTo(20)
        }
        
        let cardNo = UILabel()
        cardNo.text = self.pay_card_no
        cardNo.font =  cardNo.font.withSize(12)
        cardNo.textAlignment = .right
        cardNo.textColor = UIColor.init(red: 115.0 / 255, green: 105.0 / 255, blue: 95.0 / 255, alpha: 1.0)
        cardView.addSubview(cardNo)
        cardNo.snp.makeConstraints{ (make) -> Void in
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.top.equalToSuperview().offset(60)
            make.height.equalTo(20)
        }
        
        let bottomTitle = UILabel()
        bottomTitle.text = "이 카드로 결제를 진행합니다"
        bottomTitle.font =  cardNo.font.withSize(14)
        bottomTitle.textColor = UIColor.darkGray
        actionView.addSubview(bottomTitle)
        bottomTitle.snp.makeConstraints{ (make) -> Void in
            make.centerX.equalToSuperview()
            make.top.equalTo(cardView).offset(110)
            make.height.equalTo(20)
        }
         
        
        let clickBtn = UIButton()
        clickBtn.addTarget(self, action: #selector(goBiometricAuth), for: .touchUpInside)
        actionView.addSubview(clickBtn)
        clickBtn.snp.makeConstraints{ (make) -> Void in
            make.width.bottom.left.equalToSuperview()
            make.top.equalTo(view3)
        }
        
//        let barcodeImage = UIImageView()
////        barcodeImage.backgroundColor = .blue
//        barcodeImage.image = UIImage(named: "pay_barcode2")
//        actionView.addSubview(barcodeImage)
//        barcodeImage.snp.makeConstraints{ (make) -> Void in
//            make.centerX.equalToSuperview()
//            make.top.equalTo(bottomTitle).offset(30)
//            make.width.height.equalTo(50)
//        }
        //set button
//        let btn1 = UIButton(type: .custom)
//        btn1.frame = CGRect(x: 0, y: 60, width: self.view.bounds.width, height: 60)
//        btn1.setTitle("결제하기", for: .normal)
//        btn1.setTitleColor(.white, for: .normal)
//        btn1.backgroundColor = UIColor.init(red: 254.0 / 255, green: 134.0 / 255, blue: 133.0 / 255, alpha: 1)
//        btn1.addTarget(self, action: #selector(goBiometricAuth), for: .touchUpInside)
//        actionView.addSubview(btn1)
    }
    
    @objc func goBiometricAuth() {
//        BioMetricAuthenticator.shared.allowableReuseDuration = 30
//
//       // start authentication
//       BioMetricAuthenticator.authenticateWithBioMetrics(reason: "") { [weak self] (result) in
//
//           switch result {
//           case .success( _):
//               self?.goBiometricPayRequest()
//
//               // authentication successful
////               self?.showLoginSucessAlert()
//
//           case .failure(let error):
//
//               switch error {
//
//               // device does not support biometric (face id or touch id) authentication
//               case .biometryNotAvailable:
//                   self?.showErrorAlert(message: error.message())
//
//               // No biometry enrolled in this device, ask user to register fingerprint or face
//               case .biometryNotEnrolled:
//                   self?.showGotoSettingsAlert(message: error.message())
//
//               // show alternatives on fallback button clicked
//               case .fallback:
//                    print("fallback")
////                   self?.txtUsername.becomeFirstResponder() // enter username password manually
//
//                   // Biometry is locked out now, because there were too many failed attempts.
//               // Need to enter device passcode to unlock.
//               case .biometryLockedout:
//                    print("biometryLockedout")
////                   self?.showPasscodeAuthentication(message: error.message())
//
//               // do nothing on canceled by system or user
//               case .canceledBySystem, .canceledByUser:
//                   break
//
//               // show error for any other reason
//               default:
//                   self?.showErrorAlert(message: error.message())
//               }
//           }
//       }
    }
    
    @objc func hideActionView() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func goBiometricPayRequest() {
        var params = [String: Any]()
        params["otp"] = getOTPValue(BootpayDefault.getString(key: "biometric_secret_key"), serverTime: self.pay_server_unixtime)
        params["wallet_id"] = self.pay_wallet_id
        params["request_data"] = [
            "application_id": self.application_id,
            "order_id": payload?.order_id ?? "order_21342134",
            "price": payload?.price ?? 1000,
            "name": payload?.name ?? "상품명"
        ]
        
        let headers: HTTPHeaders = [
            "BOOTPAY-DEVICE-UUID": Bootpay.getUUID(),
            "BOOTPAY-USER-TOKEN": userToken,
        ]
        
        AF.request("https://dev-api.bootpay.co.kr/app/easy/card/request", method: .post, parameters: params, headers: headers)
                 .validate()
                 .responseJSON { response in
                     print(response.value ?? "")
                    
                    guard let res = response.value as? [String: AnyObject] else { return }
                    guard let data = res["data"] as? [String: AnyObject] else { return }
                    
                    self.hideActionView()
//                    if let biometric_secret_key = data["biometric_secret_key"] as? String, let biometric_device_id = data["biometric_device_id"] as? String, let server_unixtime = data["server_unixtime"] as? CLong {
//
//                        BootpayDefault.setValue("biometric_secret_key", value: biometric_secret_key)
//                        BootpayDefault.setValue("biometric_device_id", value: biometric_device_id)
//                        self.authRegisterBiometricOTP(biometric_secret_key, serverTime: server_unixtime)
//
//                    }
             }

    }
}

extension BootpayAuthController: BootpayAuthProtocol {
    public func verifyCancel(data: [String: Any]) {
        print("지문결제 등록과정에서 사용자가 취소하였습니다")
        print(data)
    }
    
    public func verifyError(data: [String : Any]) {
        print("지문결제 등록과정에서 에러가 발생하였습니다")
        print(data)
    }
        
    public func verifySuccess(data: [String : Any]) {
        if let sub = data["data"], let token = (sub as! [String: Any])["token"] {
            registerBiometric(token as! String)
        }
    }
    
    func registerBiometric(_ token: String) {
        //지문을 받는다
        //성공시 등록한다
        registerBiometricRequest(token)
    }
    
    //지문결제를 하겠다
    func registerBiometricRequest(_ token: String) {
        
        var params = [String: Any]()
        params["password_token"] = token
        params["os"] = "ios"
        
        let headers: HTTPHeaders = [
            "BOOTPAY-DEVICE-UUID": Bootpay.getUUID(),
            "BOOTPAY-USER-TOKEN": userToken,
        ]
        
        AF.request("https://dev-api.bootpay.co.kr/app/easy/biometric", method: .post, parameters: params, headers: headers)
                 .validate()
                 .responseJSON { response in
                     print(response.value ?? "")
                    
                    guard let res = response.value as? [String: AnyObject] else { return }
                    guard let data = res["data"] as? [String: AnyObject] else { return }
                    if let biometric_secret_key = data["biometric_secret_key"] as? String, let biometric_device_id = data["biometric_device_id"] as? String, let server_unixtime = data["server_unixtime"] as? CLong {
                        
                        BootpayDefault.setValue("biometric_secret_key", value: biometric_secret_key)
                        BootpayDefault.setValue("biometric_device_id", value: biometric_device_id)
                        self.authRegisterBiometricOTP(biometric_secret_key, serverTime: server_unixtime)
                        
                    }
             }
    }
    
    func registerBiometricOTP(_ otp: String) {
        print(otp)
        
        var params = [String: Any]()
        params["otp"] = otp
        
        let headers: HTTPHeaders = [
            "BOOTPAY-DEVICE-UUID": Bootpay.getUUID(),
            "BOOTPAY-USER-TOKEN": userToken,
        ]
        
        AF.request("https://dev-api.bootpay.co.kr/app/easy/biometric/register", method: .post, parameters: params, headers: headers)
                 .validate()
                 .responseJSON { response in
//                     print(response.value ?? "")
                    
                    guard let res = response.value as? [String: AnyObject] else { return }
                    guard let data = res["data"] as? [String: AnyObject] else { return }
                    if let biometric_secret_key = data["biometric_secret_key"] as? String, let biometric_device_id = data["biometric_device_id"] as? String {

                        BootpayDefault.setValue("biometric_secret_key", value: biometric_secret_key)
                        BootpayDefault.setValue("biometric_device_id", value: biometric_device_id)
                        self.getWalletCardRequest()
//                        self.startBiometricUI(server_unixtime)
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
}
