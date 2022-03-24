//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Dilip Agheda on 16/3/22.
//

import UIKit
import CoreData
import MapKit

class PhotoCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
}

class PhotoAlbumViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!

    @IBOutlet weak var activityView: UIActivityIndicatorView!
    
    @IBOutlet weak var newCollectionButton: UIButton!
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var noImagesLabel: UILabel!
    
    var photos: [Photo] = []
    
    var pin: Pin?
    
    func setupCollectionViewLayout() {
        
        let screenWidth = UIScreen.main.bounds.size.width
        let totalItems:CGFloat = 3
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        var side = (screenWidth - 2*(totalItems-1) ) / totalItems

        side = side.rounded(.towardZero)
        
        layout.itemSize = CGSize(width: side, height: side)
        layout.minimumInteritemSpacing = 2
        layout.minimumLineSpacing = 2

        collectionView!.collectionViewLayout = layout
    }
    
    func isLoading(status: Bool) {
        if(status == true) {
            activityView.startAnimating()
            newCollectionButton.isEnabled = false
        }else {
            activityView.stopAnimating()
            newCollectionButton.isEnabled = true
        }
    }
    
    @IBAction func onTapNewCollection(_ sender: Any) {
        
        //PhotoCollectionMetaData.totalPhotosInCurrentPage = 0
        self.photos = []
        self.collectionView.reloadData()
        
        //invalidate currently stored local photos
        DataService.shared.deletePhotosByPin(pin: self.pin!)
        initiatePhotosRetrieval()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        noImagesLabel.isHidden = true
        
        newCollectionButton.layer.cornerRadius = 0
        newCollectionButton.clipsToBounds = false
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        let lat = CLLocationDegrees(pin!.latitude)
        let long = CLLocationDegrees(pin!.longitude)
        
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        
        self.mapView.addAnnotation(annotation)
        
        let region = MKCoordinateRegion( center: annotation.coordinate, latitudinalMeters: CLLocationDistance(exactly: 10000)!, longitudinalMeters: CLLocationDistance(exactly: 10000)!)
        self.mapView.setRegion(mapView.regionThatFits(region), animated: true)
        
        setupCollectionViewLayout()

        initiatePhotosRetrieval()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewWillLayoutSubviews() {
        
        super.viewWillLayoutSubviews()
        self.collectionView.collectionViewLayout.invalidateLayout()
        setupCollectionViewLayout()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return PhotoCollectionMetaData.totalPhotosInCurrentPage
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell( withReuseIdentifier: "imageCell", for: indexPath) as! PhotoCollectionViewCell
        
        if(self.photos.isEmpty) {
            cell.imageView.image = UIImage(named: "placeholder")
            
        }else{              
            let row = indexPath.row

            let photoData = self.photos[row].image
            
            if let photoData = photoData {
                cell.imageView.image = UIImage(data: photoData)
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let row = indexPath.row

        let photo = self.photos[row]
        
        self.photos.remove(at: row)
        
        PhotoCollectionMetaData.totalPhotosInCurrentPage = self.photos.count
        
        DataService.shared.deletePhoto(photo: photo)
        
        self.collectionView.reloadData()
    }
}
