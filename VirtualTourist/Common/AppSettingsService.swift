//
//  AppSettingsService.swift
//  VirtualTourist
//
//  Created by Dilip Agheda on 23/3/22.
//

import Foundation
import MapKit

class AppSettingsService {
    
    static public func setRegion(region: MKCoordinateRegion) {

            let longitude = region.center.longitude
            let latitude = region.center.latitude
            let latitudeDelta = region.span.latitudeDelta
            let longitudeDelta = region.span.longitudeDelta
            
            UserDefaults.standard.set(longitude, forKey: "longitude")
            UserDefaults.standard.set(latitude, forKey: "latitude")
            UserDefaults.standard.set(latitudeDelta, forKey: "latitudeDelta")
            UserDefaults.standard.set(longitudeDelta, forKey: "longitudeDelta")
    }
    
    static public func getRegion() -> MKCoordinateRegion? {
        
        let longitude = UserDefaults.standard.double(forKey: "longitude")
        let latitude = UserDefaults.standard.double(forKey: "latitude")
        
        if(longitude == 0 && latitude == 0) {
            return nil
        }
        
        let latitudeDelta = UserDefaults.standard.double(forKey: "latitudeDelta")
        let longitudeDelta = UserDefaults.standard.double(forKey: "longitudeDelta")

        let center =  CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let span = MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
        
        let region = MKCoordinateRegion(center: center, span: span)
        return region
    }
}
