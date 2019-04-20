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
            let numberPhone = sender.titleLabel?.text,
            let url = URL(string: "telprompt://\(numberPhone)")
        else { return }
        
        UIApplication.shared.open(url)
    }
}
