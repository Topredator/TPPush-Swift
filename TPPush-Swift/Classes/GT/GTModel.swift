//
//  GTModel.swift
//  TPPush-Swift
//
//  Created by Topredator on 2021/8/30.
//

import Foundation
import TPPush

public extension Notification.Name {
   /// 接收到 远程推送
   static let clientId = Notification.Name("com.xt.push.notify.fetchClientId")
}

public class GTModel: NSObject, PlatformWrapper {
    public var handler: ConnectMessageHandle? = nil
    let key: String
    let secret: String
    let identify: String
    public init(_ key: String, secret: String, identify: String) {
        self.key = key
        self.secret = secret
        self.identify = identify
    }
    
    /// 自定义渠道
    /// - Parameter channelId: 渠道号
    public func customChannelId(_ channelId: String) {
        GeTuiSdk.setChannelId(channelId)
    }
}

extension GTModel: GeTuiSdkDelegate {
    
    // MARK:  ------------- Public method --------------------
    public func register() {
        GeTuiSdk.start(withAppId: identify, appKey: key, appSecret: secret, delegate: self)
    }
    public func registerDeviceToken(_ token: String?) {
        guard let token = token else { return }
        GeTuiSdk.registerVoipToken(token)
    }
    public func handleRemoteNotify(_ param: [AnyHashable : Any]?) {
        guard let userInfo = param else { return }
        GeTuiSdk.handleRemoteNotification(userInfo)
    }
    public func setBadge(_ badge: Int) {
        GeTuiSdk.setBadge(UInt(badge))
    }
    public var appKey: String? { key }
    public var appSecret: String? { secret }
    public var appIdentify: String? { identify }
    public var pass: String? {
        GeTuiSdk.clientId()
    }
    
    
    public func geTuiSdkDidRegisterClient(_ clientId: String) {
        if clientId.count > 0 {
            NotificationCenter.default.post(name: .clientId, object: nil)
        }
    }
    
    public func geTuiSdkDidReceiveSlience(_ userInfo: [AnyHashable : Any], fromGetui: Bool, offLine: Bool, appId: String?, taskId: String?, msgId: String?, fetchCompletionHandler completionHandler: ((UIBackgroundFetchResult) -> Void)? = nil) {
        if !offLine { // 在线
            handler?.handleLongConnect(userInfo)
        }
    }
}
