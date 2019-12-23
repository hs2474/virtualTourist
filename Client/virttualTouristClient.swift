//
//  virttualSwiftClient.swift
//  virtualTourist
//
//  Created by Hema on 11/26/19.
//  Copyright © 2019 Hema. All rights reserved.
//


import Foundation
import MapKit
import CoreLocation
import CoreData
class virtualTouristClient {
    
    
    enum Endpoints {
        static let base = "https://api.flickr.com/services/rest/?method=flickr.photos.search&format=json&extras=url_m&api_key=18d6de5d7b93aa3de79ca601b0086b58"
        
        case getInitialMapData(newlat:Float, newLon:Float)
        case loadPhoto(newlat:Float, newLon:Float, pageNum:Int)

        var stringValue: String {
            switch self {
            case .getInitialMapData(let newlat, let newLon): return Endpoints.base + "&lat=\(newlat)" + "&lon=\(newLon)"
            
            case .loadPhoto(let newlat, let newLon, let pageNum): return Endpoints.base + "&lat=\(newlat)" + "&lon=\(newLon)" + "&pageNum=\(pageNum)"
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
        
    }

    
    
   class func taskForGETRequestNew<ResponseType: Decodable>(url: URL, delChars:Bool, responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) -> URLSessionDataTask {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {print("Your request returned a status code other than 2xx!")
                completion(nil, error)
                return
            }
            
            
            let range = 14..<data.count
            var newData = data.subdata(in: range)
            //newData = data.subdata(in: range) /* subset response data! */
            newData.remove(at: newData.endIndex - 1)
            
            print(String(data: newData, encoding: .utf8)!)
            print("after get name")
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(ResponseType.self, from: newData)
                DispatchQueue.main.async {
                    print("here")
                    //print(responseObject)
                    completion(responseObject, nil)
                }
            } catch {
                do {
                    let errorResponse = try decoder.decode(ResponseMap.self, from: newData) as Error
                    DispatchQueue.main.async {
                        completion(nil, errorResponse)
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                }
            }
            
        }
        task.resume()
        
        return task
        
    }


    class func  getPictures(pinLocation: PinLocation, newFlag: Bool, completion: (@escaping ( Error?) -> Void) ) {
        let newlat = pinLocation.latitude
        let newLon = pinLocation.longitude
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let dataController = appDelegate.dataController
        var pageNum = 1
        if (!newFlag) {
            pageNum = Int(pinLocation.pageNum)
            pageNum = pageNum + 1
            pinLocation.pageNum = Int32(pageNum)
            try? dataController.viewContext.save()
        }
        
        let newUrl = Endpoints.loadPhoto(newlat:  newlat, newLon: newLon, pageNum: pageNum).url
        
        print(newUrl)
        
        taskForGETRequestNew(url:newUrl,  delChars:true, responseType: Flickr.self)
            { response, error in
            print("after call")
            if let response = response {
                print("no pages")
                print(response.flickr.currentPageNumber)

              //  var newPhoto = PhotoImg(id:"", url_m:"")
                
                for (_, value) in response.flickr.photos.enumerated()
                {
                    let id = value.id
                    let url_m  = value.url_m

                    print(id);
                    print(url_m)
                    let pinPhotoData = PinPhotoData(context: dataController.viewContext)
                    pinPhotoData.id = id
                    pinPhotoData.url_m = url_m
                    pinPhotoData.pin = pinLocation
                   
                    try? dataController.viewContext.save()
                   // newPhoto = PhotoImg(id:id, url_m:url_m)
                    //photoList.append(newPhoto)
                }

            completion(nil)
        }
        else {
            completion(error)
        }
        
       }

    }
}
