//
//  RQCollectionViewController.swift
//  iOSResearchPosition
//
//  Created by brendan kerr on 10/20/16.
//  Copyright © 2016 b3k3r. All rights reserved.
//

import UIKit

private let reuseIdentifier = "RQCell"

typealias JSONDictionary = [String:AnyObject]
typealias JSONStringDictionary = [String:String]


//MARK: Photo Struct
struct Photo {
    
    var id: Int
    var title: String
    var fileThubnailID: String
    
    init(_ i: Int, _ t: String, _ f: String) {
        id = i
        title = t
        fileThubnailID = f
    }
}

extension Photo {
    
    init?(_ photoJSON: JSONDictionary) {
        guard let pid = photoJSON["Id"] as? Int,
            let ptitle = photoJSON["Title"] as? String,
            let pfilethumbID = photoJSON["FileThumbnailId"]as? String else {
                return nil
        }
        
        id = pid
        title = ptitle
        fileThubnailID = pfilethumbID
    }
}


class RQCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, RQImageUtilityDelegate {
    
    let cellSize: CGFloat = 100.0
    var collectionItems: [Photo] = Array()
    var imageDictionary: [String:UIImage] = Dictionary<String,UIImage>()
    
    var service: WebService?
    var imageUtility: RQImageUtility?

    /*
     pastArrayIndex and hasNewCollection were checking to determine whether a new list is
     provided.  simply checking count is not enough, a new list coulbe retrieved with the same count 
     as the previous.  Plus the vars were used to determine whether to retrieve or not - this
     has since been eliminated to only retrieve when needed
    */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageUtility = RQImageUtility()
        imageUtility?.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        WebService.sharedService.loadPhotoList { list in
            if let list = list {
                self.collectionItems = list
                DispatchQueue.main.async {
                    self.collectionView?.reloadData()
                }
            }
        }
    }
    
    
    func updateItem(at index:Int) {
        DispatchQueue.main.async {
            print(index)
            self.collectionView?.reloadItems(at: [IndexPath(row: index, section: 0)])
        }
    }
    
    
    // MARK: UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionItems.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! RQCollectionViewCell
        
        let photoItem = collectionItems[indexPath.row]

        if let photo = imageUtility?.imageForThumbID(thumbID: photoItem.fileThubnailID, atIndex: indexPath.row) {
            cell.image = photo
            cell.activityInd.stopAnimating()

        } else {
            cell.image = nil
            cell.activityInd.startAnimating()
        }
        
        return cell
    }
    
    //MARK: Layout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5, left: 2, bottom: 5, right: 2)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 2.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: view.frame.width/3 - 3, height: view.frame.width/3 - 3)
//        return CGSize(width: view.frame.width/2, height: view.frame.width/2)
        return CGSize(width: view.frame.width/1.2, height: view.frame.width/1.2)

    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 30)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}





//    func createIfNeededDownloadDirectory() {
//
//        let baseURL = NSURL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0])
//        let imagesDirURL = baseURL.appendingPathComponent("images")!
//
//        let fileManager = FileManager.default
//        // Create the resources directory if needed
//
//        var directory: ObjCBool = false
//        let exists = fileManager.fileExists(atPath: imagesDirURL.path, isDirectory: &directory)
//        if exists && directory.boolValue {
//            // Exists. Directory.
//        } else if exists {
//            // Exists.
//        }
//
//        if !exists {
//            do {
//                try fileManager.createDirectory(at: imagesDirURL, withIntermediateDirectories: true, attributes: [:])
//            } catch {
//                print(error)
//            }
//        }
//    }



//    func imageForThumbID(thumbID: String, atIndex index: Int) -> UIImage? {
//
//        var needToRetrieve = false
//
//        if let image = imageCache?.object(forKey: thumbID as AnyObject) as? UIImage {
//            debugPrint("image from cache")
//            return image
//        } else {
//            let fileImageDirURL = URL(fileURLWithPath:NSTemporaryDirectory())
//            let fileImageURL = fileImageDirURL.appendingPathComponent(thumbID + ".png")
//
//            do {
//                let data = try Data(contentsOf: fileImageURL, options:[])
//                if let image = UIImage(data: data)  {
//                    self.imageCache?.setObject(image as AnyObject, forKey: thumbID as AnyObject)
//                    debugPrint("image from disk")
//                    return image
//                }
//
//            } catch {
//                needToRetrieve = true
//            }
//        }
//
//        if needToRetrieve {
//
//            DispatchQueue.global().async() {
//                WebService.sharedService.loadImage(With: thumbID) { image in
//                    debugPrint("image from server")
//                    if let realImage = image {
//                        let scaledImage = self.scaledImage(image: realImage)
//
//                        self.imageCache?.setObject(scaledImage as AnyObject, forKey: thumbID as AnyObject)
//                        let data = UIImagePNGRepresentation(scaledImage)
//                        do {
//                            let fileImageDirURL = URL(fileURLWithPath:NSTemporaryDirectory())
//                            let fileImageURL = fileImageDirURL.appendingPathComponent(thumbID + ".png")
//
//                            try data?.write(to: fileImageURL)
//                        } catch {
//                            print(error)
//                        }
//
//                        DispatchQueue.main.async {
//                            print(index)
//                            self.collectionView?.reloadItems(at: [IndexPath(row: index, section: 0)])
//                        }
//
//                    } else {
//
//                        // SHOULD delete the image on disk if truly the image is not available on the server
//                        // but not when there was an error on the retrieval call
//                        // Will need to add some sort of status on the WebService completion
//                        // image data, success = true  (success call has image)
//                        // image nil,  success = true  (success call no image) probably deleted
//                        // image data, success = false (should not happen)
//                        // image nil,  success = false (failed call)
//                    }
//                }
//            }
//        }
//
//        return nil
//    }


//    func scaledImage(image: UIImage) -> UIImage {
//
//        //let image = UIImage(contentsOfFile: self.URL.absoluteString!)
//        let size = image.size.applying(CGAffineTransform(scaleX: 0.10, y: 0.10))
//
//        //let size = CGSizeApplyAffineTransform(image.size, CGAffineTransformMakeScale(0.5, 0.5))
//        let hasAlpha = false
//        let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
//
//        UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
//        image.draw(in: CGRect(origin: CGPoint.zero, size: size))
//
//        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//
//        debugPrint("orig \(image.size) scaled \(scaledImage!.size)")
//
//        return scaledImage!
//    }



