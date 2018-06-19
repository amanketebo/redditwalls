//
//  WallpaperRequester.swift
//  Reddit Walls
//
//  Created by Amanuel Ketebo on 3/19/17.
//  Copyright © 2017 Amanuel Ketebo. All rights reserved.
//

import UIKit
import SwiftyJSON
import Foundation

class WallpaperRequester {
    private var baseURL = "https://www.reddit.com/r/wallpapers.json"
    private lazy var wallpapersURL = URL(string: baseURL)!
    var nextPage: String?
    var wallpaperCache = NSCache<NSURL, UIImage>()
    let stuffManager = StuffManager.shared

    init(subredditURL: String) {
        self.baseURL = subredditURL
        self.wallpaperCache.countLimit = 8
    }

    typealias WallpapersCallback = ([Wallpaper]?, Error?) -> Void
    typealias WallpaperImageDataCallback = (UIImage?, Error?) -> Void

    // MARK: - Wallpaper fetching methods

    func fetchWallpapers(page: Int, completion: @escaping WallpapersCallback) {
        var request: URLRequest!

        if page == 0 {
            request = URLRequest(url: wallpapersURL)
        } else {
            if let nextPageURL = nextPageURL(page: page) {
                request = URLRequest(url: nextPageURL)
            } else {
                DispatchQueue.main.async {
                    completion([], nil)
                }
                return
            }
        }

        let task = URLSession.shared.dataTask(with: request) { [weak self] (data, _, error) in
            if let taskError = error {
                DispatchQueue.main.async {
                    completion(nil, taskError)
                }
            } else {
                if let nextPage = self?.nextPage(data: data!) {
                    self?.nextPage = nextPage
                } else {
                    self?.nextPage = nil
                }

                let returnedWallpapers = self?.parseWallpaperJSON(data: data!)

                DispatchQueue.main.async {
                    completion(returnedWallpapers, nil)
                }
            }
        }
        task.resume()
    }

    // MARK: - Wallpaper Cache methods

    func wallpaperForURL(_ url: URL) -> UIImage? {
        return wallpaperCache.object(forKey: url as NSURL)
    }

    func addToCache(_ url: URL, wallpaper: UIImage) {
        wallpaperCache.setObject(wallpaper, forKey: url as NSURL)
    }

    func fetchWallpaperImage(from wallpaperURL: URL, completion: @escaping WallpaperImageDataCallback) {
        let request = URLRequest(url: wallpaperURL)

        if let cachedWallpaper = self.wallpaperForURL(wallpaperURL) {
            completion(cachedWallpaper, nil)
        } else {
            let task = URLSession.shared.dataTask(with: request) { (data, _, error) in
                if let taskError = error {
                    DispatchQueue.main.async {
                        completion(nil, taskError)
                    }
                } else {
                    if let wallpaper = UIImage(data: data!) {
                        self.addToCache(wallpaperURL, wallpaper: wallpaper)
                        DispatchQueue.main.async {
                            completion(wallpaper, nil)
                        }
                    } else {
                        DispatchQueue.main.async {
                            completion(nil, error)
                        }
                    }
                }
            }

            task.resume()
        }
    }

    // MARK: - Helper methods

    private func parseWallpaperJSON(data: Data) -> [Wallpaper] {
        var wallpapers: [Wallpaper] = []
        let json = JSON(data)

        if let returnedWallpapers = json[SwiftyJSONPaths.wallpapers].array {
            for wallpaperJSON in returnedWallpapers {
                if let wallpaper = Wallpaper(wallpaperJSON) {
                    wallpapers.append(wallpaper)
                }
            }
        }

        return wallpapers
    }

    private func nextPage(data: Data) -> String? {
        let json = JSON(data)

        if let nextPage = json[SwiftyJSONPaths.nextPage].string {
            return nextPage
        } else {
            return nil
        }
    }

    private func nextPageURL(page: Int) -> URL? {
        guard let nextPage = nextPage else { return nil }

        return URL(string: baseURL + "?after=" + "\(nextPage)")
    }
}
