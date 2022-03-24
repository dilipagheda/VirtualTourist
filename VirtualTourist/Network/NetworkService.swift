//
//  NetworkService.swift
//  VirtualTourist
//
//  Created by Dilip Agheda on 19/3/22.
//

import Foundation

class NetworkService {
    
    static let shared = NetworkService()
    
    private init(){}
    
    public func searchPhotos(latitude: Double, longitude: Double, completion: @escaping (FlickerPhotos?, String?) -> Void) {
        
        let lastTotalPages = PhotoCollectionMetaData.getLastTotalPages(id: "\(latitude) \(longitude)")
        
        let page = lastTotalPages == 0 ? 1 : Int.random(in: 1...lastTotalPages)
        
        let url = Endpoints.searchPhotos(lat: latitude, lon: longitude, page: page).url
        
        let dataTask = URLSession.shared.dataTask(with: url){
            (data, urlResponse, error) in
            if let error = error {
                completion(nil, error.localizedDescription)
                return
            }
            guard let data = data else {
                completion(nil, "Sorry! Something went wrong!")
                return
            }
            
            let decoder = JSONDecoder()
            do{
                let searchPhotosResponse = try decoder.decode(SearchPhotosResponse.self, from: data)

                PhotoCollectionMetaData.totalPhotosInCurrentPage = searchPhotosResponse.flickerPhotos.perpage
                PhotoCollectionMetaData.setLastTotalPages(lastTotalPages: searchPhotosResponse.flickerPhotos.pages)
                
                completion(searchPhotosResponse.flickerPhotos, nil)
            }catch{
                completion(nil, "Sorry! Something went wrong!")
                return
            }
        }
        
        dataTask.resume()
    }
    
    public func getPhoto(id: String, server: String, secret: String ,completion: @escaping (Data?, String?) -> Void) {
       
        let dataTask = URLSession.shared.dataTask(with: Endpoints.fetchPhoto(id: id, server: server, secret: secret).url){
            (data, urlResponse, error) in
            if let error = error {
                completion(nil, error.localizedDescription)
                return
            }
            guard let data = data else {
                completion(nil, "Sorry! Something went wrong!")
                return
            }
            completion(data, nil)
        }

        dataTask.resume()
    }
    
    public func getPhotosByGeoLocation(flickerPhotos: FlickerPhotos, completion: @escaping ([Data]?, String?) -> Void) {

            var dataArray : [Data] = []
            var index = 0
            let total = flickerPhotos.flickerPhotoArray.count
        
            if(total == 0) {
                DispatchQueue.main.async {
                    completion([], nil)
                }
                return
            }
            
            func getPhotoFunc() {
                
                let photoItem = flickerPhotos.flickerPhotoArray[index]

                self.getPhoto(id: photoItem.id, server: photoItem.server, secret: photoItem.secret) {
                    (data, errorMessage) in
                    guard let data = data else {
                        DispatchQueue.main.async {
                            completion(nil, errorMessage)
                        }
                        return
                    }
                    dataArray.append(data)
                    index = index + 1
                    if(index < total) {
                        getPhotoFunc()
                    }else{
                        DispatchQueue.main.async {
                            completion(dataArray, nil)
                        }
                    }
                }
            }
            
            getPhotoFunc()
        }
}
