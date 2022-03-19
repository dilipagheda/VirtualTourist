//
//  Endpoints.swift
//  VirtualTourist
//
//  Created by Dilip Agheda on 19/3/22.
//

import Foundation

enum Endpoints {
    
    case searchPhotos(lat: Double, lon: Double)
    case fetchPhoto(id: String, server: String, secret: String)

    var url: URL {
        switch(self) {
        case .searchPhotos(let lat, let lon):
            return URL(string: "https://www.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(Constants.API_KEY)&has_geo=true&lat=\(lat)&lon=\(lon)&format=json&nojsoncallback=1")!
        case .fetchPhoto(let id, let server, let secret):
            return URL(string: "https://live.staticflickr.com/\(id)/\(server)_\(secret)_t.jpg")!
        }
    }
}



