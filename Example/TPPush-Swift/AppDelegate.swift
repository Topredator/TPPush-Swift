//
//  AppDelegate.swift
//  TPPush-Swift
//
//  Created by 周晓路 on 08/30/2021.
//  Copyright (c) 2021 周晓路. All rights reserved.
//

import UIKit
import TPPush_Swift


private struct Push {
    static let identity = "Y4sUpfMd1W7kZZDseDQhW5"
    static let key = "qYrqZr4mZu5tKZ2WvzlLW"
    static let secret = "IYNmbCtTuf7I6gCuXSQBu6"
}


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        initPush()
        return true
    }
    
    func initPush() {
        Pusher.registerRemoteService()
        /// 个推平台
        let gt = GTModel(Push.key, secret: Push.secret, identify: Push.identity)
        gt.customChannelId("app-ios")
        Pusher.registerModel(gt)
    }
}

