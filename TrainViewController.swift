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
import RealmSwift

class TrainViewController: UIViewController,  MGLMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: MGLMapView!
    
    var tracking:Bool = (false)
    var trackCamera : MGLMapCamera!
    var staticCamera : MGLMapCamera!
    
    @IBOutlet weak var paceLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    @IBOutlet weak var trackingAreaHeightConstant: NSLayoutConstraint!
    @IBOutlet weak var trackingAreaLabel: UILabel!
    @IBOutlet weak var trackingAreaContainerView: UIView!
    @IBOutlet weak var pinpointLocationButton: UIButton!
    
    var currentLocation : CLLocation!
    var trackedLocations = [CLLocation]()
    var trackStartingArea : String?
    
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
    
    let uiRealm = try! Realm()

    
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
            
            updateRun()
            
        } else {
            
            if(self.trackStartingArea == nil){
                //set trackStartingArea
                CLGeocoder().reverseGeocodeLocation(self.currentLocation, completionHandler: {(placemarks, error) -> Void in
                    if error != nil {
                        print("Reverse geocoder failed with error" + error!.localizedDescription)
                        return
                    }
                    if placemarks?.count > 0 {
                        let pm = placemarks![0]
                        self.trackStartingArea = pm.locality
                        self.trackingAreaLabel.text = "Track Location: "+self.trackStartingArea!
                        print("located")
                    }
                    else {
                        print("Problem with the data received from geocoder")
                    }
                })
                //set map to current location and wait for tracking to begin
                mapView.setCenterCoordinate(currentLocation.coordinate, animated:true)
                
            }
            
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
            sessionRun?.areaLocation = trackStartingArea
            print(sessionRun?.dateRan)
            print(sessionRun?.totalDistance)
            print(sessionRun?.totalAveragePace)
            print(sessionRun?.totalTime)
            print(sessionRun?.areaLocation)
            
  
            for location in trackedLocations{
                
                let realmLocation = RealmCLLocation()
                realmLocation.speed = location.speed
                realmLocation.lat = location.coordinate.latitude
                realmLocation.lng = location.coordinate.longitude
                
                sessionRun?.realmTrackedLocations.append(realmLocation)                
            }
            
            try! uiRealm.write { () -> Void in
                uiRealm.add(sessionRun!)
                
            }
            
            let allRuns = uiRealm.objects(Run.self)
            print(allRuns)
            
            for run in allRuns {
                print(run.realmTrackedLocations)
            }
            
            //UIupdates
            mapView.tintColor = UIColor(red: 0.0, green: 0.817, blue: 0.714, alpha: 1.0)
  
            updateUI()
            
            UIView.animateWithDuration(0.5, delay: 0, options: .CurveEaseInOut, animations: {
                self.trackingAreaLabel.alpha = 1.0
                }, completion: nil)
            
            self.trackingAreaHeightConstant.constant = 30.0
            UIView.animateWithDuration(1, delay: 0, options: .CurveEaseInOut, animations: {
                self.trackingAreaContainerView.alpha = 1.0
                self.trackingAreaContainerView.layoutIfNeeded()
                self.pinpointLocationButton.alpha = 0.8
                }, completion: nil)
            
        } else {
            tracking = true
                print("   ")
            print("starting run")
            print("   ")
            //  trackCamera = MGLMapCamera(lookingAtCenterCoordinate: currentLocation.coordinate, fromDistance: 50, pitch: 60.0, heading: 0)
            // mapView.setCamera(trackCamera, animated: true)
            
            //setup run object to prepare for location updates
            sessionRun = Run()
            trackedLocations = [CLLocation]()
            sessionRun?.dateRan = NSDate()
            timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(secondIncrement), userInfo: nil, repeats: true)
            
            //UIupdates & animate
            mapView.tintColor = .orangeColor()
                
            UIView.animateWithDuration(0.5, delay: 0, options: .CurveEaseInOut, animations: {
                self.trackingAreaLabel.alpha = 0.0
                }, completion: nil)
            
            self.trackingAreaHeightConstant.constant = 0.0
            UIView.animateWithDuration(1, delay: 0, options: .CurveEaseInOut, animations: {
                self.trackingAreaContainerView.alpha = 0.0
                self.trackingAreaContainerView.layoutIfNeeded()
                self.pinpointLocationButton.alpha = 0.0
                }, completion: nil)
    
        }
        
    }
    
    func updateUI(){
        distanceLabel.text = String(format:"%0.2f km", (sessionRun?.totalDistance)!)
        paceLabel.text = String(format:"%0.2f min/km", sessionPaces.last!)
        timeLabel.text = sessionRun?.totalTimeTranslation()
    }
    
    
    func secondIncrement(){
        sessionRun?.totalTime = (sessionRun?.totalTime)! + 1

        //update the UI so it reflects the useful information by the second
        updateUI()
    }
    
    func updateRun(){
        
        //add the next location
        trackedLocations.append(currentLocation)
        mapView.setCenterCoordinate(currentLocation.coordinate, animated:true)
        
        //draw the run path
        drawRun()
        
        //taking raw data from location manager and translating to useful information for the user
        sessionRun?.totalDistance += currentLocation.speed/1000
        sessionPaces.append(1000/(currentLocation.speed*60))
    
    }
    
    @IBAction func pinpointButtonPressed(sender: UIButton) {
        
        if(self.currentLocation != nil){
             mapView.setCenterCoordinate(currentLocation.coordinate, animated:true)
        }
        
    }
    
    func drawRun(){
        
        var coordinates: [CLLocationCoordinate2D] = []
        for trackedLocation in (trackedLocations) {
            
            let coordinate = trackedLocation.coordinate
            coordinates.append(coordinate)
        }
        
        let line = MGLPolyline(coordinates: &coordinates, count: UInt(coordinates.count))
        mapView.addAnnotation(line)
    }
    
    func endOfRace(){
    
//        mapView.setVisibleCoordinates(<#T##coordinates: UnsafeMutablePointer<CLLocationCoordinate2D>##UnsafeMutablePointer<CLLocationCoordinate2D>#>, count: <#T##UInt#>, edgePadding: <#T##UIEdgeInsets#>, animated: <#T##Bool#>)
    }
    
    
}
