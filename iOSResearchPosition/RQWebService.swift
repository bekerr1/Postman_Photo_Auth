//
//  RQWebService.swift
//  iOSResearchPosition
//
//  Created by brendan kerr on 10/20/16.
//  Copyright © 2016 b3k3r. All rights reserved.
//

import UIKit
import Alamofire


final class WebService {
    
    
    var validToken: String?
    
    let photoListBase: URL = URL(string: "http://ec2-107-21-15-164.compute-1.amazonaws.com/api/photoslist")!
    let photoUploadBase: URL = URL(string: "http://ec2-107-21-15-164.compute-1.amazonaws.com/api/file/add")!
    let photoListAddBase: URL = URL(string: "http://ec2-107-21-15-164.compute-1.amazonaws.com/api/photoslist/add")!
    let loginBase: URL = URL(string: "http://ec2-107-21-15-164.compute-1.amazonaws.com/api/login")!
    var photoBase: URL = URL(string: "http://ec2-107-21-15-164.compute-1.amazonaws.com/api/file")!
    
    static let sharedService = WebService()
    
    func hasValidToken() -> Bool {
        return validToken != nil
    }
    
    func authHeader() -> HTTPHeaders {
        return [ "Authorization" : "BEARER \(validToken!)" ]
    }
    
    
    func loadToken(withUser user: User, Completion complete: @escaping (Bool) -> ()) {
        
        //let parameters: Parameters = ["email": user.email,
        //                              "password": user.password]
        //test
        let parameters: Parameters = ["email": "user@test.com",
                                      "password": "test"]
        
        Alamofire.request(loginBase, method: .post, parameters: parameters, encoding: URLEncoding(destination: .httpBody)).responseJSON { response in
            
            switch response.result {
            case .success:
                if let json = response.result.value as? Dictionary<String, AnyObject> {
                    //let errorCode = json["status"]
                    if let token = json["token"] as? String {
                        self.validToken = token
                        complete(true)
                    }
                }
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    
    
    func loadPhotoList(_ completion: @escaping ([Photo]?) -> ()) {
        
        if hasValidToken() {
            
            let headers: HTTPHeaders = authHeader()
            
            Alamofire.request(photoListBase, method: .get, headers: headers).responseData { response in
                
                switch response.result {
                case .success:
                    if let json = try? JSONSerialization.jsonObject(with: response.result.value!, options: []) as! JSONDictionary {
                        
                        if let photolist = json["photoslist"] as? [JSONDictionary] {
                            
                            let photoResult = photolist.flatMap(Photo.init)
                            completion(photoResult)
                            
                        }
                    }
                    
                    completion(nil)
                    
                case .failure(let error):
                    print(error)
                }
                
                
            }
        }
    }
    
    
    func loadImage(With src: String, Completion complete: @escaping (UIImage?) -> ()) {
        
        if hasValidToken() {
            
            let currentPhoto: URL = photoBase.appendingPathComponent(src)
            print(currentPhoto)
            
            let headers: HTTPHeaders = authHeader()
            
            Alamofire.request(currentPhoto, headers: headers).responseData { response in
                if let data = response.result.value {
                    guard let image = UIImage(data: data) else {
                        complete(nil)
                        return
                    }
                    complete(image)
                }
            }
        }
    }
    
    
    func uploadImage(named name: String, WithURL imageURL: URL, Progress prog: @escaping (Request.ProgressHandler), Completion complete: @escaping (Bool) -> ()) {
        
        let headers = authHeader()
        
        
        Alamofire.upload(multipartFormData: { multipartForm in
            multipartForm.append(imageURL, withName: "newFile")
            },
                         to: photoUploadBase, method: .post, headers: headers, encodingCompletion: { encoding in
                            switch encoding {
                            case .success(let request, _, _):
                                request
                                    .uploadProgress(closure: prog)
                                    .responseJSON { response in
                                    debugPrint(response.result.value)
                                    switch response.result {
                                    case .success(let value as JSONDictionary):
                                        if let fileData = value["file"] as? JSONDictionary {
                                            if let id = fileData["Id"] as? String {
                                                self.uploadToList(ByName: name, Thumbnail: id, Complete: complete)
                                            }
                                            
                                         }
                                    case .failure(let error):
                                        print(error)
                                        
                                    default:
                                        print("who cares")
                                    }
                                }
                            case .failure(let encodingError):
                                debugPrint(encodingError)
                            }
        })
        
    }
    
    
    func uploadToList(ByName name: String, Thumbnail tn: String, Complete completion: @escaping (Bool) -> ()) {
        
        let headers = authHeader()
        let params = ["title" : name, "thumbnailFileId" : tn]
        
        Alamofire.request(photoListAddBase, method: .post, parameters: params, encoding: URLEncoding(destination: .httpBody), headers: headers).responseJSON { response in
            
            switch response.result {
            case .success(_):
                completion(true)
            case .failure(let error):
                print(error)
            }
            
        }
    }
    
}

/*
if let json = response.result.value as? Dictionary<String, AnyObject> {
    print(json)
    if let photolist = json["photolist"] as? [JSONStringDictionary] {
        
        let photoResult = photolist.flatMap(Photo.init)
        completion(photoResult)
        
}
 
 
 
 */
