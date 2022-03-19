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
    
    public func addPin(latitude: Double, longitude: Double) {
        
        guard let viewContext = viewContext, let appDelegate = appDelegate else {
            return
        }
       
        let pin = Pin(context: viewContext)
        pin.latitude = latitude
        pin.longitude = longitude
        
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
    
    public func addPhotoToPin(pin:Pin, image: Data) {
        
        guard let viewContext = viewContext, let appDelegate = appDelegate else {
            return
        }
       
        let photo = Photo(context: viewContext)
        photo.image = image
        pin.addToPin(photo)

        appDelegate.saveContext()

    }
    
    public func addPhotosToPin(pin:Pin, images: [Data]) {

        guard let viewContext = viewContext, let appDelegate = appDelegate else {
            return
        }
       
        for image in images {
            let photo = Photo(context: viewContext)
            photo.image = image
            pin.addToPin(photo)
        }

        appDelegate.saveContext()
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
            return data
        }catch{
            debugPrint(error)
        }

        return []
    }
}
