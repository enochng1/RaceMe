//
//  RaceViewController.swift
//  RaceMe
//
//  Created by Enoch Ng on 2016-06-16.
//  Copyright © 2016 Enoch Ng. All rights reserved.
//

import UIKit
import Mapbox
import CoreLocation
import RealmSwift

class RaceViewController: UIViewController, MGLMapViewDelegate, LocationManagerDelegate {
    
    var locationManager = LocationManager.sharedInstance
    
    //track specifics
    var track : Run!
    var start : CLLocationCoordinate2D?
    var end : CLLocationCoordinate2D?
    lazy var timer = NSTimer()
    
    //user variables
    var myRun : Run!
    var currentLocation : CLLocation!
    var sessionPaces = [Double]()
    
    //ghost variables
    var ghostRun : Run!
    var ghostLocationIncrementer : Int = 0
    var ghostCurrentLocation : CLLocation = CLLocation()
    var ghostAnnotation : MGLPointAnnotation!
    
    //state variables
    var hasSetupTrack = false
    var startedRace = false
    
    @IBOutlet weak var mapView: MGLMapView!
    
    @IBOutlet weak var trackingAreaColorView: UIView!
    @IBOutlet weak var trackingAreaLayoutHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var checkpointLocatorLabel: UILabel!
    
    @IBOutlet weak var trackingAreaContainerView: UIView!
    @IBOutlet weak var startRaceButton: UIButton!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var paceLabel: UILabel!
    @IBOutlet weak var distanceDiffLabel: UILabel!
    @IBOutlet weak var timeDiffLabel: UILabel!
    
    override func viewDidLoad() {
        mapView.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        locationManager.LMDelegate = self
    }
    
    
    
    func updatedLocation(currentLocation: CLLocation) {
        
        self.currentLocation = currentLocation
        
        if !hasSetupTrack {
            preRaceSetup()
            hasSetupTrack = true
            NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: #selector(finishShowingTrackThenPinPointUserLocation), userInfo: nil, repeats: false)
        }
        
        if(!startedRace){
            detectProximityToStart()
        } else {
            
            
            if ghostLocationIncrementer < track.realmTrackedLocations.count {
            
            let ghostRealmCLLocation = track.realmTrackedLocations[ghostLocationIncrementer]
            
            ghostCurrentLocation = CLLocation(latitude: ghostRealmCLLocation.lat, longitude: ghostRealmCLLocation.lng)
            
            ghostLocationIncrementer += 1
                
            }
            
            if(myRun.totalDistance < track.totalDistance){
                
            updateMyRun()
            
            } else {
                
                print("run ended")
            }
        
        
        }
        
    }
    
    func detectProximityToStart(){
        let distanceFromStartPoint = self.currentLocation.distanceFromLocation(CLLocation(coordinate: start!, altitude: 0.0, horizontalAccuracy: 0.0, verticalAccuracy: 0.0, timestamp: NSDate()))
        
        if (distanceFromStartPoint > 15.0){
            
            trackingAreaColorView.backgroundColor = UIColor(red:0.929, green:0.388, blue:0.415, alpha:1)
            
            startRaceButton.userInteractionEnabled = false
            startRaceButton.titleLabel?.textColor = UIColor(red:0.929, green:0.388, blue:0.415, alpha:1)
            
            startRaceButton.titleLabel?.text = ""
            
            checkpointLocatorLabel.text = String(format: "%0.0f metres away from start", distanceFromStartPoint)
            
            mapView.tintColor = UIColor(red:0.929, green:0.388, blue:0.415, alpha:1)
            
        } else {
            
            trackingAreaColorView.backgroundColor =  UIColor(red: 0.0, green: 0.817, blue: 0.714, alpha: 1.0)
            checkpointLocatorLabel.text = "Arrived at start - Race can begin"
            
            startRaceButton.userInteractionEnabled = true
            startRaceButton.titleLabel?.textColor = UIColor(red: 0.0, green: 0.817, blue: 0.714, alpha: 1.0)
            startRaceButton.titleLabel?.text = "Start Race"
            
            mapView.tintColor = UIColor(red: 0.0, green: 0.817, blue: 0.714, alpha: 1.0)
            
        }
    }

    func finishShowingTrackThenPinPointUserLocation(){
        mapView.setCenterCoordinate(self.currentLocation.coordinate, animated: true)
    }

