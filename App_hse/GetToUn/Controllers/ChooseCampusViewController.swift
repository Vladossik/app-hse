//
//  CampusPickerViewController.swift
//  App_hse
//
//  Created by Vladislava on 11/04/2019.
//  Copyright © 2019 VladislavaVakulenko. All rights reserved.
//

import UIKit

class ChooseCampusViewController: UITableViewController {

    let campuses = RoadModel.sharedInstance.campuses
    
    var selectedCampusIndex: Int!

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SaveSelectedCampus" {
            if let cell = sender as? UITableViewCell {
                let indexPath = tableView.indexPath(for: cell)
                selectedCampusIndex = indexPath?.row
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let index = selectedCampusIndex {
            let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0))
            cell?.accessoryType = .none
        }
        
        selectedCampusIndex = indexPath.row
        
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = .checkmark
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return campuses!.count - 1;
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CampusCell", for: indexPath)
        
        let campus = campuses![indexPath.row + 1]
        
        cell.textLabel?.text = campus["title"] as? String
        cell.detailTextLabel?.text = campus["description"] as? String
        if indexPath.row == selectedCampusIndex {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
