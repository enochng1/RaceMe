//
//  TrainViewController.swift
//  RaceMe
//
//  Created by Enoch Ng on 2016-06-13.
//  Copyright © 2016 Enoch Ng. All rights reserved.
//

import UIKit
import Mapbox
import CoreLocation

class TrainViewController: UIViewController,  MGLMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: MGLMapView!
    
    var tracking:Bool = (false)
    var trackCamera : MGLMapCamera!
    var staticCamera : MGLMapCamera!
    
    @IBOutlet weak var paceLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    var currentLocation : CLLocation!
    
    var sessionRun : Run?
    lazy var sessionPaces = [Double]()
    lazy var timer = NSTimer()
    
    lazy var locationManager: CLLocationManager! = {
        let manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.delegate = self
        //        manager.distanceFilter = 1.0
        manager.requestAlwaysAuthorization()
        return manager
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        locationManager.delegate = self
        
        if(CLLocationManager.authorizationStatus() == .NotDetermined){
            locationManager.requestAlwaysAuthorization()
        }
        
        //setup zoomLevel
        mapView.showsUserLocation = true
        mapView.zoomLevel = 16
        
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if(status == .AuthorizedAlways){
            locationManager.startUpdatingLocation()
        }
    }
    
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        //test to see if tracking location in background
        //        if UIApplication.sharedApplication().applicationState == .Active {
        //             print(currentLocation.coordinate)
        //        } else {
        //             print(currentLocation.coordinate)
        //        }
        
        
        //update current location
        currentLocation = locations.last
        
        if(tracking){
            
            mapView.userTrackingMode = .FollowWithHeading
            updateRun()
            
        } else {
            //set map to current location and wait for tracking to begin
            mapView.setCenterCoordinate(currentLocation.coordinate, animated:true)
        }
    }
    
    @IBAction func startTracking(sender: UIButton) {
        
        if(tracking){
            tracking = false
            print("   ")
            print("end run")
                print("   ")
            //staticCamera = MGLMapCamera(lookingAtCenterCoordinate: currentLocation.coordinate, fromDistance: 50, pitch: 0.0, heading: 0)
            // mapView.setCamera(staticCamera, animated: true)
            timer.invalidate()
            
            sessionRun?.totalAveragePace = (sessionPaces.reduce(0, combine:+)) / Double(sessionPaces.count)
            print(sessionRun)
            print(sessionRun?.dateRan)
            print(sessionRun?.totalDistance)
            print(sessionRun?.totalAveragePace)
            print(sessionRun?.totalTime)
            
            updateUI()
            
        } else {
            tracking = true
                print("   ")
            print("starting run")
            print("   ")
            //  trackCamera = MGLMapCamera(lookingAtCenterCoordinate: currentLocation.coordinate, fromDistance: 50, pitch: 60.0, heading: 0)
            // mapView.setCamera(trackCamera, animated: true)
            
            //setup run object to prepare for location updates
            sessionRun = Run()
            sessionRun?.trackedLocations = [CLLocation]()
            sessionRun?.dateRan = NSDate()
            timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(secondIncrement), userInfo: nil, repeats: true)
        }
        
    }
    
    func updateUI(){
        distanceLabel.text = String(format:"%0.2f km", (sessionRun?.totalDistance)!)
        paceLabel.text = String(format:"%0.2f min/km", sessionPaces.last!)
        timeLabel.text = sessionRun?.totalTimeTranslation()
    }
    
    
    func secondIncrement(){
        sessionRun?.totalTime = (sessionRun?.totalTime)! + 1
        
        //update the UI so it reflects the useful information
        updateUI()
    }
    
    func updateRun(){
        
        //add the next location
        sessionRun?.trackedLocations.append(currentLocation)
        mapView.setCenterCoordinate(currentLocation.coordinate, animated:true)
        
        //draw the run path
        drawRun()
        
        //taking raw data from location manager and translating to useful information for the user
        sessionRun?.totalDistance += currentLocation.speed/1000
        sessionPaces.append(1000/(currentLocation.speed*60))
    
    }
    
    func drawRun(){
        
        var coordinates: [CLLocationCoordinate2D] = []
        
        for trackedLocation in (sessionRun?.trackedLocations)! {
            
            let coordinate = trackedLocation.coordinate
            coordinates.append(coordinate)
        }
        
        let line = MGLPolyline(coordinates: &coordinates, count: UInt(coordinates.count))
        mapView.addAnnotation(line)
    }
    
    
    
}
