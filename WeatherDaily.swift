//
//  WeatherDaily.swift
//  NewWeatherForecast
//
//  Created by Ma Duy Loc on 20/09/2018.
//  Copyright © 2018 Alice Ma. All rights reserved.
//


//
//  WeatherDaily.swift
//  WeatherForecast
//
//  Created by Bui Quoc Anh on 9/15/18.
//  Copyright © 2018 Bui Quoc Anh. All rights reserved.
//
import Foundation
import Foundation

class WeatherDaily{
    let time: Int
    let summary: String
    let icon: String
    let temperature: Double
    let humidity: Double
    let uvIndex: Int
    let windSpeed: Double
    
    
    enum SerializationError:Error {
        case missing(String)
        case invalid(String, Any)
    }
    
    
    init(json:[String:Any], isDaily: Bool) throws {
        guard let summary = json["summary"] as? String else {throw SerializationError.missing("summary is missing")}
        
        
        guard let icon = json["icon"] as? String else {throw SerializationError.missing("icon is missing")}
        
        if isDaily {
            if let temperature = json["temperatureMax"] as? Double  {
                self.temperature = temperature
            } else {throw SerializationError.missing("temp is missing")}
        }
        else{
            if let temperature = json["temperature"] as? Double  {
                self.temperature = temperature
            } else {throw SerializationError.missing("temp is missing")}
        }
        
        guard let humidity = json["humidity"] as? Double else {throw SerializationError.missing("humidity is missing")}
        
        guard let uvIndex = json["uvIndex"] as? Int else {throw SerializationError.missing("UV Index is missing")}
        
        guard let windSpeed = json["windSpeed"] as? Double else {throw SerializationError.missing("wind speed is missing")}
        
        guard let time = json["time"] as? Double else {throw SerializationError.missing("time is missing")}
        
        self.time = Int(time)
        self.summary = summary
        self.icon = icon
        //self.temperature = temperature
        self.humidity = humidity
        self.uvIndex = uvIndex
        self.windSpeed = windSpeed
    }
    
    static let apiLink: String = "https://api.darksky.net/forecast/a5fafc7995f9f2c6c2df5af3af69a15b/"
    
    static func parseHistory(location: String, time: String, completion: @escaping (WeatherDaily?) -> ()) {
        let url = apiLink + location + "," + time + "T00:00:00Z"
        let request = URLRequest(url: URL(string: url)!)
        
        let task = URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            
            var weatherDailyData: WeatherDaily? = nil
            
            if let data = data {
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] {
                        if let dailyForecasts = json["daily"] as? [String:Any] {
                            if let dailyData = dailyForecasts["data"] as? [[String:Any]] {
                                for dataPoint in dailyData {
                                    if let weatherObject = try? WeatherDaily(json: dataPoint, isDaily: true) {
                                        weatherDailyData = weatherObject
                                    }
                                }
                            }
                        }
                        
                    }
                }catch {
                    print(error.localizedDescription)
                }
                
                completion(weatherDailyData)
                
            }
        }
        task.resume()
        
    }
    
    static func hourlyForecast (location: String, completion: @escaping ([WeatherDaily]?) -> ()) {
        let url = apiLink + location
        
        let request = URLRequest(url: URL(string: url)!)
        
        let task = URLSession.shared.dataTask(with: request) { (data:Data?, response:URLResponse?, error:Error?) in
            
            var forecastArray:[WeatherDaily] = []
            
            if let data = data {
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] {
                        if let dailyForecasts = json["hourly"] as? [String:Any] {
                            if let dailyData = dailyForecasts["data"] as? [[String:Any]] {
                                for dataPoint in dailyData {
                                    if let weatherObject = try? WeatherDaily(json: dataPoint, isDaily: false) {
                                        forecastArray.append(weatherObject)
                                    }
                                }
                            }
                        }
                    }
                }catch {
                    print(error.localizedDescription)
                }
                completion(forecastArray)
            }
        }
        task.resume()
    }
    
    static func dailyForecast (location: String, completion: @escaping ([WeatherDaily]?) -> ()) {
        let url = apiLink + location
        
        let request = URLRequest(url: URL(string: url)!)
        
        let task = URLSession.shared.dataTask(with: request) { (data:Data?, response:URLResponse?, error:Error?) in
            
            var forecastArray:[WeatherDaily] = []
            
            if let data = data {
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] {
                        if let dailyForecasts = json["daily"] as? [String:Any] {
                            if let dailyData = dailyForecasts["data"] as? [[String:Any]] {
                                for dataPoint in dailyData {
                                    if let weatherObject = try? WeatherDaily(json: dataPoint, isDaily: true) {
                                        forecastArray.append(weatherObject)
                                    }
                                }
                            }
                        }
                    }
                }catch {
                    print(error.localizedDescription)
                }
                completion(forecastArray)
            }
        }
        task.resume()
    }
    
    static func currentForecast (location: String, completion: @escaping ([WeatherDaily]?) -> ()) {
        let url = apiLink + location
        
        let request = URLRequest(url: URL(string: url)!)
        
        let task = URLSession.shared.dataTask(with: request) { (data:Data?, response:URLResponse?, error:Error?) in
            
            var forecastArray:[WeatherDaily] = []
            
            if let data = data {
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] {
                        if let dailyForecasts = json["currently"] as? [String:Any] {
                            if let weatherObject = try? WeatherDaily(json: dailyForecasts, isDaily: false) {
                                forecastArray.append(weatherObject)
                            }
                        }
                    }
                }catch {
                    print(error.localizedDescription)
                }
                completion(forecastArray)
            }
        }
        task.resume()
    }
    
    
}

