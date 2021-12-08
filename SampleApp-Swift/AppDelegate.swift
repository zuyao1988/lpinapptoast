//
//  AppDelegate.swift
//  SampleApp-Swift
//
//  Created by Nimrod Shai on 2/23/16.
//  Copyright © 2016 LivePerson. All rights reserved.
//

import UIKit
import LPMessagingSDK
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Override point for customization after application launch.
        
        UNUserNotificationCenter.current().delegate = self
        
        // Register for push remote push notifications
        UNUserNotificationCenter.current().requestAuthorization(options:[.badge, .alert, .sound]){ (granted, error) in }
        application.registerForRemoteNotifications()
        
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        LPMessaging.instance.registerPushNotifications(token: deviceToken, notificationDelegate: self)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        LPMessaging.instance.handlePush(userInfo)
    }
}

//MARK: - LPMessagingSDKNotificationDelegate
/*
  For more information on `LPMessagingSDKNotificationDelegate` see:
      https://developers.liveperson.com/mobile-app-messaging-sdk-for-ios-customizing-toast-notifications.html
 */
extension AppDelegate: LPMessagingSDKNotificationDelegate {
    func LPMessagingSDKNotification(shouldShowPushNotification notification: LPNotification) -> Bool {
        return false
    }
    
    func LPMessagingSDKNotification(didReceivePushNotification notification: LPNotification) {
        
    }
    
    func LPMessagingSDKNotification(notificationTapped notification: LPNotification) {
        
    }
    
    // Example on how to implement a custom InApp Notification that supports Proactive and IVR Deflection
//    func LPMessagingSDKNotification(customLocalPushNotificationView notification: LPNotification) -> UIView {
//        let view = Toast(frame: CGRect(x: 0,
//                                       y: 0,
//                                       width: UIScreen.main.bounds.width,
//                                       height: 110))
//        view.set(with: notification)
//        return view
//    }
}

////get call if in the background
extension AppDelegate: UNUserNotificationCenterDelegate {
    //for displaying notification when app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("+++++ willPresent \(notification)")
        

        let userInfo = notification.request.content.userInfo
        
        print(userInfo)
        
        LPMessaging.instance.handlePush(userInfo)
        
        completionHandler([.alert, .badge, .sound])
//        application.registerForRemoteNotifications()
    }

    // For overwrite + handling tap and user actions
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("+++OMG \(response)")
        let userInfo = response.notification.request.content.userInfo
        LPMessaging.instance.handlePush(userInfo)
        print(userInfo)
        completionHandler()
    }
}
