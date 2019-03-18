//
//  CleaningViewController.swift
//  App_hse
//
//  Created by Vladislava on 16/03/2019.
//  Copyright © 2019 VladislavaVakulenko. All rights reserved.
//

import UIKit

class CleaningViewController: UITableViewController {

    @IBAction func phoneCall(_ sender: UIButton) {
        guard
            let numberPhone = sender.titleLabel?.text, let url = URL(string: "telprompt://\(numberPhone)")
        else { return }
        
        UIApplication.shared.open(url)
    }
//    override func viewDidLoad() {
//        super.viewDidLoad()
//    }
//    override func numberOfSections(in tableView: UITableView) -> Int {
//        return 0
//    }
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete implementation, return the number of rows
//        return 0
//    }
//
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
//        tableView.deselectRow(at: indexPath, animated: true)
//    }
}
