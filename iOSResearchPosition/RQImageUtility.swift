//
//  RQImageUtility.swift
//  iOSResearchPosition
//
//  Created by JOSEPH KERR on 10/22/16.
//  Copyright © 2016 b3k3r. All rights reserved.
//

//import Foundation
import UIKit

protocol RQImageUtilityDelegate {
    func updateItem(at index:Int)
}

class RQImageUtility {
    
    let baseURL = NSURL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0])
    var imagesDirURL : URL?
    var imageCache: NSCache<AnyObject, AnyObject>?

    var delegate : RQImageUtilityDelegate?
    
    init() {
        imagesDirURL = baseURL.appendingPathComponent("images")!
        imageCache = NSCache()
        createIfNeededDownloadDirectory()
    }
    
    
    func imageForThumbID(thumbID: String, atIndex index: Int) -> UIImage? {
        
        var needToRetrieve = false
        
        if let image = imageCache?.object(forKey: thumbID as AnyObject) as? UIImage {
            debugPrint("image from cache")
            return image
            
        } else {
            if let fileImageURL = imagesDirURL?.appendingPathComponent(thumbID + ".png") {
                
                do {
                    let data = try Data(contentsOf: fileImageURL, options:[])
                    if let image = UIImage(data: data)  {
                        self.imageCache?.setObject(image as AnyObject, forKey: thumbID as AnyObject)
                        debugPrint("image from disk")
                        return image
                    }
                    
                } catch {
                    needToRetrieve = true
                }
            }
        }
        
        if needToRetrieve {
            
            DispatchQueue.global().async() {
                WebService.sharedService.loadImage(With: thumbID) { image in
                    debugPrint("image from server")
                    if let realImage = image {
                        let scaledImage = self.scaledImage(image: realImage)
                        
                        self.imageCache?.setObject(scaledImage as AnyObject, forKey: thumbID as AnyObject)
                        
                        if let fileImageURL = self.imagesDirURL?.appendingPathComponent(thumbID + ".png") {
                            
                            let data = UIImagePNGRepresentation(scaledImage)
                            do {
                                try data?.write(to: fileImageURL)
                            } catch {
                                print(error)
                            }
                        }
                        
                        DispatchQueue.main.async {
                            print(index)
                            self.delegate?.updateItem(at: index)
//                            self.collectionView?.reloadItems(at: [IndexPath(row: index, section: 0)])
                        }
                        
                    } else {
                        
                        // SHOULD delete the image on disk if truly the image is not available on the server
                        // but not when there was an error on the retrieval call
                        // Will need to add some sort of status on the WebService completion
                        // image data, success = true  (success call has image)
                        // image nil,  success = true  (success call no image) probably deleted
                        // image data, success = false (should not happen)
                        // image nil,  success = false (failed call)
                    }
                }
            }
        }
        
        return nil
    }
    
    
    func scaledImage(image: UIImage) -> UIImage {
        
        //let image = UIImage(contentsOfFile: self.URL.absoluteString!)
        let size = image.size.applying(CGAffineTransform(scaleX: 0.10, y: 0.10))
        
        //let size = CGSizeApplyAffineTransform(image.size, CGAffineTransformMakeScale(0.5, 0.5))
        let hasAlpha = false
        let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
        
        UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
        image.draw(in: CGRect(origin: CGPoint.zero, size: size))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        debugPrint("orig \(image.size) scaled \(scaledImage!.size)")
        
        return scaledImage!
    }
    
    
    private func createIfNeededDownloadDirectory() {
        
        let baseURL = NSURL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0])
        let imagesDirURL = baseURL.appendingPathComponent("Images")!
        
        let fileManager = FileManager.default
        // Create the  directory if needed
        var directory: ObjCBool = false
        let exists = fileManager.fileExists(atPath: imagesDirURL.path, isDirectory: &directory)
        if exists && directory.boolValue {
            // Exists. Directory.
        } else if exists {
            // Exists.
        }
        
        if !exists {
            do {
                try fileManager.createDirectory(at: imagesDirURL, withIntermediateDirectories: true, attributes: [:])
            } catch {
                print(error)
            }
        }
    }

    
    
    func cleanImagesDirectory() {
        let fileManager = FileManager.default
        if let enumerator = fileManager.enumerator(atPath: imagesDirURL!.path) {
            while let element = enumerator.nextObject() as? String {
                if let removeURL = imagesDirURL?.appendingPathComponent(element) {
                    do {
                        try fileManager.removeItem(at: removeURL)
                    } catch {
                        
                    }
                }
            }
        }
    }

    
    
    
    
    
}
