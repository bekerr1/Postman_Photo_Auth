//
//  RQTabBarController.swift
//  iOSResearchPosition
//
//  Created by brendan kerr on 10/21/16.
//  Copyright © 2016 b3k3r. All rights reserved.
//

import UIKit

class RQTabBarController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(uploadComplete(_:)), name: NSNotification.Name(rawValue: "successfulUpload"), object: nil)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        //
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        //
    }
    
    func uploadComplete(_ noti: NSNotification) {
        selectedIndex = 0
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