    @IBAction func startRacePressed(sender: UIButton) {
        
        if(startedRace){
            startedRace = false
            
            //code for end race
            
        } else {
            startedRace = true
            
            //code for start race
            myRun = Run()
            ghostRun = Run()
            myRun.dateRan = NSDate()
            timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(secondIncrement), userInfo: nil, repeats: true)
            
            //UIupdates & animate
            mapView.tintColor = .orangeColor()
            UIView.animateWithDuration(0.5, delay: 0, options: .CurveEaseInOut, animations: {
                self.checkpointLocatorLabel.alpha = 0.0
                }, completion: nil)
            
            self.trackingAreaLayoutHeightConstraint.constant = 0.0
            UIView.animateWithDuration(1, delay: 0, options: .CurveEaseInOut, animations: {
                self.trackingAreaContainerView.alpha = 0.0
                self.trackingAreaContainerView.layoutIfNeeded()
                }, completion: nil)

        }
    }
    
    func updateUI(){
        distanceLabel.text = String(format:"%0.2f km", (myRun.totalDistance))
        paceLabel.text = String(format:"%0.2f min/km", sessionPaces.last!)
        timeLabel.text = myRun.totalTimeTranslation()
        
        
        
        let distanceDiff = myRun.totalDistance - ghostRun.totalDistance
        let mapDistanceDiff = currentLocation.distanceFromLocation(ghostCurrentLocation)
        
        if(distanceDiff >= 0){
             distanceDiffLabel.textColor = .greenColor()
             distanceDiffLabel.text = String(format: "+ %0.2f m",mapDistanceDiff)
        } else {
            distanceDiffLabel.textColor = .redColor()
            distanceDiffLabel.text = String(format: "- %0.2f m",mapDistanceDiff)
        }
        
        
        
        timeDiffLabel.text = String(format: "%0.2f m",myRun.totalDistance)
    }
    
    
    func secondIncrement(){
        
        myRun.totalTime = (myRun.totalTime) + 1
        //update the UI so it reflects the useful information by the second
        updateUI()
        
    }
    
    func updateMyRun(){
        
        if ghostRun.realmTrackedLocations.last != nil {
            
            let distanceBetweenLastPointAndCurrentLocation = ghostCurrentLocation.distanceFromLocation(CLLocation(latitude: (ghostRun.realmTrackedLocations.last!.lat), longitude: (ghostRun.realmTrackedLocations.last?.lng)!))
            
            ghostRun.totalDistance += distanceBetweenLastPointAndCurrentLocation/1000
            
        }
        
        if myRun.realmTrackedLocations.last != nil {
            
            let distanceBetweenLastPointAndCurrentLocation = currentLocation.distanceFromLocation(CLLocation(latitude: (myRun.realmTrackedLocations.last!.lat), longitude: (myRun.realmTrackedLocations.last?.lng)!))
            
            myRun.totalDistance += distanceBetweenLastPointAndCurrentLocation/1000
            
        }
        //taking raw data from location manager and translating to useful information for the user
       // myRun?.totalDistance += currentLocation.speed/1000
        sessionPaces.append(1000/(currentLocation.speed*60))
        
        //add the next location
        let realmLocation = RealmCLLocation()
        realmLocation.speed = 1000/(currentLocation.speed*60)
        realmLocation.lat = currentLocation.coordinate.latitude
        realmLocation.lng = currentLocation.coordinate.longitude
        
        myRun.realmTrackedLocations.append(realmLocation)
        mapView.setCenterCoordinate(currentLocation.coordinate, animated:true)
        
        //ghost's run
        let ghostRealmLocation = RealmCLLocation()
        ghostRealmLocation.lat = ghostCurrentLocation.coordinate.latitude
        ghostRealmLocation.lng = ghostCurrentLocation.coordinate.longitude
        ghostRun.realmTrackedLocations.append(ghostRealmLocation)
        
        //draw the run path
        drawGhost()
        drawRun()
    }

    func drawRun(){
        var coordinates: [CLLocationCoordinate2D] = []
        
        for trackedLocation in (myRun.realmTrackedLocations) {
            let coordinate = CLLocationCoordinate2DMake(trackedLocation.lat, trackedLocation.lng)
            coordinates.append(coordinate)
        }
        let line = MGLPolyline(coordinates: &coordinates, count: UInt(coordinates.count))
        line.title = "userBreadCrumbs"
        mapView.addAnnotation(line)
    }
    
    func drawGhost(){
        var coordinates: [CLLocationCoordinate2D] = []
        
        for trackedLocation in (ghostRun.realmTrackedLocations) {
            let coordinate = CLLocationCoordinate2DMake(trackedLocation.lat, trackedLocation.lng)
            coordinates.append(coordinate)
        }
        
        let line = MGLPolyline(coordinates: &coordinates, count: UInt(coordinates.count))
        line.title = "ghostBreadCrumbs"
        mapView.addAnnotation(line)
        
//        if ghostAnnotation != nil{
//          mapView.removeAnnotation(ghostAnnotation)
//        
//        }
//        
//        ghostAnnotation = MGLPointAnnotation()
//        ghostAnnotation.coordinate = CLLocationCoordinate2DMake(ghostCurrentLocation.coordinate.latitude, ghostCurrentLocation.coordinate.longitude)
//            
//        mapView.addAnnotation(ghostAnnotation)
        
    }

    
    func drawTrack(){
        var coordinates: [CLLocationCoordinate2D] = []
        
        for trackedLocation in (track.realmTrackedLocations) {
            let coordinate = CLLocationCoordinate2DMake(trackedLocation.lat, trackedLocation.lng)
            coordinates.append(coordinate)
        }
        let line = MGLPolyline(coordinates: &coordinates, count: UInt(coordinates.count))
        line.title = "track"
        mapView.addAnnotation(line)
        
        
        let startIndicator = MGLPointAnnotation()
        startIndicator.coordinate = CLLocationCoordinate2DMake(track.realmTrackedLocations.first!.lat, track.realmTrackedLocations.first!.lng)
        startIndicator.title = String(format: "Start",track.realmTrackedLocations.first!.checkPoint)
        
        mapView.addAnnotation(startIndicator)
        
        mapView.tintColor = .orangeColor()
    }
    
    
    @IBAction func backButtonPressed(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func preRaceSetup(){
        
        self.mapView.showsUserLocation = true
        
        start = CLLocationCoordinate2DMake(track.realmTrackedLocations.first!.lat, track.realmTrackedLocations.first!.lng)
        
        end = CLLocationCoordinate2DMake(track.realmTrackedLocations.last!.lat, track.realmTrackedLocations.last!.lng)
        
        var coordinates: [CLLocationCoordinate2D] = []
        
        for trackedLocation in (track.realmTrackedLocations) {
            let coordinate = CLLocationCoordinate2DMake(trackedLocation.lat, trackedLocation.lng)
            coordinates.append(coordinate)
        }
        
        mapView.setVisibleCoordinates(&coordinates, count: UInt(coordinates.count), edgePadding: UIEdgeInsetsMake(60.0, 40.0, 70.0, 40.0), animated: true)
        
        drawTrack()
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

}
