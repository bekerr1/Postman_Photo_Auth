//
//  RQView.swift
//  iOSResearchPosition
//
//  Created by brendan kerr on 10/19/16.
//  Copyright © 2016 b3k3r. All rights reserved.
//

import UIKit

protocol ViewCallback {
    
    func completedFormsWith(user current: User)
}

struct User {
    var email: String
    var password: String
    
    
}

class RQView: UIView, UITextFieldDelegate {

    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    var currentUser: User = {
        var user = User(email: "", password: "")
        return user
    }()
    
    var callback: ViewCallback?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    
    @IBAction func loginPressed(_ sender: AnyObject) {
        /*
        if (passwordField.text?.isEmpty)! || (emailField.text?.isEmpty)! {
            print("Need email and/or password")
            return
        }
         */
        guard let name = emailField.text else {
            print("Need email")
            return
        }
        guard let password = passwordField.text else {
            print("Need password")
            return
        }
        
        currentUser.email = name
        currentUser.password = password
        
        callback?.completedFormsWith(user: currentUser)
        
    }
    
}










/*
 
 // Only override draw() if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 override func draw(_ rect: CGRect) {
 // Drawing code
 }
 */


/*
func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    
    switch textField.tag {
    case 0:
        if let validName = textField.text {
            currentUser.email = validName
            return true
        }
        
    case 1:
        if let validPassword = textField.text {
            currentUser.password = validPassword
            return true
        }
        
    default:
        print("No valid tag")
        
    }
    
    return true
    
}
 
 
*/
