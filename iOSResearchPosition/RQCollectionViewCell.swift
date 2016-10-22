//
//  RQCollectionViewCell.swift
//  iOSResearchPosition
//
//  Created by brendan kerr on 10/20/16.
//  Copyright © 2016 b3k3r. All rights reserved.
//

import UIKit

class RQCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var cellImageView: UIImageView!
    var image: UIImage? {
        willSet(newValue) {
            cellImageView.image = newValue
        }
    }
    @IBOutlet weak var activityInd: UIActivityIndicatorView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        print("cellViewInit")
        backgroundColor = UIColor.gray
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        print("cellViewInit")
        backgroundColor = UIColor.gray
    }
    
    
}
