//
//  SideTableTableViewController.swift
//  App_hse
//
//  Created by Vladislava on 12/03/2019.
//  Copyright © 2019 VladislavaVakulenko. All rights reserved.
//

import UIKit

class SideTableTableViewController: UITableViewController {
    
    @IBOutlet weak var avatarUser: UIImageView!
    @IBOutlet weak var name: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.clearsSelectionOnViewWillAppear = true
       
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 3 && indexPath.row == 0 {
            revealViewController()?.dismiss(animated: true)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
