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


class RQCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    let cellSize: CGFloat = 100.0
    var collectionItems: [Photo] = Array() {
        didSet(value) {
            pastArrayIndex = collectionItems.count
        }
    }
    
    var pastArrayIndex: Int = 0
    var imageDictionary: [String:UIImage] = Dictionary<String,UIImage>()
    var hasNewCollection: Bool = false
    var service: WebService?

    override func viewDidLoad() {
        super.viewDidLoad()

        //Load PhotoList on viewDidLoad
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        WebService.sharedService.loadPhotoList { list in
            if let validPhotoList = list {
                if self.pastArrayIndex == validPhotoList.count {
                    //No new photos
                    self.hasNewCollection = false
                } else {
                    self.collectionItems = validPhotoList
                    DispatchQueue.main.async {
                        self.hasNewCollection = true
                        self.collectionView?.reloadData()
                        if self.hasNewCollection {
                            print("hit")
                            //self.retrievePhotos()
                        }
                    }
                }
                
            }
        }
    }

    
    //MARK: Photo Retrival
    func retrievePhotos() {
        
        for (index, photoItem) in self.collectionItems.enumerated() {
            
            if let _ = imageDictionary[photoItem.fileThubnailID] {
                self.collectionView?.reloadItems(at: [IndexPath(row: index, section: 0)])
                continue
            }
            
            DispatchQueue.global().async(qos: .userInitiated) {
                
                WebService.sharedService.loadImage(With: photoItem.fileThubnailID) { image in
                    if let realImage = image {

                        let fileImageDirURL = URL(fileURLWithPath:NSTemporaryDirectory())
                        let fileImageURL = fileImageDirURL.appendingPathComponent(photoItem.fileThubnailID + ".png")
                        
                        let data = UIImagePNGRepresentation(realImage)
                        do {
                            try data?.write(to: fileImageURL)
                        } catch {
                            print(error)
                        }
                        
                        print("Got image")
                        
                        //self.imageDictionary[photoItem.fileThubnailID] = realImage
                        
                        DispatchQueue.main.async {
                            print(index)
                            self.collectionView?.reloadItems(at: [IndexPath(row: index, section: 0)])
                        }
                        
                    }
                }
            }
        }
    }
    
    
    func imageForThumbID(thumbID: String, atIndex index: Int) -> UIImage? {

        let fileImageDirURL = URL(fileURLWithPath:NSTemporaryDirectory())
        let fileImageURL = fileImageDirURL.appendingPathComponent(thumbID + ".png")
        
        do {
            let data = try Data(contentsOf: fileImageURL, options:[])
            if let image = UIImage(data: data)  {
                return image
            }

        } catch {
            
            
            DispatchQueue.global().async(qos: .userInitiated) {
                
                WebService.sharedService.loadImage(With: thumbID) { image in
                    if let realImage = image {
                        
                        let scaledImage = self.scaledImage(image: realImage)
                        
                        let fileImageDirURL = URL(fileURLWithPath:NSTemporaryDirectory())
                        let fileImageURL = fileImageDirURL.appendingPathComponent(thumbID + ".png")
                        
                        let data = UIImagePNGRepresentation(scaledImage)
                        do {
                            try data?.write(to: fileImageURL)
                        } catch {
                            print(error)
                        }
                        
                        print("Got image")
                        
                        //self.imageDictionary[photoItem.fileThubnailID] = realImage
                        
                        DispatchQueue.main.async {
                            print(index)
                            self.collectionView?.reloadItems(at: [IndexPath(row: index, section: 0)])
                        }
                        
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
    
    
    // MARK: UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionItems.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! RQCollectionViewCell
        //cell.image = nil
        
        let photoItem = collectionItems[indexPath.row]

        if let photo = imageForThumbID(thumbID: photoItem.fileThubnailID, atIndex: indexPath.row) {
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
        return CGSize(width: view.frame.width, height: view.frame.width)

    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 30)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}


/*
 // MARK: - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 
 
 
 
 
 
 photoWorkItem = DispatchWorkItem(qos: .userInitiated, flags: []) {
 
 for (index, photoItem) in self.collectionItems.enumerated() {
 
 self.service?.loadImage(With: photoItem.fileThubnailID) { image in
 if let realImage = image {
 print("Got image")
 self.collectionItems[index].image = realImage
 DispatchQueue.main.async {
 print("reload collectionView")
 self.collectionView?.reloadData()
 }
 }
 }
 }
 }
 photoRetrivalQueue?.async(execute: photoWorkItem!)
 
 
 
 func singleImageRetrivel() {
 service?.loadImage(With: collectionItems[0].fileThubnailID) { image in
 if let actualImage = image {
 print("got image")
 self.collectionItems[0].image = actualImage
 }
 }
 }
 
 func simpleRetrievePhotos() {
 
 for (index, photoItem) in collectionItems.enumerated() {
 service?.loadImage(With: photoItem.fileThubnailID) { image in
 if let actualImage = image {
 print("got image")
 self.collectionItems[index].image = actualImage
 }
 
 }
 }
 
 }
 
 */

