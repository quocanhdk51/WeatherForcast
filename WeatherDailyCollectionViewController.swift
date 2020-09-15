//
//  WeatherDailyCollectionViewController.swift
//  NewWeatherForecast
//
//  Created by Ma Duy Loc on 20/09/2018.
//  Copyright © 2018 Alice Ma. All rights reserved.
//

import UIKit
import CoreLocation

private let reuseIdentifier = "Cell"

class WeatherDailyCollectionViewController: UICollectionViewController, UISearchBarDelegate {
    
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet var modeView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var blurEffectView: UIVisualEffectView!
    var isFahrenheit: Bool!
    var weatherData = [WeatherDaily]()
    var isDaily: Bool!
    var state: State = State.CURRENT
    var location: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        modeView.layer.cornerRadius = 5
        
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        isFahrenheit = true
        location = "Hanoi"
        searchBar.text = location
        updateWeatherForLocation(location: "Hanoi")

    }
    
    func selectMode() {
        self.view.addSubview(blurEffectView)
        self.view.addSubview(modeView)
        
        modeView.center = self.view.center
        modeView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        modeView.alpha = 0
        
        
        UIView.animate(withDuration: 0.4) {
            self.modeView.alpha = 1
            self.modeView.transform = CGAffineTransform.identity
            
        }
    }
    
    
    func settingClose () {
        UIView.animate(withDuration: 0.3, animations: {
            self.modeView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.modeView.alpha = 0
            
            
        }) { (success:Bool) in
            self.view.sendSubview(toBack: self.blurEffectView)
            self.modeView.removeFromSuperview()
            print("get out of current mode and get current value")
        }
    }
    
    @IBAction func modeSetting(_ sender: Any) {
        selectMode()
    }
    
    @IBAction func chooseCurrentMode(_ sender: Any) {
        state = State.CURRENT
        updateWeatherForLocation(location: location)
        settingClose()
    }
    @IBAction func chooseNext24HMode(_ sender: Any) {
        state = State.HOURLY
        updateWeatherForLocation(location: location)
        settingClose()
    }
    @IBAction func chooseDailyForecast(_ sender: Any) {
        state = State.DAILY
        updateWeatherForLocation(location: location)
        settingClose()
    }
    @IBAction func chooseHistory(_ sender: Any) {
        state = State.HISTORY
        updateWeatherForLocation(location: location)
        settingClose()
    }
    @IBAction func convertToUnit(_ sender: Any) {
        switch segmentedControl.selectedSegmentIndex {
        case 1:
            isFahrenheit = false
        default:
            isFahrenheit = true
        }
        
        self.collectionView?.reloadData()
    }
    
    @IBAction func settingClosed(_ sender: Any) {
        settingClose()
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if (kind == UICollectionElementKindSectionHeader) {
            let headerView:UICollectionReusableView =  collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "CollectionViewHeader", for: indexPath)
            
            return headerView
        }
            return UICollectionReusableView()
        
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if let locationString = searchBar.text, !(searchBar.text?.isEmpty)!{
            self.location = locationString
            updateWeatherForLocation(location: locationString)
            //updateWeatherForLocation(location: locationString)
        }
    }
    
    // MARK: - Navigation
 

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.size.width - 22
        return CGSize(width: width - 16, height: 160)
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return weatherData.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WeatherDailyCell", for: indexPath) as! WeatherDailyCollectionViewCell
        
        let weatherDailyObjectData = weatherData[indexPath.row]
        if (isFahrenheit == false) {
            cell.weatherTemp.text = "Temperature " + String(Int((weatherDailyObjectData.temperature) - 32) * 5/9) + " °C" }
            else {
            cell.weatherTemp.text = "Temperature " + String(Int(weatherDailyObjectData.temperature)) + " °F" }
        cell.setWeather(weatherDaily: weatherDailyObjectData, isDaily: isDaily, isFahrenheit: isFahrenheit)
        return cell
    }

    func updateWeatherForLocation (location: String){
        CLGeocoder().geocodeAddressString(location){ (placemarks: [CLPlacemark]?, error: Error?) in
            if error == nil{
                if let location = placemarks?.first?.location{
                    
                    self.caseHandler(withLocation: location.coordinate, state: self.state)
                    
                    print("reach reload table")
                }
            }
        }
        
    }
    
    
    
    func getHistory(withLocation location: CLLocationCoordinate2D) {
        let locationCoordinate = "\(location.latitude),\(location.longitude)"
        var weatherData = [WeatherDaily]()
        for i in -7 ...  -1 {
            WeatherDaily.parseHistory(location: locationCoordinate, time: getDate(daysToAdd: i),
                                      completion: {(result: WeatherDaily!) in
                                        if let weatherDailyData = result {
                                            weatherData.append(weatherDailyData)
                                            self.weatherData = weatherData
                                        }
                                        /*
                                         Since reloadData is a UI API call, it needs to happen on main thread and not background one
                                         (e.g closures, completion handlers etc), so we dispatch the reloadData statement to
                                         to main thread */
                                        self.isDaily = true
                                        DispatchQueue.main.async {
                                            self.collectionView?.reloadData()
                                        }
                                        
            })
        }
    }
    
    
    func getDate(daysToAdd: Int) -> String {
        let date = Calendar.current.date(byAdding: .day, value: daysToAdd, to: Date())
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        print(dateFormatter.string(from: date!))
        return dateFormatter.string(from: date!)
    }
    
    func getHourlyForecast(withLocation location: CLLocationCoordinate2D) {
        let locationCoordinate = "\(location.latitude),\(location.longitude)"
        WeatherDaily.hourlyForecast(location: locationCoordinate, completion: {(result: [WeatherDaily]!) in
            if let weatherData = result {
                self.weatherData = weatherData
                self.isDaily = false
                DispatchQueue.main.async {
                    self.collectionView?.reloadData()
                }
            }
        })
    }
    
    func getDailyForecast(withLocation location: CLLocationCoordinate2D) {
        let locationCoordinate = "\(location.latitude),\(location.longitude)"
        WeatherDaily.dailyForecast(location: locationCoordinate, completion: {(result: [WeatherDaily]!) in
            if let weatherData = result {
                self.weatherData = weatherData
                self.isDaily = true
                DispatchQueue.main.async {
                    self.collectionView?.reloadData()
                }
            }
        })
    }
    
    func getCurrentForecast(withLocation location: CLLocationCoordinate2D) {
        let locationCoordinate = "\(location.latitude),\(location.longitude)"
        WeatherDaily.currentForecast(location: locationCoordinate, completion: {(result: [WeatherDaily]!) in
            if let weatherData = result {
                self.weatherData = weatherData
                self.isDaily = true
                DispatchQueue.main.async {
                    self.collectionView?.reloadData()
                }
            }
        })
    }
    
    enum State {
        case CURRENT
        case HOURLY
        case DAILY
        case HISTORY
    }
    
    func caseHandler(withLocation location: CLLocationCoordinate2D ,state: State) {
        switch state {
        case .HOURLY:
            getHourlyForecast(withLocation: location)
        case .DAILY:
            getDailyForecast(withLocation: location)
        case .HISTORY:
            getHistory(withLocation: location)
        default:
            getCurrentForecast(withLocation: location)
        }
    }


    // MARK: UICollectionViewDelegate
   
    
    
/*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
