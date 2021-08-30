//
//  Manager.swift
//  TPPush-Swift
//
//  Created by Topredator on 2021/8/30.
//

import Foundation
import TPFoundation_Swift

public class Manager: NSObject {
    public weak var delegate: PushNotify?
    /// 平台对象
    private var _pushModel: PlatformWrapper? = nil
    public var pushMode: PlatformWrapper? {
        get { _pushModel }
        set {
            _pushModel = newValue
            _pushModel?.register()
            _pushModel?.handler = Manager.shared
        }
    }
    public var remoteNotify: [AnyHashable: Any]? = nil
    public var localNotify: [AnyHashable: Any]? = nil
    /// 单例初始化
    static let shared = Manager()
    override init() {
        super.init()
        self.registerRemoteService()
        self.injectDeviceToken()
    }
    
    // MARK:  ------------- Public method --------------------
    public func registerDeviceToken(_ data: Data) {
        var token: String? = nil
        if #available(iOS 13.0, *) {
            token = data.hexEncodedString()
        } else {
            token = data.description.trimmingCharacters(in: CharacterSet(charactersIn: "<>"))
            token = token!.replacingOccurrences(of: " ", with: "")
        }
        pushMode?.registerDeviceToken(token)
    }
    public func setBadge(_ badge: Int) {
        UIApplication.shared.applicationIconBadgeNumber = badge
        pushMode?.setBadge(badge)
    }
    public func registerRemoteService() {
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            center.delegate = self
            center.getNotificationSettings { (setting) in
                switch setting.authorizationStatus {
                case .notDetermined:
                    center.requestAuthorization(options: [.badge, .sound, .alert]) { (result, error) in
                        if result {
                            if !(error != nil) { // 注册成功
                                DispatchQueue.main.async { UIApplication.shared.registerForRemoteNotifications() }
                            }
                        } else { debugPrint("用户不允许推送") }
                    }
                    break
                case .denied:
                    debugPrint("请求权限被拒")
                    break
                case .authorized: // 用户已授权，再次获取
                    DispatchQueue.main.async { UIApplication.shared.registerForRemoteNotifications() }
                    break
                default:
                    debugPrint("位置错误")
                    break
                }
            }
        }
    }
    public func closeRemoteService() {
        UIApplication.shared.unregisterForRemoteNotifications()
    }
    public func cancelLocalNotify(_ identify: String?) {
        guard let identify = identify else { return }
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [identify])
        } else {
            if let locals = UIApplication.shared.scheduledLocalNotifications {
                for local in locals {
                    if let dic = local.userInfo {
                        for (_, value) in dic {
                            if value is String, (value as! String) == identify {
                                UIApplication.shared.cancelLocalNotification(local)
                            }
                        }
                    }
                }
            }
        }
        
    }
    public func cancelAllLocalNotifies() {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        } else {
            UIApplication.shared.cancelAllLocalNotifications()
        }
    }
    // MARK:  ------------- Private method --------------------
    @objc func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Manager.shared.registerDeviceToken(deviceToken)
    }
    @objc func xt_application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Manager.shared.registerDeviceToken(deviceToken)
        self.xt_application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
    }
    
    func injectDeviceToken() {
        let cls = UIApplication.shared.delegate!
        let localSelector = #selector(application(_:didRegisterForRemoteNotificationsWithDeviceToken:))
        let xtSelector = #selector(xt_application(_:didRegisterForRemoteNotificationsWithDeviceToken:))
        let localMethod = class_getInstanceMethod(Manager.self, localSelector)
        if UIApplication.shared.delegate.self!.responds(to: localSelector) {
            FoundationSwizzling(type(of: cls), swizzledClass: Manager.self, originalSelector: localSelector, swizzledSelector: xtSelector)
        } else {
            class_addMethod(type(of: cls), localSelector, method_getImplementation(localMethod!), method_getTypeEncoding(localMethod!))
        }
    }
    func handleRemoteMsg(_ param: [AnyHashable: Any]?) {
        delegate?.remoteNotify(param)
        NotificationCenter.default.post(name: .remoteNotify, object: param)
    }
    func handleLocalMsg(_ param: [AnyHashable: Any]?) {
        delegate?.localNotify(param)
        NotificationCenter.default.post(name: .localNotify, object: param)
    }
}

import UserNotifications
extension Manager: ConnectMessageHandle, UNUserNotificationCenterDelegate {
    
    // MARK:  ------------- ConnectMessageHandle --------------------
    public func handleLongConnect(_ msg: [AnyHashable : Any]?) {
        guard let msg = msg else { return }
        delegate?.longConnectNotify(msg)
        NotificationCenter.default.post(name: .longConnect, object: msg)
    }
    // MARK:  ------------- UNUserNotificationCenterDelegate --------------------
    /// App在前台获取到通知
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.badge, .sound, .alert])
    }
    /// 点击通知进入App时触发
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if let trigger = response.notification.request.trigger, trigger is UNPushNotificationTrigger {
            remoteNotify = response.notification.request.content.userInfo
            pushMode?.handleRemoteNotify(remoteNotify)
            handleRemoteMsg(remoteNotify)
        } else {
            localNotify = response.notification.request.content.userInfo
            handleLocalMsg(localNotify)
        }
        completionHandler()
    }
}


extension Data {
    struct HexEncodingOptions: OptionSet {
        let rawValue: Int
        static let upperCase = HexEncodingOptions(rawValue: 1 << 0)
    }

    func hexEncodedString(options: HexEncodingOptions = []) -> String {
        let format = options.contains(.upperCase) ? "%02hhX" : "%02hhx"
        return self.map { String(format: format, $0) }.joined()
    }
}
