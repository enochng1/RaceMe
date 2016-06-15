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
    
    var currentLocation : CLLocation!
    var trackedLocations : [CLLocation]!
    
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
        
        mapView.showsUserLocation = true
        mapView.zoomLevel = 17
        
        trackedLocations = [CLLocation]()
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if(status == .AuthorizedAlways){
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        currentLocation = locations.last
        mapView.setCenterCoordinate(currentLocation.coordinate, animated: true)
        
        if UIApplication.sharedApplication().applicationState == .Active {
           // print(currentLocation.coordinate)
        } else {
           // print(currentLocation.coordinate)
        }
        
        if(tracking){
            trackedLocations.append(currentLocation)
            print(trackedLocations)
        }
        
    }
    
    //    func mapView(mapView: MGLMapView, didUpdateUserLocation userLocation: MGLUserLocation?){
    ////
    //        if(!tracking){
    //
    //            //            staticCamera = MGLMapCamera(lookingAtCenterCoordinate: self.mapView.userLocation!.location!.coordinate, fromDistance: 500, pitch: 0, heading: 0)
    //            //            mapView.setCamera(staticCamera, animated: true)
    //            mapView.setCenterCoordinate(userLocation!.coordinate, animated: true)
    //        } else {
    //
    //        }
    //        mapView.userTrackingMode = .FollowWithHeading
    //        if UIApplication.sharedApplication().applicationState == .Active {
    //            print(userLocation)
    //        } else {
    //            print(userLocation)
    //        }
    //
    //
    //    }
    
    
    @IBAction func startTracking(sender: UIButton) {
        
        if(tracking){
            tracking = false
            print("end of run")
            
            
            
            
            
            
//            staticCamera = MGLMapCamera(lookingAtCenterCoordinate:currentLocation.coordinate, fromDistance: 100, pitch: 0, heading: 0)
//            mapView.setCamera(staticCamera, animated: true)
//            print(mapView.camera)
//            mapView.zoomLevel = 18
            
            
            
        } else {
            tracking = true
            print("starting run")
            
        
//            trackCamera = MGLMapCamera(lookingAtCenterCoordinate:currentLocation.coordinate, fromDistance: 100, pitch: 60, heading: 0)
//             mapView.setCamera(trackCamera, animated: true)
//              print(mapView.camera)
  
            //            print(self.mapView.userLocation!.heading?.trueHeading)
            //self.mapView.userTrackingMode = .FollowWithHeading
            //            print(self.mapView.userLocation!.heading)
            
            //            trackCamera = MGLMapCamera(lookingAtCenterCoordinate: self.mapView.userLocation!.location!.coordinate, fromDistance: 100, pitch: 80, heading: 0)
            //            mapView.setCamera(trackCamera, animated: true)
            
            //            mapView.userTrackingMode = .FollowWithHeading
            //            mapView.camera.pitch = 80;
            
        }
        
    }
    
    
}
