//
//  collectionController.swift
//  virtualTourist
//
//  Created by Hema on 11/25/19.
//  Copyright © 2019 Hema. All rights reserved.
//

import Foundation
import MapKit
import CoreLocation
import CoreData
import UIKit
class  CollectionViewController: UICollectionViewController, NSFetchedResultsControllerDelegate  {


    @IBOutlet weak var deleteNew: UIBarButtonItem!
    @IBOutlet weak var locationMap: MKMapView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var photoCollectionView: UICollectionView!
    var dataController:DataController!
    var sentPinLocation: PinLocation?
  
    var latitude: Float = 0.0
    var longitude: Float = 0.0
    var selectedPhotoCount: Int = 0
    var newLocation: Bool = false
    var pinLocation: PinLocation?
    var totalItem: Int = 0
    var photoData: [PinPhotoData] = []

    var fetchedResultsController:NSFetchedResultsController<PinPhotoData>!
    
    fileprivate func setupFetchedResultsController() {
        let newViewController = UserDefaults.standard.string(forKey: "initialView")
        print(newViewController as Any)
        if (newViewController == "CollectionViewController") {
            getSavedPin()
        }
        else {
            pinLocation = sentPinLocation
        }
        
        let fetchRequest:NSFetchRequest<PinPhotoData> = PinPhotoData.fetchRequest()
        let predicate = NSPredicate(format: "pin == %@", pinLocation!)
        fetchRequest.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "id", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        print("in collection fetch")
        print(pinLocation?.latitude)
        print("before fetch")
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
 
 
        //  fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        //   fetchedResultsController.delegate = self
        //    do {
        //       try fetchedResultsController.performFetch()
        //   } catch {
        //         fatalError("The fetch could not be performed: \(error.localizedDescription)")
        //       }
    }
    
    func reload() {
         print("reloading")
         DispatchQueue.main.async {
                self.collectionView.reloadData()
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
    }
    
    fileprivate func setLayout() {
        //TODO: Implement flowLayout here.
        let space:CGFloat = 3.0
        let dimension = (view.frame.size.width - (2 * space)) / 3.0
        
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setLayout()
        
        //setupFetchedResultsController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupFetchedResultsController()
        if (fetchedResultsController.fetchedObjects!.isEmpty) {
            loadPhoto(newFlag: true)
            newLocation = true
            
        } else {
            print("photos are already present")

        }
       
        
        setMapRegion()
        savePageData()
        if (newLocation) {
            self.reload()
        }
     

    }
    
    
    func savePageData() {
        UserDefaults.standard.set("CollectionViewController", forKey: "initialView")
        UserDefaults.standard.set(pinLocation!.latitude, forKey: "pinlat")
        UserDefaults.standard.set(pinLocation!.longitude, forKey: "pinlong")
        UserDefaults.standard.set(pinLocation?.pageNum, forKey: "pinPageNum")
        print(pinLocation!.latitude)
        print("pin data saved")
        let savLat = UserDefaults.standard.float(forKey: "pinlat")
        print("savLat")
        print(savLat)
    }
    
    func getSavedPin() {
        let savLat = UserDefaults.standard.float(forKey: "pinlat")
        let savLong = UserDefaults.standard.float(forKey: "pinlong")
        let savPageNum = UserDefaults.standard.integer(forKey: "pinPageNum")
        print("loading saved ddata")
        print("savLat")
        print(savLat)
        //print(pinLocation)
        let fetchRequest:NSFetchRequest<PinLocation> = PinLocation.fetchRequest()
        let sortDescriptor1 = NSSortDescriptor(key: "latitude", ascending: false)
        let sortDescriptor2 = NSSortDescriptor(key: "longitude", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor1, sortDescriptor2]
        
        let predicate1 = NSPredicate(format: "latitude = %@", savLat as Float)
        let predicate2 = NSPredicate(format: "longitude = %@", savLong as Float)
        let subpredicates: [NSPredicate]
        subpredicates = [predicate1]
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: subpredicates)
        //fetchRequest.predicate = predicate1
        
        print("before fetch")
        
        var result1 = try? self.dataController.viewContext.fetch(fetchRequest)
        print(result1)
        if (result1!.count > 0) {
            pinLocation = result1![1]
        }
        else {
            print("no data found")
        }
        
    }
    
    fileprivate func setMapRegion() {
        locationMap.delegate = self as? MKMapViewDelegate
        var annotations = [MKPointAnnotation]();
        let coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(pinLocation!.latitude), longitude: CLLocationDegrees(pinLocation!.longitude))
        print("in collection view")
        print(pinLocation!.latitude)
        print(pinLocation!.longitude)
        let newLocation = MKCoordinateRegion(center: coordinate, latitudinalMeters: 20000, longitudinalMeters: 20000);
        let annotation = MKPointAnnotation()
        
        annotation.coordinate = coordinate
        // Finally we place the annotation in an array of annotations.
        annotations.append(annotation)
        // Finally we place the annotation in an array of annotations.
        
