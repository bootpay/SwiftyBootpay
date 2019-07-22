//
//  RemoteOrderForm.swift
//  SwiftyBootpay
//
//  Created by YoonTaesup on 2019. 4. 12..
//
import ObjectMapper

@objc public class RemoteOrderForm: NSObject, BootpayParams, Mappable {
    public override init() {}
    @objc public var m_id = ""
    @objc public var pg = ""
    @objc public var fm = [String]() //결제수단 methods (filtered)
    @objc public var tfp = Double(0) //tax_free_price
    @objc public var n = "" //상품명, name
    @objc public var cn = "" //company_name, 업체명
    @objc public var ip = Double(0) // item price - 상품가격
    @objc public var dp = Double(0) // display price - 할인된 가격을 표시하기 위함
    @objc public var dap = Double(0)  // 기본배송비
    
    @objc public var is_r_n = false //구매자명 입력을 허용할지 말지, is_receive_name
    @objc public var is_r_p = false //구매자가 가격 입력 허용할지 말지
    @objc public var is_addr = false // 주소 받을지 말지
    @objc public var is_da = false // 배송비 받을지 말지
    @objc public var is_memo = false //한줄메모 할지 말지
    
    @objc public var desc_html = "" //상품설명 html
    @objc public var dap_jj = 0.0 // 제주지역 도서산간 추가비용
    @objc public var dap_njj = 0.0 // 제주 외 지역 도서산간 추가비용
    @objc public var o_key = "" //(부트페이가 관리하는) 가맹점의 상품 고유 키, receipt에 전송시 su와 조합하여 전송해야겠다
    
    public required init?(map: Map) {
    }
    
    public func mapping(map: Map) {
        m_id <- map["m_id"]
        pg <- map["pg"]
        fm <- map["fm"]
        tfp <- map["tfp"]
        n <- map["n"]
        cn <- map["cn"]
        ip <- map["ip"]
        dp <- map["dp"]
        dap <- map["dap"]
        
        is_r_n <- map["is_r_n"]
        is_r_p <- map["is_r_p"]
        is_addr <- map["is_addr"]
        is_da <- map["is_da"]
        is_memo <- map["is_memo"]
        
        desc_html <- map["desc_html"]
        dap_jj <- map["dap_jj"]
        dap_njj <- map["dap_njj"]
        o_key <- map["o_key"]
    } 
}
