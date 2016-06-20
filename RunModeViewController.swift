//
//  RunModeViewController.swift
//  RaceMe
//
//  Created by Enoch Ng on 2016-06-19.
//  Copyright © 2016 Enoch Ng. All rights reserved.
//

import Foundation
import UIKit
import Mapbox
import CoreLocation
import RealmSwift
import QuartzCore

class RunModeViewController: UIViewController,  MGLMapViewDelegate, LocationManagerDelegate, setAsCurrentViewControllerDelegate{
    
    //UI
    @IBOutlet weak var mapView: MGLMapView!
    
    @IBOutlet weak var paceLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    @IBOutlet weak var trackingAreaHeightConstant: NSLayoutConstraint!
    @IBOutlet weak var trackingAreaLabel: UILabel!
    @IBOutlet weak var trackingAreaContainerView: UIView!
    @IBOutlet weak var pinpointLocationButton: UIButton!
    
    //UI properties
    var trackLocation : String?
    
    //model
    var locationManager = LocationManager.sharedInstance
    let myRealm = try! Realm()
    
    //track setup
    var track = Track()
    var checkPointTracker = 1
    var timer = NSTimer()
    
    //mapView setup
    var mapViewHasSetUp = false
    
    //stages of running
    var runHasSetUp = false
    var runTracking = false
    var runEnded = false
    var runCleared = false
    
    //run setup
    var user = Runner()
    var userRun = Run()
    
