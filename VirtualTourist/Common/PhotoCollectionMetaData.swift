//
//  PhotoCollectionMetaData.swift
//  VirtualTourist
//
//  Created by Dilip Agheda on 23/3/22.
//

import Foundation

class PhotoCollectionMetaData {
    
    static var totalPhotosInCurrentPage: Int = 0
    
    static func getLastTotalPages(id: String) -> Int {
        
        let currentId = UserDefaults.standard.string(forKey: "id")
        
        if let currentId = currentId {
            if(currentId == id) {
                let lastTotalPages = UserDefaults.standard.integer(forKey: "lastTotalPages")
             
                return lastTotalPages
            }
        }
        
        PhotoCollectionMetaData.setId(id: id)
        
        setLastTotalPages(lastTotalPages: 0)
        
        return 0
        
    }

    static func setId(id: String) {
        
        UserDefaults.standard.set(id, forKey: "id")
        
    }

    static func setLastTotalPages(lastTotalPages: Int) {
        
        UserDefaults.standard.set(lastTotalPages, forKey: "lastTotalPages")
        
    }
    
}
