//
//  BootpayBioTheme.swift
//  Pods
//
//  Created by Taesup Yoon on 15/10/2020.
//

import Foundation
import ObjectMapper

public class BootpayBioTheme: NSObject, BootpayParams, Mappable {
    @objc public var fontColor = UIColor.black
    @objc public var bgColor = UIColor.init(red: 0.98, green: 0.98, blue: 0.98, alpha: 1.0)
    
    
    public override init() {}
   
    public required init?(map: Map) {}
   
   
    public func mapping(map: Map) {
    }
}
