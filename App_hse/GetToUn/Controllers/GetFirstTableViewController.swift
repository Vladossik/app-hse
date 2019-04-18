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
 
    // variable of view controller
    // selected campus
    var campus: Dictionary<String, AnyObject>? {
        didSet {
            // after set value of when need set label text
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
            // after set value of when need set label text
            if arrivalTime != nil {
                whenLabel.text = arrivalTime!.string("dd MMM HH:mm")
            } else {
                whenLabel.text = NSLocalizedString("Now", comment: "")
            }
        }
    }
    
    let routeDataModel = RouteDataModel.sharedInstance
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
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        switch(segue.identifier) {
        case "RouteShow":
            if arrivalTime != nil {
            // по времени прибытия
            RouteDataModel.sharedInstance.calculateRouteByArrival(arrivalTime!, direction: directionSegmentControl.selectedSegmentIndex, campus: campus!)
            }
//        case "CampusPick":
//            if let campusPicker = segue.destination as? CampusPickerViewController {
//                campusPicker.selectedCampusIndex = (campus!["id"] as! Int) - 2
//            }
//        case "TimePick":
//            if let timePicker = segue.destination as? TimePickerViewController {
//                timePicker.arrivalTime = arrivalTime
//            }
        default : break
        }
    }

    // when press button done on campus picker view controller
    @IBAction func unwindWithSelectedCampus(_ segue:UIStoryboardSegue) {
        if let campusPicker = segue.source as? CampusPickerViewController,
            let campusIndex = campusPicker.selectedCampusIndex {
            campus = RouteDataModel.sharedInstance.campuses![campusIndex + 1]
        }
    }
    
    // when press button done on time picker view controller
    @IBAction func unwindSelectedTime(_ segue:UIStoryboardSegue) {
        if let timePicker = segue.source as? TimePickerViewController {
            //print(timePickerViewController.selectedDate)
//            departureTime = timePicker.departureTime
            arrivalTime = timePicker.arrivalTime
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