    //ghost setup
    lazy var ghost = Runner()
    lazy var ghostRun = Run()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        locationManager.LMDelegate = self
    }
    
    func registerAsCurrentViewController(){
        locationManager.LMDelegate = self
    }
    
    
    func updatedLocation(currentLocation: CLLocation){
        
        user.currentLocation = currentLocation
        
        //setup mapView only runs once
        if !mapViewHasSetUp {
            setUpMapView()
            mapViewHasSetUp = true
        }
        
        if(runTracking){
            updateRunFor(user, aRun: userRun)
            if(userRun.isRace){
                updateRunFor(ghost, aRun: ghostRun)
            }
        }
    }
    
    @IBAction func startTrackingRun(sender: UIButton) {
        
        if !runTracking {
            
            if(userRun.isRace){
                //setUpRace()
            } else {
                setUpRun()
            }
            runTracking = true
        } else {
            updateUI()
            endRun()
            runTracking = false
        }
    }
    
    func setUpRun(){
        
        track = Track()
        track.trackLocation = trackLocation!
        
        //creat a new run object, set a new timer
        userRun = Run()
        userRun.dateRan = NSDate()
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(secondIncrement), userInfo: nil, repeats: true)
        
        checkPointTracker = 1
    }
    
    func secondIncrement(){
        
        userRun.totalTimeSeconds = userRun.totalTimeSeconds + 1
        
        //update the UI so it reflects the useful information by the second
        updateUI()
    }
    
    func setUpUIForNewRun(){
        
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
    
    
    func updateUI(){
        
        distanceLabel.text = userRun.distanceRanInKilometresToString()
        paceLabel.text = user.paceToString()
        timeLabel.text = userRun.formattedTime()
        
    }
    
    
    func updateRunFor(aRunner: Runner, aRun: Run){
        
        mapView.setCenterCoordinate((aRunner.currentLocation?.coordinate)!, animated: true)
        
        //calculate distance
        if aRun.footPrints.last != nil{
            
            let distanceBetweenLastPointAndCurrentLocation = aRunner.currentLocation?.distanceFromLocation((aRun.footPrints.last?.trackPointToCLLocation())!)
            
            aRun.distanceRanInMetres += distanceBetweenLastPointAndCurrentLocation!
            
        }
        
        //append footprint
        let newTrackPoint = TrackPoint()
        newTrackPoint.altitude = aRunner.currentLocation!.altitude
        newTrackPoint.latitude = aRunner.currentLocation!.coordinate.latitude
        newTrackPoint.longitude = aRunner.currentLocation!.coordinate.longitude
        
        if(aRun.distanceRanInMetres > Double(checkPointTracker)){
            newTrackPoint.checkPoint = checkPointTracker
            checkPointTracker = checkPointTracker + 1
        }
        
        aRun.footPrints.append(newTrackPoint)
    }
    
    func drawRunFor(aRun: Run){
        
        var coordinates: [CLLocationCoordinate2D] = []
        
        for trackPoint in (aRun.footPrints) {
            
            let coordinate = trackPoint.trackPointToCLLocationCoordinate2D()
            coordinates.append(coordinate)
        }
        
        let line = MGLPolyline(coordinates: &coordinates, count: UInt(coordinates.count))
        mapView.addAnnotation(line)
    }
    
    func checkToSeeIfLocationsFetchingInBackground(){
        if UIApplication.sharedApplication().applicationState == .Active {
            print(user.currentLocation!.coordinate)
        } else {
            print(user.currentLocation!.coordinate)
        }
    }
    
    func endRun(){
        //stop timer
        timer.invalidate()
        checkPointTracker = 0
        
    }
    
    func endRunUpdateMapViewWith(aRun: Run){
        //centered on track
        var coordinates: [CLLocationCoordinate2D] = []
        for trackPoint in aRun.footPrints {
            let coordinate = trackPoint.trackPointToCLLocationCoordinate2D()
            coordinates.append(coordinate)
        }
        mapView.setVisibleCoordinates(&coordinates, count: UInt(coordinates.count), edgePadding: UIEdgeInsetsMake(60.0, 40.0, 70.0, 40.0), animated: true)
    }
    
    func drawCheckPointsFor(aRun : Run){
        
        for trackPoint in aRun.footPrints {
            
            if(trackPoint.checkPoint > 0){
                
                let checkPoint = trackPoint.trackPointToCLLocationCoordinate2D()
                
                let checkPointIndicator = MGLPointAnnotation()
                checkPointIndicator.coordinate = checkPoint
                checkPointIndicator.title = String(format: "%i km",trackPoint.checkPoint)
                mapView.addAnnotation(checkPointIndicator)
            }
        }
        
    }
    
    @IBAction func pinpointButtonPressed(sender: UIButton) {
        if(user.currentLocation != nil){
            mapView.setCenterCoordinate(user.currentLocation!.coordinate, animated:true)
        }
    }
    
    func mapView(mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }
    
    func mapView(mapView: MGLMapView, lineWidthForPolylineAnnotation annotation: MGLPolyline) -> CGFloat {
        // Set the line width for polyline annotations
        if (annotation.title == "track") {
            return 16.0
        }
        else if (annotation.title == "ghostBreadCrumbs") {
            
            return 8.0
            
        } else if (annotation.title == "userBreadCrumbs") {
            
            return 2.0
        } else {
            
            return 2.0
        }
        
    }
    
    
    func mapView(mapView: MGLMapView, strokeColorForShapeAnnotation annotation: MGLShape) -> UIColor {
        // Give our polyline a unique color by checking for its `title` property
        if (annotation.title == "track" && annotation is MGLPolyline) {
            return UIColor.whiteColor()
        }
        else if (annotation.title == "ghostBreadCrumbs" && annotation is MGLPolyline) {
            
            return UIColor.greenColor()
            
        } else if (annotation.title == "userBreadCrumbs" && annotation is MGLPolyline) {
            
            return UIColor.orangeColor()
        } else {
            
            return UIColor.yellowColor()
        }
    }
    
    func saveRunToRealm(){
        //write to Realm
        try! myRealm.write { () -> Void in
            myRealm.add(userRun)
        }
    }
    
    
    @IBAction func saveRun(sender: UIButton) {
        if !runTracking{
            saveRunToRealm()
        }
    }
    
    func setUpMapView(){
        CLGeocoder().reverseGeocodeLocation(user.currentLocation!, completionHandler: {(placemarks, error) -> Void in
            if error != nil {
                print("Reverse geocoder failed with error" + error!.localizedDescription)
                return
            }
            if placemarks?.count > 0 {
                let pm = placemarks![0]
                self.trackLocation = pm.locality
                self.trackingAreaLabel.text = "Track Location: "+self.trackLocation!
                self.mapView.setCenterCoordinate(self.user.currentLocation!.coordinate, animated:true)
                print("located")
            }
            else {
                print("Problem with the data received from geocoder")
            }
        })
        
        //setup zoomLevel
        self.mapView.showsUserLocation = true
        self.mapView.zoomLevel = 15
    }
}

