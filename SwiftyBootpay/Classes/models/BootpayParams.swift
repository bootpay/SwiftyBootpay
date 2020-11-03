//
//  BootpayParams.swift
//  CryptoSwift
//
//  Created by YoonTaesup on 2019. 4. 12..
//

public protocol BootpayParams {}

//// from - devxoul's then (https://github.com/devxoul/Then)
extension BootpayParams where Self: AnyObject {
    public func params(_ block: (Self) -> Void) -> Self {
        block(self)
        return self
    }
}
