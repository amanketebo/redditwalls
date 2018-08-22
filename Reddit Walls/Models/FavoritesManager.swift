//
//  Favorites.swift
//  Reddit Walls
//
//  Created by Amanuel Ketebo on 9/10/17.
//  Copyright © 2017 Amanuel Ketebo. All rights reserved.
//

import Foundation
import UIKit

class FavoritesManager {
    static let shared = FavoritesManager()
    static let favorites = "favorites"

    var favorites: [Wallpaper] = [] {
        didSet {
            saveFavorites()
        }
    }
    let userDefaults = UserDefaults.standard

    init() {
        favorites = fetchSavedFavorites()
    }

    // MARK: - Favorites methods

    func fetchSavedFavorites() -> [Wallpaper] {
        if let favorites = userDefaults.array(forKey: FavoritesManager.favorites) as? [[String: String]] {
            var savedFavorites = [Wallpaper]()

            favorites.forEach({ (wallpaperInfo) in
                if let wallpaper = Wallpaper(wallpaperInfo, favorite: true) {
                    savedFavorites.append(wallpaper)
                }
            })

            return savedFavorites
        }

        return []
    }

    func saveFavorites() {
        // User defaults can only contain Property Lists
        var favoritesPropertyList = [[String: String]]()

        // Convert each Wallpaper element to a Property List
        favorites.forEach { (wallpaper) in
            var wallpaperInfo = [String: String]()

            wallpaperInfo[Wallpaper.title] = wallpaper.title
            wallpaperInfo[Wallpaper.author] = wallpaper.author
            wallpaperInfo[Wallpaper.fullResolutionURL] = wallpaper.fullResolutionURL
            wallpaperInfo[Wallpaper.lowerResolutionURL] = wallpaper.lowerResolutionURL
            favoritesPropertyList.append(wallpaperInfo)
        }

        userDefaults.set(favoritesPropertyList, forKey: FavoritesManager.favorites)
    }

    func removeFavorite(_ wallpaper: Wallpaper) {
        guard let position = favorites.index(where: { (favoriteWallpaper) -> Bool in
            return wallpaper == favoriteWallpaper
        }) else { return }

        favorites.remove(at: position)
    }

    func favoritesContains(_ wallpaper: Wallpaper) -> Bool {
        if favorites.contains(where: { (favoriteWallpaper) -> Bool in
            return wallpaper == favoriteWallpaper
        }) {
            return true
        } else {
            return false
        }
    }
}