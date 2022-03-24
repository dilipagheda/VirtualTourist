//
//  TravelLocationsMapViewController.swift
//  VirtualTourist
//
//  Created by Dilip Agheda on 22/3/22.
//

import Foundation
import UIKit
import MapKit

class TravelPointAnnotation: MKPointAnnotation {
    
    var pin: Pin!
}

class TravelLocationsMapViewController : UIViewController, MKMapViewDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!

    var longTapGesture: UILongPressGestureRecognizer!

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        configureLongTapGesture()
       
        mapView.delegate = self
        
        self.refresh()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        for annotation in mapView.selectedAnnotations {
            mapView.deselectAnnotation(annotation, animated: false)
        }
    }
    
    private func configureLongTapGesture() {
        
        longTapGesture = UILongPressGestureRecognizer(target: self, action: #selector(longTapGestureHandler(_:)))
        longTapGesture.minimumPressDuration = 0.5
        longTapGesture.delegate = self
        mapView.addGestureRecognizer(longTapGesture)
    }
    
    @objc func longTapGestureHandler(_ gestureRecognizer: UIGestureRecognizer) {
        
        let touchedScreenLocation = gestureRecognizer.location(in: self.mapView)
        let touchedGeoLocation : CLLocationCoordinate2D = mapView.convert(touchedScreenLocation, toCoordinateFrom: self.mapView)
        
        debugPrint(touchedGeoLocation)
        
        DataService.shared.addPin(latitude: touchedGeoLocation.latitude, longitude: touchedGeoLocation.longitude)
        
        self.refresh()
    }
    
    public func refresh() {
       
        self.configureMapView()
    }
    
    private func setMapRegion(coordinate: CLLocationCoordinate2D?) {
        
        let region = AppSettingsService.getRegion()
        
        if let region = region {
            
            self.mapView.setRegion(mapView.regionThatFits(region), animated: true)
            
            return
        }
        
        if let coordinate = coordinate {
            
            let defaultRegion = MKCoordinateRegion( center: coordinate, latitudinalMeters: CLLocationDistance(exactly: 100000)!, longitudinalMeters: CLLocationDistance(exactly: 100000)!)
            
            self.mapView.setRegion(mapView.regionThatFits(defaultRegion), animated: true)
            
            return
        }

        let defaultRegion = MKCoordinateRegion( center: CLLocationCoordinate2D(latitude: -33.865143, longitude: 151.209900), latitudinalMeters: CLLocationDistance(exactly: 100000)!, longitudinalMeters: CLLocationDistance(exactly: 100000)!)
        
        self.mapView.setRegion(mapView.regionThatFits(defaultRegion), animated: true)
    }
    
    private func configureMapView() {

        let pins = DataService.shared.getPins()
        
        if(pins.isEmpty) {
            setMapRegion(coordinate: nil)
            return
        }
        
        var annotations = [MKPointAnnotation]()
        
        for pin in pins {

            let lat = CLLocationDegrees(pin.latitude)
            let long = CLLocationDegrees(pin.longitude)
            
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            let annotation = TravelPointAnnotation()
            annotation.coordinate = coordinate
            annotation.pin = pin
            
            annotations.append(annotation)
        }
        
        self.mapView.addAnnotations(annotations)
        
        setMapRegion(coordinate: annotations[0].coordinate)

    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView

        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        let travelPointAnnotation = view.annotation as! TravelPointAnnotation
        let pin = travelPointAnnotation.pin

        performSegue(withIdentifier: "showPhotoAlbum", sender: pin)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if(segue.identifier == "showPhotoAlbum") {
            let photoAlbumVC = segue.destination as! PhotoAlbumViewController
            let pin = sender as! Pin
            photoAlbumVC.pin = pin
        }
    }

    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        
        AppSettingsService.setRegion(region: mapView.region)
    }
    
}
