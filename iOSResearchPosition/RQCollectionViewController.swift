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
                self.imageUtility?.cleanImagesDirectory()
                
                self.collectionItems = list
                DispatchQueue.main.async {
                    self.collectionView?.reloadData()
                }
            }
        }
    }
    
    // MARK: -
    
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




