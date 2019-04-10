//
//  ProfileViewController.swift
//  App_hse
//
//  Created by Vladislava on 18/03/2019.
//  Copyright © 2019 VladislavaVakulenko. All rights reserved.
//

import UIKit
import SwiftyVK

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var avatar: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Profile"
        
        sideMenu()
        
//        avatar.layer.cornerRadius = avatar.frame.size.width / 2
//        avatar.clipsToBounds = true
  
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        showUserPhoto()
//        self.avatar.layer.cornerRadius = self.avatar.frame.size.width / 2
//        self.avatar.clipsToBounds = true
    }
    
    // left side menu
    func sideMenu() {
        
        if revealViewController() != nil{
            menuButton.target = revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            revealViewController()?.rearViewRevealWidth = 275
            
            view.addGestureRecognizer((self.revealViewController()?.panGestureRecognizer())!)
        }
    }
    
    private func showUserPhoto() {
        let session = URLSession(configuration: .default)
        var dataTask: URLSessionDataTask?
        let token = UserDefaults.standard.string(forKey: defaultsKeys.token)!
        
        //UserDefaults.token)
        dataTask = session.dataTask(with: URL(string: "https://api.vk.com/method/users.get?fields=photo_200&v=5.92&access_token=" + token)!) { [weak self] data, r, error in
            guard let self = self else { return }
            
            if error == nil, let data = data {
                let response = try? JSONDecoder().decode(ProfileUser.self, from: data)
                guard let userData = response?.response[0] else { return }
                
                DispatchQueue.main.async {
                    self.avatar.kf.setImage(with: URL(string: userData.photo100))
                    self.avatar.layer.cornerRadius = self.avatar.frame.size.width / 2
                    self.avatar.clipsToBounds = true
                }
            }
        }
        
        dataTask?.resume()
    }
}
