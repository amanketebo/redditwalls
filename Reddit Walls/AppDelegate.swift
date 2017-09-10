//
//  AppDelegate.swift
//  Reddit Walls
//
//  Created by Amanuel Ketebo on 3/17/17.
//  Copyright © 2017 Amanuel Ketebo. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool
    {
        setupAppearance()
        return true
    }
    
    private func setupAppearance()
    {
        let navBar = UINavigationBar.appearance()
        let refreshControl = UIRefreshControl.appearance()
        let collectionView = UICollectionView.appearance()
        
        navBar.isTranslucent = false
        refreshControl.backgroundColor = .hintOfGray
        collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: Dimension.footerHeight, right: 0)
    }
}

