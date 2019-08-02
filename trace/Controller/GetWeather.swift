//
//  GetWeather.swift
//  trace
//
//  Created by ITP312 on 9/7/19.
//  Copyright © 2019 NYP. All rights reserved.
//
import Foundation
import AVFoundation

class GetWeather {
    var syth = AVSpeechSynthesizer()
    var utterance = AVSpeechUtterance(string: "")
    let openWeatherMapBaseURL = "http://api.openweathermap.org/data/2.5/weather"
    
    let openWeatherMapAPIKey = "ce45135fe033185bb7ad75548acc9335"
    
    func getWeather(city: String, onComplete: @escaping () -> Void) {
        let session = URLSession.shared
        
        let escapedCity = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        let weatherRequestURL = URL(string: "\(openWeatherMapBaseURL)?APPID=\(openWeatherMapAPIKey)&q=\(escapedCity)")
        //let weatherRequestURL = URL(string: "http://api.openweathermap.org/data/2.5/weather?APPID=ce45135fe033185bb7ad75548acc9335&q=Ang%20Mo%20Kio")
        
        let dataTask = session.dataTask(
            with: weatherRequestURL!,
            completionHandler: {
                (data, response, error) in
                if let error = error {
                    print("Error:\n\(error)")
                } else {
                    do {
                        let weather = try
                            JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [String: AnyObject]
                        let tempKelvin = weather["main"]!["temp"]!! as! Double
                        
                        var tempCelcius = tempKelvin - 273.15
                        tempCelcius = Double(round(10*tempCelcius)/10)
                        
                        let name = weather["name"]!
                        var condition = (weather["weather"]![0]! as! [String: AnyObject])
                        let humidity = weather["main"]!["humidity"]!!
                        let pressure = weather["main"]!["pressure"]!!
                        // Weather.celsius = tempCelcius
                        // Weather.name = weather["name"]! as! String
                        self.utterance = AVSpeechUtterance(string: "Weather for \(weather["name"]!): It is \((weather["weather"]![0]! as! [String: AnyObject])["main"]!) outside. The temperature is \(tempCelcius) Celcius. The Humidity is \(weather["main"]!["humidity"]!!) percent. The pressure is \(weather["main"]!["pressure"]!!)hpa." )
                        
                        Weather.weather = "Weather for \(name): It is \(condition["main"]!) outside. The temperature is \(tempCelcius) Celcius. The Humidity is \(humidity) percent. The pressure is \(pressure)hpa."
                        self.utterance.rate = 0.4
                        self.syth.speak(self.utterance)
                        
                        onComplete()
                    }
                    catch let jsonError as NSError {
                        print("JSON error: \(jsonError.description)")
                    }
                }
        })
        dataTask.resume()
        
        
        
    }
    
    
}
