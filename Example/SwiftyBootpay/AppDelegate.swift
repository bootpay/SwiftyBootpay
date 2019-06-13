//
//  AppDelegate.swift
//  SwiftyBootpay
//
//  Created by ehowlsla on 10/30/2017.
//  Copyright (c) 2017 ehowlsla. All rights reserved.
//

import UIKit
import SwiftyBootpay

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool { 
        // 해당 프로젝트(아이폰)의 application id 값을 설정합니다. 결제와 통계 모두를 위해 꼭 필요합니다. 
        Bootpay.sharedInstance.appLaunch(application_id: "5a52cc39396fa6449880c0f0") // production sample
        
        return true
    } 

    func applicationWillResignActive(_ application: UIApplication) { 
        Bootpay.sharedInstance.sessionActive(active: false)
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        Bootpay.sharedInstance.sessionActive(active: true)
    }

    func applicationWillTerminate(_ application: UIApplication) {
    }
}

