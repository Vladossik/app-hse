//
//  ViewController.swift
//  App_hse
//
//  Created by Vladislava on 16/01/2019.
//  Copyright © 2019 VladislavaVakulenko. All rights reserved.
//

import UIKit
import SwiftyVK

class LoginViewController: UIViewController {

    @IBOutlet weak var roundedRectangle: UIView!
    @IBOutlet weak var appTitle: UITextField!
    @IBOutlet weak var firstLabel: UILabel!
    @IBOutlet weak var secondLabel: UILabel!
    
    @IBOutlet weak var buttonLogIn: UIButton!
    
    @IBAction func btnClickVK(_ sender: Any) {
        
//        VK.sessions.default.logOut()
        
        //APIWorker.logout()
        VK.sessions.default.logIn (
            onSuccess: { info in UIApplication.shared.keyWindow!.rootViewController!.present(self.storyboard?.instantiateViewController(withIdentifier: "SWRevealViewController") as! SWRevealViewController, animated: true)
        },
            onError: { _ in /*error in let alert = UIAlertController(title: "Error occured", message: error.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                                self.present(alert, animated: true, completion: nil)*/
                DispatchQueue.main.async {
                    UIApplication.shared.keyWindow!.rootViewController!.present(self.storyboard?.instantiateViewController(withIdentifier: "SWRevealViewController") as! SWRevealViewController, animated: true)
                }
        })
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //rounded border for view
        roundedRectangle.layer.cornerRadius = 50
        
        //title - HSE Dorm - text color
        appTitle.textColor = Colors.peacockBlue
        
        //gradient color for button Login
        buttonLogIn.setGradientBackground(colorOne: Colors.waterBlue66, colorTwo: Colors.niceBlue86)
    }
    
}

