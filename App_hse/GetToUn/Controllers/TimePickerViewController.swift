//
//  TimePickerViewController.swift
//  App_hse
//
//  Created by Vladislava on 11/04/2019.
//  Copyright © 2019 VladislavaVakulenko. All rights reserved.
//

import UIKit

class TimePickerViewController: UIViewController {

    @IBOutlet weak var lessonView: UIView!
    @IBOutlet weak var datePicker: UIDatePicker!

    let lessonTimes = ["1":"09:00", "2":"10:30", "3":"12:10", "4":"13:40", "5":"15:10", "6":"16:40", "7":"18:10", "8":"19:40"]
    var arrivalTime: Date?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        datePicker.minimumDate = Date()
        datePicker.maximumDate = Date().dateByAddingDay(30) // +30 day

        if arrivalTime != nil {
            datePicker.date = arrivalTime!
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func lessonButtonPress(_ sender: UIButton) {

        let lessonTime = lessonTimes[(sender.titleLabel?.text)!]
        let date = datePicker.date.dateByWithTime(lessonTime!)!
        if date.compare(Date()) == .orderedDescending {
            datePicker.date = date
        } else {
            // next day
            datePicker.date = date.dateByAddingDay(1)!
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SaveSelectedTime" {
                arrivalTime = datePicker.date
        }
    }
}
