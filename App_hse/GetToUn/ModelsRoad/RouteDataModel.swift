//
//  RouteDataModel.swift
//  App_hse
//
//  Created by Vladislava on 11/04/2019.
//  Copyright © 2019 VladislavaVakulenko. All rights reserved.
//

import Foundation
import UIKit

class RouteDataModel: NSObject {
    
    // Singleton Class
    static let sharedInstance = RouteDataModel()
    
    // Описание общежитий
    let dormitories = NSArray(contentsOfFile: Bundle.main.path(forResource: "Dormitories", ofType: "plist")!) as? [Dictionary<String, AnyObject>]
    // Описание кампусов
    let campuses = NSArray(contentsOfFile: Bundle.main.path(forResource: "Campuses", ofType: "plist")!) as? [Dictionary<String, AnyObject>]
    // Названия станций метро
    let subways = NSDictionary(contentsOfFile: Bundle.main.path(forResource: "Subways", ofType: "plist")!) as? Dictionary<String, AnyObject>
    // Описания станций ж/д
    let stations = NSDictionary(contentsOfFile: Bundle.main.path(forResource: "Stations", ofType: "plist")!) as? Dictionary<String, AnyObject>
    
    // Маршрут
    var route: [RouteStep] = [RouteStep()]
    
    override init() {
        super.init()
        
        // load array of campuses from resource
        //let dormitoriesPath = Bundle.main.path(forResource: "Dormitories", ofType: "plist")
        //let dormitories = NSArray(contentsOfFile: dormitoriesPath!)
        //print(dormitories?.count)
    }
    
    func calculateRouteByArrival(_ arrival: Date, direction: Int, campus: Dictionary<String, AnyObject>) {
        let dorm = dormitories![0] // общежитие
        
        route = [RouteStep]() // очистка маршрута
        
        let timestamp = arrival.dateByAddingMinute(-10)! // прибыть за 10 минут до нужного времени
        
        if direction == 0 {
            // из Дубков
            // Маршрут: Автобус->Переход->Электричка->Переход->Метро->Пешком
            
            // станции ж/д
            let stationFrom = stations![(dorm["station"] as? String)!] as! Dictionary<String, AnyObject>
            let stationTo = stations![(campus["station"] as? String)!] as! Dictionary<String, AnyObject>
            
            // станции метро
            let subwayFrom = stationTo["subway"] as? String
            let subwayTo = campus["subway"] as? String
            
            // пешком
            let onfoot = OnfootStep(arrival: timestamp, edu: campus)
            
            // на метро
            let subway = SubwayStep(arrival: onfoot.departure, from: subwayFrom!, to: subwayTo!)
            
            // переход Станция->Метро
            let t2From = stationTo["title"] as! String
            let t2To = subways![subwayFrom!] as! String
            let t2Duration = stationTo["transit"] as! Int
            let transit2 = TransitionStep(arrival: subway.departure, from: t2From, to: t2To, duration: t2Duration)
            
            // электричкой
            let train = TrainStep(arrival: transit2.departure, from: stationFrom, to: stationTo)
            
            // Коррекция времени отправления и прибытия в зависимости от расписания электрички
            transit2.departure = train.arrival
            transit2.arrival = transit2.departure.dateByAddingMinute(transit2.duration)!
            
            subway.departure = transit2.arrival
            subway.arrival = subway.departure.dateByAddingMinute(subway.duration)!
            
            onfoot.departure = subway.arrival
            onfoot.arrival = onfoot.departure.dateByAddingMinute(onfoot.duration)!
            
            // переход Автобус->Станция
            let t1From = NSLocalizedString("Bus", comment: "") // "Автобус"
            let t1To = NSLocalizedString("Station", comment: "") // "Станция"
            let t1Duration = stationFrom["transit"] as! Int
            let transit1 = TransitionStep(arrival: train.departure, from: t1From, to: t1To, duration: t1Duration)
            
            // автобусом
            //let bus = BusStep(arrival: transit1.departure, from: "Дубки", to: "Одинцово")
            
            // общая информация о пути
            let wayFrom = dorm["title"] as! String
            let wayTo = campus["title"] as! String
            let wayDeparture = transit1.departure.dateByAddingMinute(-10)! // 10 минут на сборы
            let wayArrival = onfoot.arrival
            let way = TotalStep(from: wayFrom, to: wayTo, departure: wayDeparture, arrival: wayArrival)
            
            // формирование информации о пути
            route.append(way)
            // route.append(bus)
            if transit1.duration > 0 {
                route.append(transit1)
            }
            route.append(train)
            if transit2.duration > 0 {
                route.append(transit2)
            }
            route.append(subway)
            route.append(onfoot)
            
        } else {
            // в Дубки
            // Маршрут: Пешком->Метро->Переход->Электричка->Переход->Автобус
            
            // станции ж/д
            let stationFrom = stations![(campus["station"] as? String)!] as! Dictionary<String, AnyObject>
            let stationTo = stations![(dorm["station"] as? String)!] as! Dictionary<String, AnyObject>
            
            // станции метро
            let subwayFrom = campus["subway"] as? String
            let subwayTo = stationFrom["subway"] as? String
            
            // автобусом
            let bus = BusStep(arrival: timestamp, from: "Одинцово", to: "Дубки")
            
            // переход Станция->Автобус
            let t2From = NSLocalizedString("Station", comment: "") // "Станция"
            let t2To = NSLocalizedString("Bus", comment: "") // "Автобус"
            let t2Duration = stationTo["transit"] as! Int
            let transit2 = TransitionStep(arrival: bus.departure, from: t2From, to: t2To, duration: t2Duration)
            
            //электричкой
            let train = TrainStep(arrival: transit2.departure, from: stationFrom, to: stationTo)
            
            // переход Метро->Станция
            let t1From = subways![subwayTo!] as! String
            let t1To = stationFrom["title"] as! String
            let t1Duration = stationFrom["transit"] as! Int
            let transit1 = TransitionStep(arrival: train.departure, from: t1From, to: t1To, duration: t1Duration)
            
            // на метро
            let subway = SubwayStep(arrival: transit1.departure, from: subwayFrom!, to: subwayTo!)
            
            // пешком
            let onfoot = OnfootStep(arrival: subway.departure, edu: campus)
            
            // TODO: можно попробовать подобрать автобус после прибытия электрички
            
            // общая информация о пути
            let wayFrom = campus["title"] as! String
            let wayTo = dorm["title"] as! String
            let wayDeparture = onfoot.departure.dateByAddingMinute(-10)! // 10 минут на сборы
            let wayArrival = bus.arrival
            let way = TotalStep(from: wayFrom, to: wayTo, departure: wayDeparture, arrival: wayArrival)
            
            // формирование информации о пути
            route.append(way)
            route.append(onfoot)
            route.append(subway)
            if transit1.duration > 0 {
                route.append(transit1)
            }
            route.append(train)
            if transit2.duration > 0 {
                route.append(transit2)
            }
            route.append(bus)
        }
    }
}
