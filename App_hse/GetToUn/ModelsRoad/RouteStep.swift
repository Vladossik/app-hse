//
//  RouteStep.swift
//  App_hse
//
//  Created by Vladislava on 11/04/2019.
//  Copyright © 2019 VladislavaVakulenko. All rights reserved.
//

import Foundation
import SwiftyJSON
import UIKit

class RouteStep {

    var from: String?
    var to: String?
    var departure: Date
    var arrival: Date
    var duration: Int

    var title: String? {
        get {
            return NSLocalizedString("NoneParameter", comment: "")
        }
    }
    
    var detail: String? {
        get {
            return ""
        }
    }

    init() {
        departure = Date()
        arrival = Date()
        duration = 0
    }
}


class TotalStep: RouteStep {

    override var title: String {
        get {
            return String (format: "%@ to %@", from ?? "?", to ?? "?")
        }
    }
    override var detail: String {
        get {
            //let timeDeparture = departure.string("HH:mm") ?? "?"
            let dateDeparture = departure.string("dd MMM HH:mm")
            let timeArrival = arrival.string("HH:mm")
            //let dateArrival = arrival.string("dd MMM HH:mm")
            let detailFormat = NSLocalizedString("TotalDetailFormat", comment: "")
            return String(format: detailFormat, duration, dateDeparture, timeArrival)
        }
    }

    init(from: String, to: String) {
        super.init()
        self.from = from
        self.to = to
    }

    init(departure: Date, arrival: Date) {
        super.init()
        setTime(departure, arrival: arrival)
    }

    init(from: String, to: String, departure: Date, arrival: Date) {
        super.init()
        self.from = from
        self.to = to
        setTime(departure, arrival: arrival)
    }

    func setTime(_ departure: Date, arrival: Date) {
        self.departure = departure
        self.arrival = arrival
        self.duration = Int(arrival.timeIntervalSince(departure) / 60.0 + 0.5)
    }
}

class TrainStep: RouteStep {

    var trainName: String?
    var stops: String?
    var url: String?
    
    override var title: String {
        get {
            return NSLocalizedString("Suburban electric train", comment: "")
        }
    }
    override var detail: String {
        get {
            let timeDeparture = departure.string("HH:mm")
            let timeArrival = arrival.string("HH:mm")
            let detailFormat = NSLocalizedString("TrainDetailFormat", comment: "")
            return String(format: detailFormat, trainName ?? "?", timeDeparture, timeArrival, stops ?? "везде", to ?? "?")
        }
    }

    init(departure: Date, from: Dictionary<String, AnyObject>, to: Dictionary<String, AnyObject>) {
        super.init()
        setNearestTrainByDeparture(departure, from: from, to: to)
    }

    init(arrival: Date, from: Dictionary<String, AnyObject>, to: Dictionary<String, AnyObject>) {
        super.init()
        setNearestTrainByArrival(arrival, from: from, to: to)
    }

    //let RASP_YANDEX_URL = "https://rasp.yandex.ru/"
    let RASP_YANDEX_URL = "https://rasp.yandex.ru/search/?when=%@&fromId=%@&toId=%@"

    let scheduleService = ScheduleService.sharedInstance