        DispatchQueue.main.async {
            self.locationMap.addAnnotation(annotation)
            self.locationMap.setRegion(newLocation, animated: true)
            self.locationMap.regionThatFits(newLocation)
        }
    }
    
    @IBAction func loadMore(){
        print("load more data")
        if selectedPhotoCount > 0 {
            deleteSelected()
        }
        else {
            loadPhoto(newFlag: false)
        }
        reload()
     }
    
    func deleteSelected() {
        print("deleted selected images")
        var pinPhotoData = PinPhotoData(context: dataController.viewContext)
        //fetchedResultsController
        let selectedImages = collectionView.indexPathsForSelectedItems!
        print(selectedImages)
        
        for (newCtr, value) in photoData.enumerated() {
            pinPhotoData = photoData[newCtr]
            dataController.viewContext.delete(pinPhotoData)
            try? dataController.viewContext.save()
         }
        
        deleteNew.title = "New Collection"
  
    }
    
    func loadPhoto(newFlag: Bool) {
        //var pinPhotoData = PinPhotoData(context: dataController.viewContext)
        let removeCurrentImages = fetchedResultsController.fetchedObjects
        for (photos) in removeCurrentImages! {
            dataController.viewContext.delete(photos)
            try? dataController.viewContext.save()
            print("data deleted")
        }
        
        deleteNew.isEnabled = false
       /*
        print("need to reload data")
        let fetchRequest:NSFetchRequest<PinPhotoData> = PinPhotoData.fetchRequest()
        let predicate = NSPredicate(format: "pin == %@", pinLocation!)
        fetchRequest.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "id", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        */
       
        DispatchQueue.main.async {
            //virtualTouristClient.getPictures(pinLocation: self.pinLocation!, completion: self.handlePhotoResponse(error:))
            virtualTouristClient.getPictures(pinLocation: self.pinLocation!, newFlag: newFlag){error in
                if (error != nil) {
                    print(error as Any)
                }
                else
                {
                    /*result1 = try? self.dataController.viewContext.fetch(fetchRequest)
                    if (!(result1 != nil)){
                        fatalError("The fetch could not be performed: ")
                    }
                    else {
                        photoList = result1!
                        print("have data now")
                        self.reload()
                    }
  */
                }
 
            }
            self.deleteNew.isEnabled = true
        }

    }
    
    // MARK: Collection View Data Source
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("photolist count")
        totalItem = fetchedResultsController.sections?[section].numberOfObjects ?? 0
        print(totalItem)
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchedResultsController.sections?.count ?? 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("loading image")
        var pinPhotoData = PinPhotoData(context: dataController.viewContext)
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionViewCell", for: indexPath) as! PhotoCollectionViewCell
        let photoCollcetionCell = fetchedResultsController.object(at: indexPath)
        
        let urlData =  photoCollcetionCell.url_m
        let imageURL = URL(string: urlData!)
        cell.photoImg.image = UIImage(imageLiteralResourceName:"camera.png")
        if let imageData = try? Data(contentsOf: imageURL!) {
            DispatchQueue.main.async {
                cell.photoImg.image = UIImage(data: imageData)!
                
            }
        }
        print("retutning cell")
        if (photoCollcetionCell.isSelected) {
            cell.backgroundColor = UIColor.black.withAlphaComponent(1)
            selectedPhotoCount = selectedPhotoCount + 1
            pinPhotoData = fetchedResultsController.object(at: indexPath)
            photoData.append(pinPhotoData)
            print("selected data")
            print(indexPath)
            print(urlData)
        }
        if (selectedPhotoCount > 0) {
            deleteNew.title = "Remove Selected Pictures"
        }
        
        return cell
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath:IndexPath) {
        print("selected")
        print(indexPath)
        let abc = collectionView.cellForItem(at: indexPath)
 
        let photoAtCell:PinPhotoData
        photoAtCell = fetchedResultsController.object(at: indexPath)
        photoData.append(photoAtCell)
        
        if (photoAtCell.isSelected){
            abc?.backgroundColor = UIColor.white.withAlphaComponent(1)
            photoAtCell.isSelected = false
            selectedPhotoCount = selectedPhotoCount - 1
        }
        else {
            abc?.backgroundColor = UIColor.black.withAlphaComponent(1)
            photoAtCell.isSelected = true
            selectedPhotoCount = selectedPhotoCount + 1
            print(selectedPhotoCount)
        }
        
        try? dataController.viewContext.save()
        if (selectedPhotoCount > 0) {
            print(selectedPhotoCount)
            deleteNew.title = "Remove Selected Pictures"
        }
        
    }
    
}

extension CollectionViewController {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            photoCollectionView.insertItems(at: [newIndexPath!])
            break
        case .delete:
            photoCollectionView.deleteItems(at: [indexPath!])
            break
        case .update:
            break
        case .move:
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        let indexSet = IndexSet(integer: sectionIndex)
        switch type {
        case .insert: photoCollectionView.insertSections(indexSet)
        case .delete: photoCollectionView.deleteSections(indexSet)
        case .update, .move:
            fatalError("Invalid change type in controller(_:didChange:atSectionIndex:for:). Only .insert or .delete should be possible.")
        }
    }

}



