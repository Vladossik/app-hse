//
//  ScheduleService.swift
//  App_hse
//
//  Created by Vladislava on 13/04/2019.
//  Copyright © 2019 VladislavaVakulenko. All rights reserved.
//

import Foundation
import SwiftyJSON

class ScheduleService: NSObject {
    
    // Singleton Class
    static let sharedInstance = ScheduleService()
    
    // API Keys
    let apikeys = "f6c89396-fac1-401a-9bd5-fa5b36eca4a3"
//    let apikeys = NSDictionary(contentsOfFile: Bundle.main.path(forResource: "apikeys", ofType: "plist")!) as? Dictionary<String, String>
    
    // Standart User Default Settings
    let userDefaults = UserDefaults.standard
    
    let BUS_SCHEDULE_FILE = "bus.json"
    let TRAIN_SCHEDULE_FILE = "train.json"
    
    var busFileURL: URL   // путь к файлу bus.json
    var trainFileURL: URL // путь к файлу train.json
    
    var busSchedule: JSON?
    var trainSchedule: JSON?
    var lastUpdate: Date? {
        get {
            userDefaults.synchronize()
            return userDefaults.object(forKey: "last_update") as? Date
        }
        set {
            userDefaults.set(newValue, forKey: "last_update")
            userDefaults.synchronize()
        }
    }
    
    // конструктор
    override init() {
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first! as URL
        busFileURL = documentsUrl.appendingPathComponent(BUS_SCHEDULE_FILE)
        trainFileURL = documentsUrl.appendingPathComponent(TRAIN_SCHEDULE_FILE)
        
        super.init()
        
        //let fileManager = NSFileManager.defaultManager()
        //if fileManager.fileExistsAtPath(filePath) {
        
        // загрузка расписания из файла bus.json
        if let busData = try? Data(contentsOf: busFileURL) {
            busSchedule = try! JSON(data: busData)
        }
        // загрузка расписания из файла train.json
        if let trainData = try? Data(contentsOf: trainFileURL) {
            trainSchedule = try! JSON(data: trainData)
        }
        
        cacheSchedules()
    }
    
    // Кэширование расписания автобуса и электрички на сегодня
    func cacheSchedules() {
        if lastUpdate != nil && lastUpdate!.string("yyyyMMdd") == Date().string("yyyyMMdd") {
            if busSchedule != nil && trainSchedule != nil {
                return
            }
        }
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        cacheTrainSchedule()
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        if busSchedule != nil && trainSchedule != nil {
            // update schedule successfull
            lastUpdate = Date()
        }
    }
    
    /*
     Caches a schedule between all stations
     */
    func cacheTrainSchedule() {
        trainSchedule = JSON([String: JSON]())
        let date = Date().string("yyyy-MM-dd")
        let from = "c10743" //"Одинцово" = "s9600721"
        let toStations = ["s9601728", "s9600821", "s9601666", "s2000006"] //["Кунцево", "Фили", "Беговая", "Белорусская"]
        for to in toStations {
            if let fromTo = loadScheduleTrain(from, to: to, date: date) {
                let key = "\(from):\(to):\(date)"
                trainSchedule![key] = fromTo
            }
            if let toFrom = loadScheduleTrain(to, to: from, date: date) {
                let key = "\(to):\(from):\(date)"
                trainSchedule![key] = toFrom
            }
        }
        // сохранить в файл train.json
        if let trainData = trainSchedule!.rawString()?.data(using: String.Encoding.utf8) {
            try? trainData.write(to: trainFileURL, options: [.atomic])
        }
    }
    
    // MARK: - Train Schedule
    
    /*
     Caches a schedule between stations from arguments starting with certain day
     Writes the cached schedule for day and two days later to train_cached_* files
     
     Args:
     from(String): departure train station
     to(String): arrival train station
     timestamp(Date): date to cache schedule for
     */
    func loadScheduleTrain(_ from: String, to: String, date: String) -> JSON? {
//        let YANDEX_API_KEY = apikeys!["rasp.yandex.ru"]
        let YANDEX_API_KEY = apikeys
        // URL of train schedule API provider
        let TRAIN_API_URL = "https://api.rasp.yandex.net/v1.0/search/?apikey=%@&format=json&date=%@&from=%@&to=%@&lang=ru&transport_types=suburban"
        
        let api_url = String(format: TRAIN_API_URL, YANDEX_API_KEY, date, from, to)
        print(api_url)
        
        // загрузка распияния из интернета
        if let trainSchedule = try? Data(contentsOf: URL(string: api_url)!) {
            let schedule = try! JSON(data: trainSchedule)
            
            var trains = [Dictionary<String, AnyObject>]()
            for item in (schedule["threads"].array)! {
                var train = Dictionary<String, AnyObject>()
                train["arrival"] = item["arrival"].string as AnyObject?
                train["departure"] = item["departure"].string as AnyObject?
                train["duration"] = item["duration"].int as AnyObject?
                train["stops"] = item["stops"].string as AnyObject?
                train["title"] = item["thread"]["title"].string as AnyObject?
                train["number"] = item["thread"]["number"].string as AnyObject?
                trains.append(train)
            }
            return JSON(trains)
        }
        return nil
    }
    
    /*
     Returns a cached schedule between stations in arguments
     If no cached schedule is available, download and return a fresh one
     
     Args:
     from(String): departure train station
     to(String): arrival train station
     timestamp(Date): date to get schedule for
     */
    func getScheduleTrain(_ from: String, to: String, timestamp: Date) -> JSON? {
        cacheSchedules()
        if trainSchedule == nil {
            return nil
        }
        
        let date = timestamp.string("yyyy-MM-dd")
        let key = "\(from):\(to):\(date)"
        if trainSchedule![key].exists() {
            return trainSchedule![key]
        }
        if let schedule = loadScheduleTrain(from, to: to, date: date) {
            trainSchedule![key] = schedule
            return schedule
        }
        return nil
    }

}