    /*
     Returns the nearest train by departure time

     Args:
     from(Dictionary): place of departure
     to(Dictionary): place of arrival
     departure(Date): time of departure

     Note:
     'from' and 'to' should not be equal and should be in STATIONS
     */
    func setNearestTrainByDeparture(_ departure: Date, from: Dictionary<String, AnyObject>, to: Dictionary<String, AnyObject>) {
        //assert _from in STATIONS
        //assert _to in STATIONS

        let fromCode = from["code"] as! String
        let toCode = to["code"] as! String

        // получить расписание электричек
        let trains = scheduleService.getScheduleTrain(fromCode, to: toCode, timestamp: departure)

        if trains == nil || trains!.isEmpty {
            print("Не получилось загрузить расписание электричек")
            return
        }

        // поиск ближайшего рейса (минимум ожидания)
        var minInterval: Double = 24*60*60 // мин. интервал (сутки)
        var trainInfo: JSON? // найденая информация о поезде
        for train in trains!.array! {
            let departureTime = train["departure"].string!.date()
            let interval: Double = departureTime!.timeIntervalSince(departure)
            if interval > 0 && interval < minInterval {
                minInterval = interval
                trainInfo = train
            }
        }

        if trainInfo == nil {
            //print("Ближайшая электричка не найдена")
            // get nearest train on next day
            let newDeparture = departure.dateByAddingDay(1)!.dateByWithTime("00:00")!
            setNearestTrainByDeparture(newDeparture, from: from, to: to)
            return
        }

        self.from = from["title"] as? String
        self.to = to["title"] as? String
        self.trainName = trainInfo!["title"].string //"Кубинка 1 - Москва (Белорусский вокзал)"
        self.stops = trainInfo!["stops"].string //"везде"
        self.departure = trainInfo!["departure"].string!.date()! as Date
        self.arrival = trainInfo!["arrival"].string!.date()! as Date
        self.duration = Int(self.arrival.timeIntervalSince(self.departure) / 60.0 + 0.5)
        //self.duration = trainInfo!["duration"].int! / 60
        self.url = String(format: RASP_YANDEX_URL, self.departure.string("yyyy-MM-dd"), fromCode, toCode)
    }

    /*
     Returns the nearest train by arrival time

     Args:
     from(Dictionary): place of departure
     to(Dictionary): place of arrival
     arrival(Date): time of arrival

     Note:
     'from' and 'to' should not be equal and should be in STATIONS
     */
    func setNearestTrainByArrival(_ arrival: Date, from: Dictionary<String, AnyObject>, to: Dictionary<String, AnyObject>) {
        //assert _from in STATIONS
        //assert _to in STATIONS

        let fromCode = from["code"] as! String
        let toCode = to["code"] as! String

        // получить расписание электричек
        let trains = scheduleService.getScheduleTrain(fromCode, to: toCode, timestamp: arrival)

        if trains == nil || trains!.count == 0 {
            print("Не получилось загрузить расписание электричек")
            return
        }

        // поиск ближайшего рейса (минимум ожидания)
        var minInterval: Double = 24*60*60 // мин. интервал (сутки)
        var trainInfo: JSON? // найденая информация о поезде
        for train in trains!.array! {
            let arrivalTime = train["arrival"].string!.date()!
            let interval: Double = arrival.timeIntervalSince(arrivalTime)
            if interval > 0 && interval < minInterval {
                minInterval = interval
                trainInfo = train
            }
        }

        if trainInfo == nil {
            //print("Ближайшая электричка не найдена")
            // get nearest train on next day
            let newArrival = arrival.dateByAddingDay(-1)!.dateByWithTime("23:59")!
            setNearestTrainByArrival(newArrival, from: from, to: to)
            return
        }

        self.from = from["title"] as? String
        self.to = to["title"] as? String
        self.trainName = trainInfo!["title"].string //"Кубинка 1 - Москва (Белорусский вокзал)"
        self.stops = trainInfo!["stops"].string //"везде"
        self.departure = trainInfo!["departure"].string!.date()! as Date
        self.arrival = trainInfo!["arrival"].string!.date()! as Date
        self.duration = Int(self.arrival.timeIntervalSince(self.departure) / 60.0 + 0.5)
        //self.duration = trainInfo!["duration"].int! / 60
        self.url = String(format: RASP_YANDEX_URL, self.arrival.string("yyyy-MM-dd"), fromCode, toCode)
    }
}

// MARK: - Route On Subway

class SubwayStep: RouteStep {

    override var title: String {
        get {
            return NSLocalizedString("Subway", comment: "") // "Метро"
        }
    }
    override var detail: String {
        get {
            let timeDeparture = departure.string("HH:mm")
            let timeArrival = arrival.string("HH:mm")
            return String(format: "%@ (%@) → %@ (%@)", from ?? "?", timeDeparture, to ?? "?", timeArrival)
        }
    }

    init(departure: Date, from: String, to: String) {
        super.init()
        setNearestSubwayByDeparture(departure, from: from, to: to)
    }

