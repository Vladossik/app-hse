//
//  Date.swift
//  App_hse
//
//  Created by Vladislava on 12/04/2019.
//  Copyright © 2019 VladislavaVakulenko. All rights reserved.
//

import Foundation

extension String {

    func date(_ dateFormat: String = "yyyy-MM-dd HH:mm:ss") -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.date(from: self)
    }
}

extension Date {
    
    func string(_ dateFormat: String = "yyyy-MM-dd HH:mm:ss") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.string(from: self)
    }
    
    func dateByAddingMinute(_ minute: Int) -> Date? {
        let calendar = Calendar.current
        if #available(iOS 8.0, *) {
            return calendar.date(byAdding: .minute, value: minute, to: self)
        } else {
            // Fallback on earlier versions
            var components = DateComponents()
            components.minute = minute
            return calendar.date(byAdding: components, to: self)
        }
    }
    
    func dateByAddingDay(_ day: Int) -> Date? {
        //let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let calendar = Calendar.current
        if #available(iOS 8.0, *) {
            return calendar.date(byAdding: .day, value: day, to: self)
        } else {
            // Fallback on earlier versions
            var components = DateComponents()
            components.day = day
            return calendar.date(byAdding: components, to: self)
        }
    }
    
    var weekday: Int {
        get {
            //let myCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
            let calendar = Calendar.current
            return calendar.component(.weekday, from: self)
            //            let components = (calendar as NSCalendar).components(NSCalendar.Unit.weekday, from: self)
            //            return components.weekday!
        }
    }
    
    func weekdayName() -> String {
        return string("EEE")
        //let weekdayName = ["воскресенье", "понедельник", "вторник", "среда", "четверг", "пятница", "суббота"]
        //return weekdayName[weekday - 1]
    }
    
    func dateByWithTime(_ time: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd "
        
        let dateString = dateFormatter.string(from: self) + time
        
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        return dateFormatter.date(from: dateString)
    }
    
}
