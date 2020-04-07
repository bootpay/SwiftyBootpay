//
//  BootpayOneStore.swift
//  Alamofire
//
//  Created by Taesup Yoon on 01/04/2020.
//

import Foundation
import ObjectMapper

public class BootpayOneStore: NSObject, BootpayParams, Mappable {
    @objc public var ad_id = "UNKNOWN_ADID";
    @objc public var sim_operator = "UNKNOWN_SIM_OPERATOR";
    @objc public var installer_package_name = "UNKNOWN_INSTALLER";
     

    public override init() {}
    public required init?(map: Map) {}
    
    public func mapping(map: Map) {
        ad_id <- map["ad_id"]
        sim_operator <- map["sim_operator"]
        installer_package_name <- map["installer_package_name"]
    }
    
    public func toString() -> String {
        return "{ad_id: '\(ad_id)', sim_operator: '\(sim_operator)', installer_package_name: '\(installer_package_name)'}"
    }
}