    init(arrival: Date, from: String, to: String) {
        super.init()
        setNearestSubwayByArrival(arrival, from: from, to: to)
    }

    // Subway Route Data (timedelta in minutes)
    let subwayDuration = [
        "kuntsevskaya": [ // Кунцевская
            "strogino":           16, // Строгино
            "semyonovskaya":      28, // Семёновская
            "kurskaya":           21, // Курская
            "leninsky_prospekt" : 28  // Ленинский проспект
        ],
        "belorusskaya": [ // Белорусская
            "aeroport":  6, // Аэропорт
            "tverskaya": 4  // Тверская
        ],
        "begovaya": [ // Беговая
            "tekstilshchiki": 23, // Текстильщики
            "lubyanka":       12, // Лубянка
            "shabolovskaya":  20, // Шаболовская
            "kuznetsky_most":  9, // Кузнецкий мост
            "paveletskaya":   17, // Павелецкая
            "kitay-gorod":    11  // Китай-город
        ],
        "slavyansky_bulvar": [ // Славянский бульвар
            "strogino":          18, // Строгино
            "semyonovskaya":     25, // Семёновская
            "kurskaya":          18, // Курская
            "leninsky_prospekt": 25, // Ленинский проспект
            "aeroport":          26, // Аэропорт
            "tverskaya":         22, // Тверская
            "tekstilshchiki":    35, // Текстильщики
            "lubyanka":          21, // Лубянка
            "shabolovskaya":     22, // Шаболовская
            "kuznetsky_most":    22, // Кузнецкий мост
            "paveletskaya":      17, // Павелецкая
            "kitay-gorod":       20  // Китай-город
        ]
    ]
    // время работы метро
    let subwayClosesTime = "01:00"
    let subwayOpensTime = "05:50"
    // название станций метро
    let subways = RouteDataModel.sharedInstance.subways

    /**
     Returns the time required to get from one subway station to another

     Args:
     from(String): Russian name of station of departure
     to(String): Russian name of station of arrival

     Note:
     'from' and 'to' must exist in SUBWAY_DATA.keys or any of SUBWAY_DATA[key].values
     */
    func getSubwayDuration(_ from: String, to: String) -> Int {
        if let fromStation = subwayDuration[from] {
            if let result = fromStation[to] {
                return result
            }
        }
        if let toStation = subwayDuration[to] {
            if let result = toStation[from] {
                return result
            }
        }
        print("not fround subway data from: \(from) to: \(to)")
        return 0
    }

    /**
     Returns the nearest subway route by departure time

     Args:
     from(String): Russian name of station of departure
     to(String): Russian name of station of arrival
     departure(Date): time of departure

     Note:
     'from' and 'to' must exist in SUBWAY_DATA.keys or any of SUBWAY_DATA[key].values
     */
    func setNearestSubwayByDeparture(_ departure: Date, from: String, to: String) {
        self.from = subways![from] as? String
        self.to = subways![to] as? String
        self.duration = getSubwayDuration(from, to: to)

        // проверка на время работы метро
        let subwayCloses = departure.dateByWithTime(subwayClosesTime)
        let subwayOpens = departure.dateByWithTime(subwayOpensTime)
        // subwayCloses <= timestamp <= subwayOpens
        if subwayCloses!.compare(departure) != .orderedDescending
            && departure.compare(subwayOpens!) != .orderedDescending {
            // subway is still closed
            self.departure = subwayOpens!
        } else {
            self.departure = departure
        }
        self.arrival = self.departure.dateByAddingMinute(duration)!
    }

