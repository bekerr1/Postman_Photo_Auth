//
//  ViewController.swift
//  iOSResearchPosition
//
//  Created by brendan kerr on 10/19/16.
//  Copyright © 2016 b3k3r. All rights reserved.
//

import UIKit

class ViewController: UIViewController, ViewCallback {
    
    
    @IBOutlet weak var loginButtonBLGC: NSLayoutConstraint!
    @IBOutlet var rootView: RQView!
    //var service: WebService?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        rootView.callback = self
        loginButtonBLGC.constant = 700
        view.layoutIfNeeded()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loginButtonBLGC.constant = 332
        
        UIView.animate(withDuration: 1.0, delay: 0.0, options: [UIViewAnimationOptions.curveEaseOut], animations: {
            self.view.layoutIfNeeded()
            }, completion: nil)
    }
    
    
    func completedFormsWith(user current: User) {

        WebService.sharedService.loadToken(withUser: current) { sucess in
            if sucess {
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "showTabBarSegue", sender: nil)
                }
                
            }
        }
    }
        
    /*
        service?.loadToken(withUser: current) { sucess in
            if sucess {
                 self.performSegue(withIdentifier: "showCollectionSegue", sender: nil)
            }
        }
 */

    
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showTabBarSegue" {
            //let future = segue.destination as? RQCollectionViewController
            //future?.service = self.service
        }
    }
    


}










