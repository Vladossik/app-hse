//
//  GetFirstTableViewController.swift
//  App_hse
//
//  Created by Vladislava on 11/04/2019.
//  Copyright © 2019 VladislavaVakulenko. All rights reserved.
//

import UIKit
import CoreLocation

class GetFirstTableViewController: UITableViewController {

    @IBOutlet weak var directionSegmentControl: UISegmentedControl!
    @IBOutlet weak var campusLabel: UILabel!
    @IBOutlet weak var whenLabel: UILabel!
 
    // selected campus
    var campus: Dictionary<String, AnyObject>? {
        didSet {
            if campusLabel != nil {
                if campus != nil {
                    campusLabel.text = campus!["title"] as? String
                } else {
                    campusLabel.text = ""
                }
            }
        }
    }

    // selected arrival time
    var arrivalTime: Date? {
        didSet {
            if arrivalTime != nil {
                whenLabel.text = arrivalTime!.string("dd MMM HH:mm")
            } else {
                whenLabel.text = NSLocalizedString("Now", comment: "")
            }
        }
    }
    
   // let roadModel = RoadModel.sharedInstance
    let userDefaults = UserDefaults.standard
    
    // when direction segment change value
    @IBAction func directionValueChanged(_ sender: AnyObject) {
        tableView.reloadData()
    }
    
    // before view on screen for update fortune quote
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "RouteShow"{
            if arrivalTime != nil {
            // по времени прибытия
            RoadModel.sharedInstance
                .calculateRouteByArrival(arrivalTime!, direction: directionSegmentControl.selectedSegmentIndex, campus: campus!)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // when press button done on campus picker view controller
    @IBAction func unwindWithSelectedCampus(_ segue:UIStoryboardSegue) {
        if let campusPicker = segue.source as? ChooseCampusViewController,
            let campusIndex = campusPicker.selectedCampusIndex {
            campus = RoadModel.sharedInstance.campuses![campusIndex + 1]
        }
    }
    
    // when press button done on time picker view controller
    @IBAction func unwindSelectedTime(_ segue:UIStoryboardSegue) {
        if let timePicker = segue.source as? ChooseTimeViewController {
            arrivalTime = timePicker.arrivalTime
        }
    }
    
}
