//
//  Endpoints.swift
//  VirtualTourist
//
//  Created by Dilip Agheda on 19/3/22.
//

import Foundation

enum Endpoints {
    
    case searchPhotos(lat: Double, lon: Double, page: Int)
    case fetchPhoto(id: String, server: String, secret: String)

    var url: URL {
        switch(self) {
        case .searchPhotos(let lat, let lon, let page):
            return URL(string: "https://www.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(Constants.API_KEY)&has_geo=true&lat=\(lat)&lon=\(lon)&page=\(page)&format=json&nojsoncallback=1")!
        case .fetchPhoto(let id, let server, let secret):
            let str = "https://live.staticflickr.com/\(server)/\(id)_\(secret)_t.jpg"
            return URL(string: str)!
        }
    }
}
