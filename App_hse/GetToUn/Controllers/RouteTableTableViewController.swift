//
//  RouteTableTableViewController.swift
//  App_hse
//
//  Created by Vladislava on 13/04/2019.
//  Copyright © 2019 VladislavaVakulenko. All rights reserved.
//

import UIKit
import Foundation
import SafariServices

class TrainRouteStepTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
}

class RouteTableTableViewController: UITableViewController {
    
    let routeDataModel = RouteDataModel.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return routeDataModel.route.count
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let routeStep = routeDataModel.route[indexPath.row]
        if  let trainStep = routeStep as? TrainStep {
            if trainStep.url != nil {
//                UIApplication.shared.openURL(URL(string: trainStep.url!)!)
                guard
                    let url = URL(string: trainStep.url!)
                    else { return }
                
                if ["http", "https"].contains(url.scheme?.lowercased() ?? "") {
                    // Can open with SFSafariViewController
                    let safariViewController = SFSafariViewController(url: url)
                    self.present(safariViewController, animated: true, completion: nil)
                } else {
                    // Scheme is not supported or no scheme is given, use openURL
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let routeStep = routeDataModel.route[indexPath.row]
        if routeStep is TrainStep {
            return 120
        } else {
            return 66
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let routeStep = routeDataModel.route[indexPath.row]
        
        if routeStep is TrainStep {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TrainRouteCell", for: indexPath) as! TrainRouteStepTableViewCell
            
            
            cell.titleLabel?.text = routeStep.title
            cell.detailLabel?.text = routeStep.detail
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RouteCell", for: indexPath)
            
            cell.textLabel?.text = routeStep.title
            cell.detailTextLabel?.text = routeStep.detail
            if routeStep is TrainStep {
                cell.accessoryType = .detailButton
            } else {
                cell.accessoryType = .none
            }
            return cell
        }
    }
}
