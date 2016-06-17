//
//  LocationManager.swift
//  RaceMe
//
//  Created by Enoch Ng on 2016-06-16.
//  Copyright © 2016 Enoch Ng. All rights reserved.
//

import Foundation
import CoreLocation

protocol LocationManagerDelegate : class {

    func updatedLocation(currentLocation : CLLocation)

}

class LocationManager : NSObject, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    var currentLocation : CLLocation?
    weak var LMDelegate : LocationManagerDelegate?
    
    static let sharedInstance = LocationManager()
    
    override init(){
        super.init()
        locationManager.delegate = self
    }

    func startLocationManager (){
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if(status == .AuthorizedAlways){
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //update current location
        currentLocation = locations.last
        
        if let lastLocation = locations.last {
            LMDelegate?.updatedLocation(lastLocation)
        }
        
        //print(currentLocation)
    }
    
    func stopLocationManager (){
        locationManager.stopUpdatingLocation()
    }
}
