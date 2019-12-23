//
//  ViewController.swift
//  virtualTourist
//
//  Created by Hema on 11/23/19.
//  Copyright © 2019 Hema. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate, NSFetchedResultsControllerDelegate  {
    
    var numTaps = 0

    @IBOutlet weak var bottomToolBar: UIToolbar!
    @IBOutlet weak var mapView: MKMapView!
    

    
    var dataController:DataController!
    var pinLocations: [PinLocation] = []
    var ctr:Int = 0
    var fetchedResultsController:NSFetchedResultsController<PinLocation>!
    
    fileprivate func setupFetchedResultsController() {
        let fetchRequest:NSFetchRequest<PinLocation> = PinLocation.fetchRequest()
        let sortDescriptor1 = NSSortDescriptor(key: "latitude", ascending: false)
        let sortDescriptor2 = NSSortDescriptor(key: "longitude", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor1, sortDescriptor2]

        if let result = try? dataController.viewContext.fetch(fetchRequest) {
            pinLocations = result
            printMap()
        }
      
    }
    
    override func viewDidLoad() {
        print("view did load")
        super.viewDidLoad()
        
        let newViewController = UserDefaults.standard.string(forKey: "initialView")
        print(newViewController as Any)
        
        if (newViewController == "CollectionViewController") {
            let collectionController = self.storyboard!.instantiateViewController(withIdentifier: "CollectionViewController") as! CollectionViewController
            collectionController.dataController = dataController
            self.navigationController?.pushViewController(collectionController, animated: true)
        }
        mapView.delegate = self
        mapView.isUserInteractionEnabled = true // To detect the user events.
        
        setupFetchedResultsController()
    }

    override func viewDidAppear(_ animated: Bool) {
        print("view did appear")
        super.viewDidAppear(animated)
        DispatchQueue.main.async {
            if UserDefaults.standard.bool(forKey: "hasLaunchedBefore") {
                print("App has launched before")
                self.loadSavedMap()
            }
        }
    }
 
    override func viewWillAppear(_ animated: Bool) {
        print("view will appear")
        super.viewWillAppear(animated)
        
         //self.navigationController?.setNavigationBarHidden(false, animated: animated)
     }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
    }
    
    private func loadSavedMap() {
        print("in load map")
        UserDefaults.standard.set("MapViewController", forKey: "initialView")
        if UserDefaults.standard.float(forKey: "savedLatitude") != 0 {
            print("saved location is being loaded")
            let latitude = UserDefaults.standard.double(forKey: "savedLatitude")
            let longitude = UserDefaults.standard.double(forKey: "savedLongitude")
            let latitudeSpan = UserDefaults.standard.double(forKey: "savedlatitudeDelta")
            let longitudeSpan = UserDefaults.standard.double(forKey: "savedlongitudeDelta")
            let savedLocation = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            print(latitude)
            print(longitude)
            print("latspan: ")
            
            print(latitudeSpan)
            print("longspan: ")
            print(latitudeSpan)
            
            mapView.region = MKCoordinateRegion(center: savedLocation, span: MKCoordinateSpan(latitudeDelta: latitudeSpan, longitudeDelta: longitudeSpan))
        }
        else
        {
            print("saved data is 0")
        }
        print("here...is it ok")
        if UserDefaults.standard.bool(forKey: "pinEditMode"){
            bottomToolBar.isHidden = false
         }
        else
        {
             print("value is false")
            bottomToolBar.isHidden = true
        }
    }
    
    func printMap() {
        var annotations = [MKPointAnnotation]();
        for (_, value) in pinLocations.enumerated() {
            let lat = CLLocationDegrees(value.latitude)
            let long = CLLocationDegrees(value.longitude)
            
            // The lat and long are used to create a CLLocationCoordinates2D instance.
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            // Here we create the annotation and set its coordiate, title, and subtitle properties
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            // Finally we place the annotation in an array of annotations.
            annotations.append(annotation)
 
         }
        DispatchQueue.main.async {
            self.mapView.addAnnotations(annotations)
        }
        
    }

    @IBAction func enableEdit () {
        bottomToolBar.isHidden = false
        UserDefaults.standard.set(true, forKey: "pinEditMode")
    }
    
    @IBAction func disableEdit () {
        bottomToolBar.isHidden = true
        UserDefaults.standard.set(false, forKey: "pinEditMode")
    }
    

    @IBAction func handleLongTap(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            print("long tapped once")
            // Add an annotation as soon as the long press is ended
            let tapPoint = sender.location(in: mapView)
            let coordinates = mapView.convert(tapPoint, toCoordinateFrom: mapView)
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinates

            mapView.addAnnotation(annotation)
            //pin needs to persist
            let newPinLocation = PinLocation(context: dataController.viewContext)
            newPinLocation.latitude = Float(coordinates.latitude)
            newPinLocation.longitude = Float(coordinates.longitude)
            newPinLocation.pageNum = 1
            try? dataController.viewContext.save()
            
            pinLocations.append(newPinLocation)
            
         
        }
    }
    
    
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView)
    {
        print("map region changed")
        let region = mapView.region.center
        let savedLatitude = Float(region.latitude)
        let savedLongitude = Float(region.longitude)
        let savedlatitudeDelta = Float(mapView.region.span.latitudeDelta)
        let savedlongitudeDelta = Float(mapView.region.span.longitudeDelta)
       
        UserDefaults.standard.set(savedLatitude, forKey: "savedLatitude")
        UserDefaults.standard.set(savedLongitude, forKey: "savedLongitude")
        UserDefaults.standard.set(savedlatitudeDelta, forKey: "savedlatitudeDelta")
        UserDefaults.standard.set(savedlongitudeDelta, forKey: "savedlongitudeDelta")
        UserDefaults.standard.synchronize()

    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView)
    {
        print("pin was tapped")
        let pin = view.annotation
        let newLat  = pin?.coordinate.latitude
        let newLon = pin?.coordinate.longitude
        print(newLat as Any)
        print(newLon as Any)
        
        var newCtr = 0
        var intCtr = 0
        
        for (newCtr, value) in pinLocations.enumerated() {
            if (Float(pinLocations[newCtr].latitude) == Float(newLat!) && Float(pinLocations[newCtr].longitude) == Float(newLon!)) {
                intCtr = newCtr
                break
            }
         }
        print(intCtr)
        let pinAtlocation:PinLocation
        pinAtlocation = pinLocations[intCtr]
     
        if UserDefaults.standard.bool(forKey: "pinEditMode"){
            self.mapView.removeAnnotation(pin!)
            dataController.viewContext.delete(pinAtlocation)
            try? dataController.viewContext.save()
        }
        else
        {
           // virtualTouristClient.getPictures(newlat:newLat, newLon:newLon, completion: loadPhotos(error:))
            let collectionController = self.storyboard!.instantiateViewController(withIdentifier: "CollectionViewController") as! CollectionViewController
 
            collectionController.dataController = dataController
            collectionController.sentPinLocation = pinAtlocation
            print("going to collection")
            print(pinAtlocation.latitude)
            print(pinAtlocation.longitude)
            
            self.navigationController?.pushViewController(collectionController, animated: true)
           
        }
    }
    
    func loadPhotos(error: Error?) {
        if (error != nil) {
            self.showLoadFailure(message: error as! String)
        }
        print("after data load")
        let collectionController = self.storyboard!.instantiateViewController(withIdentifier: "CollectionViewController") as! CollectionViewController
        self.present(collectionController, animated: true, completion: nil)

    }


    func showLoadFailure(message: String) {
        let alertVC = UIAlertController(title: "Photo Load Failed", message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        //show(alertVC, sender: nil)
        self.present(alertVC, animated: true,  completion: nil)
        
    }

}

