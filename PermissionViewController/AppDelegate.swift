//
//  AppDelegate.swift
//  PermissionViewController
//
//  Created by Iven Prillwitz on 06.04.18.
//  Copyright © 2018 Iven Prillwitz. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        window = UIWindow(frame: UIScreen.main.bounds)

        let viewcontroller = PermissionViewController()
        let navigationController = UINavigationController(rootViewController: viewcontroller)

        window?.rootViewController = navigationController

        window?.makeKeyAndVisible()

        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        let notification = Notification(name: Notification.Name.UIApplicationDidBecomeActive)
        NotificationCenter.default.post(notification)
    }
}

