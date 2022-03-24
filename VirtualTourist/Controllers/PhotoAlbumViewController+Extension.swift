//
//  PhotoAlbumViewController+Extension.swift
//  VirtualTourist
//
//  Created by Dilip Agheda on 24/3/22.
//

import Foundation


extension PhotoAlbumViewController {

    func initiatePhotosRetrieval() {
        
        //find photos from core data first
        self.photos = []
        
        let locallyStoredPhotosByPin = DataService.shared.getPhotosByPin(pin: self.pin!)

        if(!locallyStoredPhotosByPin.isEmpty) {

            for locallyStoredPhoto in locallyStoredPhotosByPin {
                self.photos.append(locallyStoredPhoto)
            }

            self.collectionView.reloadData()

            return
        }
        
        //fetch from network if there are no locally stored photos by pin
        self.isLoading(status: true)
        self.noImagesLabel.isHidden = true
        
        NetworkService.shared.searchPhotos(latitude: self.pin!.latitude, longitude: self.pin!.longitude) {
                (flickerPhotos, errorMessage) in
                guard let flickerPhotos = flickerPhotos else {
                    DispatchQueue.main.async {
                        self.isLoading(status: false)
                    }
                    return
                }
            
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            
                let total = flickerPhotos.flickerPhotoArray.count
            
                if(total == 0) {
                    DispatchQueue.main.async {
                        PhotoCollectionMetaData.totalPhotosInCurrentPage = 0
                        self.photos = []
                        self.collectionView.reloadData()
                        self.isLoading(status: false)
                        self.noImagesLabel.isHidden = false
                    }
                    return
                }
            
                var index = 0

                func getPhotoFunc() {
                    
                    let photoItem = flickerPhotos.flickerPhotoArray[index]

                    NetworkService.shared.getPhoto(id: photoItem.id, server: photoItem.server, secret: photoItem.secret) {
                        (data, errorMessage) in
                        guard let data = data else {
                            DispatchQueue.main.async {
                                self.isLoading(status: false)
                                self.noImagesLabel.isHidden = false
                            }
                            return
                        }
                        
                        let newlyAddedPhoto = DataService.shared.addPhotoToPin(pin: self.pin!, image: data)
                        
                        if let newlyAddedPhoto = newlyAddedPhoto {
                            DispatchQueue.main.async {
                                self.photos.append(newlyAddedPhoto)
                                PhotoCollectionMetaData.totalPhotosInCurrentPage = self.photos.count
                                self.collectionView.reloadData()
                            }
                        }
                        
                        index = index + 1
                        if(index < total) {
                            getPhotoFunc()
                        }else {
                            DispatchQueue.main.async {
                                self.isLoading(status: false)
                                self.noImagesLabel.isHidden = true
                            }
                        }
                    }
                }
            
                getPhotoFunc()
        }
    }
}
