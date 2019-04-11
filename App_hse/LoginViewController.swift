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
        authorize(success: { info in
            DispatchQueue.main.async { UIApplication.shared.keyWindow!.rootViewController!.present(self.storyboard?.instantiateViewController(withIdentifier: "SWRevealViewController") as! SWRevealViewController, animated: true)
                }
            },
                  onError: {error in
                    let alert = UIAlertController(title: "Error occured", message: error.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
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
    
    override func viewDidAppear(_ animated: Bool) {
        let defaults = UserDefaults.standard
        
        guard
            defaults.string(forKey: DefaultsKeys.accessToken) != nil,
            defaults.string(forKey: DefaultsKeys.userId) != nil
        else { return }
        
        let storyboardID = "SWRevealViewController"
        
        guard
            let rootViewController = UIApplication.shared.keyWindow?.rootViewController,
            let storyboard = storyboard,
            let revealViewController = storyboard.instantiateViewController(withIdentifier:
                storyboardID) as? SWRevealViewController
        else { return }
        
        rootViewController.present(revealViewController, animated: false)
    }
}