    /**
     Returns the nearest subway route by arrival time

     Args:
     from(String): Russian name of station of departure
     to(String): Russian name of station of arrival
     arrival(Date): time of arrival

     Note:
     'from' and 'to' must exist in SUBWAY_DATA.keys or any of SUBWAY_DATA[key].values
     */
    func setNearestSubwayByArrival(_ arrival: Date, from: String, to: String) {
        self.from = subways![from] as? String
        self.to = subways![to] as? String
        self.duration = getSubwayDuration(from, to: to)

        // проверка на время работы метро
        let subwayCloses = arrival.dateByWithTime(subwayClosesTime)
        let subwayOpens = arrival.dateByWithTime(subwayOpensTime)
        // subwayCloses <= timestamp <= subwayOpens
        if subwayCloses!.compare(arrival) != .orderedDescending
            && arrival.compare(subwayOpens!) != .orderedDescending {
            // subway is still closed
            self.departure = subwayOpens!
            self.arrival = subwayOpens!.dateByAddingMinute(duration)!
        } else {
            self.departure = arrival.dateByAddingMinute(-duration)!
            self.arrival = arrival
        }
        self.arrival = self.departure.dateByAddingMinute(duration)!
    }

}

// MARK: - Route On Foot

class OnfootStep: RouteStep {

    //var map: String? // имя файла карты для показа делелей шага маршрута

    override var title: String {
        get {
            return NSLocalizedString("OnFoot", comment: "") // "Пешком"
        }
    }
    override var detail: String {
        get {
            let detailFormat = NSLocalizedString("OnfootDetailFormat", comment: "")
            return String(format: detailFormat, duration)
        }
    }

    init(departure: Date, edu: Dictionary<String, AnyObject>) {
        super.init()
        setNearestOnFootByDeparture(departure, edu: edu)
    }

    init (arrival: Date, edu: Dictionary<String, AnyObject>) {
        super.init()
        setNearestOnFootByArrival(arrival, edu: edu)
    }
    
    /**
     Returns a map url for displaying in a webpage

     Args:
     edu(Dictionary): which education campus the route's destination is
     urlType(Optional[String]): whether the map should be interactive

     Note:
     'edu' should be a value from EDUS
     'urlType' should be in {'static', 'js'}
     */
//    func formMapUrl(_ edu: Dictionary<String, AnyObject>, urlType: String = "static") -> String? {
//        let mapSource = edu["mapsrc"] as! String
//        return String(format: "https://api-maps.yandex.ru/services/constructor/1.0/%@/?sid=%@", urlType, mapSource)
//    }

    /**
     Returns the nearest onfoot route by departure time

     Args:
     edu(Dictionary): place of arrival
     departure(Date): time of departure from subway exit

     Note:
     'edu' should be a value from EDUS
     */
    func setNearestOnFootByDeparture(_ departure: Date, edu: Dictionary<String, AnyObject>) {
        self.duration = edu["onfoot"] as! Int
        self.departure = departure
        self.arrival = departure.dateByAddingMinute(duration)!
        //self.map = formMapUrl(edu["mapsrc"] as! String)
//        self.map = (edu["name"] as! String) + ".png"
    }

    /**
     Returns the nearest onfoot route by arrival time

     Args:
     edu(Dictionary): place of arrival
     arrival(Date): time of arrival from campus exit

     Note:
     'edu' should be a value from EDUS
     */
    func setNearestOnFootByArrival(_ arrival: Date, edu: Dictionary<String, AnyObject>) {
        self.duration = edu["onfoot"] as! Int
        self.departure = arrival.dateByAddingMinute(-duration)!
        self.arrival = arrival
        //onfoot.map = formMapUrl(edu["mapsrc"] as! String)
//        self.map = (edu["name"] as! String) + ".png"
    }
}

// MARK: - Route Transition

class TransitionStep: RouteStep {

    override var title: String {
        get {
            return NSLocalizedString("Transition", comment: "") // " Переход"
        }
    }
    override var detail: String {
        get {
            let detailFormat = NSLocalizedString("TransitDetailFormat", comment: "")
            return String(format: detailFormat, from ?? "?", to ?? "?", duration)
        }
    }

    init(departure: Date, from: String, to: String, duration: Int) {
        super.init()
        self.from = from
        self.to = to
        self.duration = duration
        self.departure = departure
        self.arrival = departure.dateByAddingMinute(duration)!
    }

    init(arrival: Date, from: String, to: String, duration: Int) {
        super.init()
        self.from = from
        self.to = to
        self.duration = duration
        self.departure = arrival.dateByAddingMinute(-duration)!
        self.arrival = arrival
        
    }
}
