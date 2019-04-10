//
//  SideTableTableViewController.swift
//  App_hse
//
//  Created by Vladislava on 12/03/2019.
//  Copyright © 2019 VladislavaVakulenko. All rights reserved.
//

import UIKit
import SwiftyVK

class SideTableTableViewController: UITableViewController {
    
    @IBOutlet weak var avatarUser: UIImageView!
    @IBOutlet weak var name: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.clearsSelectionOnViewWillAppear = true
        showUserInfo()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 3 && indexPath.row == 0 {
            revealViewController()?.dismiss(animated: true)
            
            //logOut
            VK.sessions.default.logOut()
            print("SwiftyVK: LogOut")
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    private func showUserInfo() {
        
        let session = URLSession(configuration: .default)
        var dataTask: URLSessionDataTask?
        let token = UserDefaults.standard.string(forKey: defaultsKeys.token)!
        
        dataTask = session.dataTask(with: URL(string: "https://api.vk.com/method/users.get?fields=photo_200&v=5.92&access_token=" + token)!) { [weak self] data, r, error in
            guard let self = self else { return }
            
            if error == nil, let data = data {
                let response = try? JSONDecoder().decode(ProfileUser.self, from: data)
                guard let userData = response?.response[0] else { return }
                
                DispatchQueue.main.async {
                    
                    self.avatarUser.kf.setImage(with: URL(string: userData.photo100))
                    self.avatarUser.layer.cornerRadius = self.avatarUser.frame.size.width / 2
                    self.avatarUser.clipsToBounds = true
                    self.name.text = "\(userData.firstName) \(userData.lastName)"

                    self.tableView.reloadData()
                }
            }
        }
        
        dataTask?.resume()
    }
    
}
