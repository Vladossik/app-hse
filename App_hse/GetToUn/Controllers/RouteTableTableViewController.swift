//
//  RouteTableTableViewController.swift
//  App_hse
//
//  Created by Vladislava on 13/04/2019.
//  Copyright © 2019 VladislavaVakulenko. All rights reserved.
//

import UIKit
import Foundation


class TrainRouteStepTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
}

class RouteTableTableViewController: UITableViewController {
    
    // route data model
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
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let routeStep = routeDataModel.route[indexPath.row]
        if  let trainStep = routeStep as? TrainStep {
            if trainStep.url != nil {
                UIApplication.shared.openURL(URL(string: trainStep.url!)!)
            }
        }
//        if let onfootStep = routeStep as? OnfootStep {
//            if onfootStep.map != nil {
//                let cell = tableView.cellForRow(at: indexPath)
//                performSegue(withIdentifier: "RouteDetail", sender: cell)
//            }
//        }
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
            
            // Configure the cell...
            cell.titleLabel?.text = routeStep.title
            cell.detailLabel?.text = routeStep.detail
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RouteCell", for: indexPath)
            
            // Configure the cell...
            cell.textLabel?.text = routeStep.title
            cell.detailTextLabel?.text = routeStep.detail
            if routeStep is TrainStep {
//            if routeStep is TrainStep || routeStep is OnfootStep {
                cell.accessoryType = .detailButton
            } else {
                cell.accessoryType = .none
            }
            return cell
        }
    }
    
//    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        // Get the new view controller using segue.destinationViewController.
//        // Pass the selected object to the new view controller.
//        if segue.identifier == "RouteDetail" {
//            if let detailViewController = segue.destination as? DetailViewController {
//                if let cell = sender as? UITableViewCell {
//                    let indexPath = tableView.indexPath(for: cell)
////                    if let onfootStep = routeDataModel.route[indexPath!.row] as? OnfootStep {
////                        detailViewController.imageName = onfootStep.map
////                    }
//                }
//            }
//        }
//    }
}
