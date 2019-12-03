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
import UIKit
class  CollectionViewController: UICollectionViewController {


    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var photoCollectionView: UICollectionView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //TODO: Implement flowLayout here.
        let space:CGFloat = 3.0
        let dimension = (view.frame.size.width - (2 * space)) / 3.0
        
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
    
        //photoCollectionView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
         print("in collection view")
    }
    
 

    
    // MARK: Collection View Data Source
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(photoList.count)
        return photoList.count
    }
       
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionViewCell", for: indexPath) as! PhotoCollectionViewCell
        let photoCollcetionCell = photoList[(indexPath as NSIndexPath).row]
      
       
        let urlData =  photoCollcetionCell.url_m
        let imageURL = URL(string: urlData)
        cell.photoImg.image = UIImage(imageLiteralResourceName:"camera.png")
        if let imageData = try? Data(contentsOf: imageURL!) {
            DispatchQueue.main.async {
                cell.photoImg.image = UIImage(data: imageData)!
                
            }
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath:IndexPath) {
        
         print("selected")
        

        
    }
    
    
}

