//
//  WallpaperServicing.swift
//  Reddit Walls
//
//  Created by Amanuel Ketebo on 3/20/20.
//  Copyright © 2020 Amanuel Ketebo. All rights reserved.
//

import UIKit

protocol WallpaperServicing {
    // MARK: - Properties
    
    var wallpaperType: WallpaperType { get }
    
    // MARK: - Request Building
    
    func buildRequest(forPage page: Int) -> URLRequest?
    func buildRequest(forImageResourceURL imageResourceURL: URL?) -> URLRequest?
    
    // MARK: - Fetching
    
    func fetchWallpapers(usingRequest request: URLRequest,
                         completionQueue queue: DispatchQueue,
                         completion: @escaping (Swift.Result<WallpapersResponse, APIServiceError>) -> Void)
    func fetchWallpaper(usingRequest request: URLRequest,
                        completionQueue queue: DispatchQueue,
                        completion: @escaping (Swift.Result<UIImage, APIServiceError>) -> Void)
}

class WallpaperService: WallpaperServicing {
    var wallpaperType: WallpaperType
    
    init(wallpaperType: WallpaperType) {
        self.wallpaperType = wallpaperType
    }
    
    func buildRequest(forPage page: Int) -> URLRequest? {
        var components = URLComponents()
        components.scheme = wallpaperType.scheme
        components.host = wallpaperType.host
        components.path = wallpaperType.path
        components.queryItems = [URLQueryItem(name: "after", value: String(page))]
        
        guard let url = components.url else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.cachePolicy = .returnCacheDataElseLoad
        
        return request
    }
    
    func buildRequest(forImageResourceURL imageResourceURL: URL?) -> URLRequest? {
        guard let imageResourceURL = imageResourceURL else {
            return nil
        }
        
        var request = URLRequest(url: imageResourceURL)
        request.cachePolicy = .returnCacheDataElseLoad
        
        return request
    }
    
    func fetchWallpapers(usingRequest request: URLRequest,
                         completionQueue queue: DispatchQueue,
                         completion: @escaping (Swift.Result<WallpapersResponse, APIServiceError>) -> Void) {
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            var result: Swift.Result<WallpapersResponse, APIServiceError>
            
            defer {
                queue.async {
                    completion(result)
                }
            }
            
            if let _ = error,
                let httpURLResponse = response as? HTTPURLResponse {
                let apiServiceError = APIServiceError(statusCode: httpURLResponse.statusCode)
                result = .failure(apiServiceError)
                return
            }
            
            guard let data = data,
                let wallpapersAPIResponse = try? JSONDecoder().decode(WallpapersAPIResponse.self, from: data) else {
                result = .failure(.parsing)
                return
            }
            
            let wallpapersResponse = WallpapersResponse(wallpapersAPIResponse: wallpapersAPIResponse)
            
            result = .success(wallpapersResponse)
        }
        task.resume()
    }
    
    func fetchWallpaper(usingRequest request: URLRequest,
                        completionQueue queue: DispatchQueue,
                        completion: @escaping (Swift.Result<UIImage, APIServiceError>) -> Void) {
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            var result: Swift.Result<UIImage, APIServiceError>
            
            defer {
                queue.async {
                    completion(result)
                }
            }
            
            if let _ = error,
                let httpURLResponse = response as? HTTPURLResponse {
                let apiServiceError = APIServiceError(statusCode: httpURLResponse.statusCode)
                result = .failure(apiServiceError)
                return
            }
            
            guard let data = data,
                let image = UIImage(data: data) else {
                result = .failure(.parsing)
                return
            }
            
            result = .success(image)
        }
        task.resume()
    }
}
