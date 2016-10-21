//
//  RQUploadViewController.swift
//  iOSResearchPosition
//
//  Created by brendan kerr on 10/21/16.
//  Copyright © 2016 b3k3r. All rights reserved.
//

import UIKit

class RQUploadViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var imagePicker: UIImagePickerController?
    var imageData: Data?
    var imageURL: URL?
    
    @IBOutlet weak var currentUploadItem: UIImageView!
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var progressBarView: UIProgressView!
    @IBOutlet weak var actionButton: UIButton!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imagePicker = UIImagePickerController()
        imagePicker?.delegate = self
        imagePicker?.sourceType = .photoLibrary
        present(imagePicker!, animated: true, completion: nil)
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let _ = currentUploadItem.image {
            actionButton.titleLabel?.text = "Upload"
        } else {
            actionButton.titleLabel?.text = "Select Photo"
        }
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        //
        imagePicker?.dismiss(animated: true, completion: nil)
        
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func getTempDirectory() -> URL {
        let paths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        for dir in paths {
            print(dir)
        }
        
        return paths[0]
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print(info)
        if let ogImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            
            self.currentUploadItem.image = ogImage
            
            if let data = UIImagePNGRepresentation(ogImage) {
                let filename = getTempDirectory().appendingPathComponent("copy.png")
                //let filename = getDocumentsDirectory().appendingPathComponent("copy.png")
                try! data.write(to: filename)
                self.imageURL = filename
                
            }
            
            
            
            
        }
        
        imagePicker?.dismiss(animated: true, completion: nil)
    }

    @IBAction func uploadButton(_ sender: AnyObject) {
        
        if actionButton.titleLabel?.text == "Select Photo" {
            present(imagePicker!, animated: true, completion: nil)
           return
        } else if titleField.text!.isEmpty {
            //error label
        } else {
            
            WebService.sharedService.uploadImage(named: titleField.text!,
                                                 WithURL: imageURL!,
                                                 Progress: { progress in
                                                    self.progressBarView.progress = Float(progress.fractionCompleted)}) { success in
                                                        //Successful image upload
                                                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "successfulUpload"), object: nil)
        }
        
        }
        
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
