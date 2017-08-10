//
//  ViewController.swift
//  weatherApp
//
//  Created by Colon, Joel on 8/7/17.
//  Copyright © 2017 Intern. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import MapKit
import CoreLocation

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var WeatherView: UIView!
    @IBOutlet weak var WeatherImg: UIImageView!
    @IBOutlet weak var WeatherDesc: UILabel!
    @IBOutlet weak var TempC: UILabel!
    @IBOutlet weak var TempF: UILabel!
    @IBOutlet weak var Location: UILabel!
    
    var temp: Int?
    var location: String?
    var Weather: String?
    var Date: String?
    var Sunrise: String?
    var Sunset: String?
    var SunriseInt: Int?
    var SunsetInt: Int?
    var miscTypes: [String] = []
    var miscValues: [String] = []
    let manager = CLLocationManager()
    
    


    override func viewDidLoad() {
        super.viewDidLoad()

        
        // Do any additional setup after loading the view, typically from a nib.
        // print(convertFromKelvin(temp: 273, isCelsius: false))
        
        manager.delegate = self
        manager.requestLocation()
        }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            
            
            
           let lat = String(location.coordinate.latitude)
           let long = String(location.coordinate.longitude)
            getData(lat: lat,long: long)
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }

    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return miscTypes.count
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:TableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableViewCell
        
        cell.typeLabel?.text = miscTypes[indexPath.row]
        cell.valueLabel?.text = miscValues[indexPath.row]
        
        return cell
    }
    
    // if user is in US, convert to farenheit
    func convertFromKelvin(temp: Int, isCelsius: Bool) -> Int{
        switch isCelsius{
            case false:
                return temp * 9/5 - 459
            case true:
                return temp - 273
        }
    }
    


    
    func formatDate(timestamp: Double?) -> Int64{
        
        let date = NSDate(timeIntervalSince1970: timestamp!)
        let time = Int64(date.timeIntervalSince1970 * 1000)
        return time
    }
    
    // replace background color and weather img
    func insertTimeStyle(isDay: Bool){
        switch isDay{
            case true:
                WeatherImg.image = UIImage(named:"Sun")
                WeatherView.backgroundColor = UIColor(red: 0/255, green: 195/255, blue: 255/255, alpha: 1)
                
            case false:
                WeatherImg.image = UIImage(named:"Moon")
                WeatherView.backgroundColor = .black
        }
        
    }
    
    func checkDay(sunrise: Int64?,sunset:Int64?) -> Bool{
        let currentTime = Int64(NSDate().timeIntervalSince1970 * 1000)
        print(currentTime)
        
        if currentTime > sunrise! && currentTime < sunset! {
            return true
        }
        else{
            return false
        }
    }
    
    func insertText(Celsius: Int, Farenheit: Int){
        self.TempC.text = String(describing: Celsius) + " C"
        self.TempF.text = String(describing: Farenheit) + " F"
    }
    
    

    
    func getData(lat: String, long: String){
        let endpoint = "http://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(long)&APPID=3238e71ca79614e00f3a6f63a0af72a4"
        
        print(lat,long)
        Alamofire.request(endpoint)
            .responseJSON{ response in
                switch response.result {
                    case .success(let value):
                        let json = JSON(value)
                        print(json)
                        // handle weather desc
                        let weather = json["weather"][0]["main"].stringValue
                        
                        self.WeatherDesc.text = "Weather: \(weather)"
                        
                        
                        // handle temperature
                        let intT = json["main"]["temp"].intValue
                        let C = self.convertFromKelvin(temp: intT, isCelsius: true)
                        let F = self.convertFromKelvin(temp: intT, isCelsius: false)

                        self.insertText(Celsius:C,Farenheit:F)
                        
                        // handle misc info
                        
                    
                        for key in json["main"]{
                            
                            if key.0.range(of:"temp") == nil  {
                                self.miscTypes.append(key.0)
                                self.miscValues.append(key.1.stringValue)
                            }

                        }
                        
                        
                        // handle location
                        let locationName = json["name"]
                        let locationLat = json["lat"]
                        let locationLong = json["lon"]
                        self.Location.text = "Location: \(locationName)"
                        
                        
                        // handle Time
                        let sunriseTimestamp = json["sys"]["sunrise"].doubleValue
                        let sunsetTimestamp = json["sys"]["sunset"].doubleValue
                        let sunrise = self.formatDate(timestamp: sunriseTimestamp)
                        let sunset = self.formatDate(timestamp: sunsetTimestamp)
                    
                        let isDay = self.checkDay(sunrise: sunrise,sunset: sunset)
                    
                        self.insertTimeStyle(isDay: isDay)
                    
                    
                        DispatchQueue.main.async {
                            self.table?.reloadData()
                            //reload on main thread
                    }
                    case .failure(let error):
                        print(error)
            }
        }
    }
}

