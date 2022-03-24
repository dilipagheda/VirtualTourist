//
//  DataService.swift
//  VirtualTourist
//
//  Created by Dilip Agheda on 19/3/22.
//

import Foundation
import UIKit
import CoreData

class DataService {
    
    static let shared = DataService()

    var appDelegate: AppDelegate? {
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
            return nil
        }
        return appDelegate
    }

    var viewContext: NSManagedObjectContext? {
        guard let appDelegate = self.appDelegate else {
            return nil
        }
        return appDelegate.persistentContainer.viewContext
    }
    
    private init() {}

    private func roundTo3Decimal(value: Double) -> Double {

        return round(value * 1000) / 1000.0
    }
    
    public func addPin(latitude: Double, longitude: Double) {
        
        guard let viewContext = viewContext, let appDelegate = appDelegate else {
            return
        }
       
        let lat = roundTo3Decimal(value: latitude)
        let lon = roundTo3Decimal(value: longitude)
        
        //check if it exists already
        let existingPin = getPinByGeoLocation(latitude: lat, longitude: lon)

        if existingPin != nil {
            return
        }
        
        let pin = Pin(context: viewContext)
        pin.id="\(lat) \(lon)"
        pin.latitude = Double(lat)
        pin.longitude = Double(lon)
        
        appDelegate.saveContext()
    }
    
    public func getPins() -> [Pin] {                                                             
        
        guard let viewContext = viewContext else {
            return []
        }
        
        let fetchRequest = NSFetchRequest<Pin>(entityName: "Pin")
        
        do {
            let pins = try viewContext.fetch(fetchRequest)
            return pins
        }catch{
            print(error.localizedDescription)
        }
        return []
    }
    
    public func getPinByGeoLocation(latitude: Double, longitude:  Double) -> Pin? {
        
        guard let viewContext = viewContext else {
            return nil
        }
        
        let fetchRequest = NSFetchRequest<Pin>(entityName: "Pin")
        
        let id = "\(latitude) \(longitude)"

        let predicate = NSPredicate(format: "latitude == %@", id)

        fetchRequest.predicate = predicate
        
        do {
            let pins = try viewContext.fetch(fetchRequest)
            
            if(pins.isEmpty) {
                return nil
            }
            return pins[0]
        }catch{
            print(error.localizedDescription)
        }
        return nil
    }
    
    public func addPhotoToPin(pin:Pin, image: Data) -> Photo? {
        
        guard let viewContext = viewContext, let appDelegate = appDelegate else {
            return nil
        }
       
        let photo = Photo(context: viewContext)
        photo.image = image
        photo.pin = pin

        appDelegate.saveContext()
        
        return photo
    }
    
    public func addPhotosToPin(pin:Pin, images: [Data]) {

        guard let viewContext = viewContext, let appDelegate = appDelegate else {
            return
        }
       
        for image in images {
            let photo = Photo(context: viewContext)
            photo.image = image
            photo.pin = pin

            appDelegate.saveContext()
        }
    }
    
    public func getPhotosByPin(pin: Pin) -> [Photo] {
        
        guard let viewContext = viewContext else {
            return []
        }
        
        let predicate = NSPredicate(format: "pin == %@", pin)
        let fetchRequest = NSFetchRequest<Photo>(entityName: "Photo")
        fetchRequest.predicate = predicate
        
        do {
            let data = try viewContext.fetch(fetchRequest)
            PhotoCollectionMetaData.totalPhotosInCurrentPage = data.count
            return data
        }catch{
            debugPrint(error)
        }

        return []
    }
    
    public func deletePhotosByPin(pin: Pin) {
        
        guard let viewContext = viewContext else {
            return
        }

        let predicate = NSPredicate(format: "pin == %@", pin)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
        fetchRequest.predicate = predicate

        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try viewContext.execute(batchDeleteRequest)
            
        }catch{
            debugPrint(error)
        }
    }
    
    public func deletePhoto(photo: Photo) {
        
        guard let viewContext = viewContext, let appDelegate = appDelegate else {
            return
        }

        viewContext.delete(photo)

        appDelegate.saveContext()

    }
}
