//
//  SearchPhotosResponse.swift
//  VirtualTourist
//
//  Created by Dilip Agheda on 19/3/22.
//

import Foundation

class FlickerPhoto: Codable {
    let id: String
    let owner: String
    let secret: String
    let server: String
    let farm:  Int
    let title: String
    let ispublic: Int
    let isfriend: Int
    let isfamily: Int
}

class FlickerPhotos: Codable {
    
    let page: Int
    let pages: Int
    let perpage: Int
    let total: Int
    let flickerPhotoArray: [FlickerPhoto]
    
    enum CodingKeys: String, CodingKey {
        case page = "page"
        case pages = "pages"
        case perpage = "perpage"
        case total = "total"
        case flickerPhotoArray = "photo"
    }
}

class SearchPhotosResponse: Codable {
    
    let flickerPhotos: FlickerPhotos
    
    enum CodingKeys: String, CodingKey {
        case flickerPhotos = "photos"
    }
}
