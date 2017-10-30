//
//  BootpayAnalytics.swift
//  FBSnapshotTestCase
//
//  Created by YoonTaesup on 2017. 10. 30..
//



open class BootpayAnalytics {
    //    public static let sharedInstance = BootpayAnalytics()
    public init() {}
    
    var application_id = ""
    var uuid = ""
    var sk = ""
    var sk_time = 0 // session 유지시간 기본 30분
    var last_time = 0 // 접속 종료 시간
    var time = 0 // 미접속 시간
    //    var user = BootpayUser()
}


//
//public class BootpayAnalytics {
////    public static let sharedInstance = BootpayAnalytics()
//    var application_id = ""
//    var uuid = ""
//    var sk = ""
//    var sk_time = 0 // session 유지시간 기본 30분
//    var last_time = 0 // 접속 종료 시간
//    var time = 0 // 미접속 시간
////    var user = BootpayUser()
//}

