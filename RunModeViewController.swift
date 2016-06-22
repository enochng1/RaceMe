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

class RunModeViewController: UIViewController,  MGLMapViewDelegate, LocationManagerDelegate, setAsCurrentViewControllerDelegate {
    
    //UI
    @IBOutlet weak var mapView: MGLMapView!
    
    @IBOutlet weak var paceLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var trackLocationLabel: UILabel!
    @IBOutlet weak var proximityLabel: UILabel!
    @IBOutlet weak var promptProceedLabel: UILabel!
    
    @IBOutlet weak var distanceDiffLabel: UILabel!
    @IBOutlet weak var timeDiffLabel: UILabel!
    @IBOutlet weak var paceHeaderLabel: UILabel!
    @IBOutlet weak var startRunButton: UIButton!
    @IBOutlet weak var clearSaveButtonContainer: UIView!
    @IBOutlet weak var finishRunButton: UIButton!
    //model
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var saveButtonOverlay: UIImageView!
    @IBOutlet weak var clearButtonOverlay: UIImageView!
    @IBOutlet weak var longButtonOverlay: UIImageView!
    
    var locationManager = LocationManager.sharedInstance
    
    //track setup
    lazy var track = Track()
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
    lazy var ghostAnnotation = MGLPointAnnotation()
    
    //race variables
    var raceStarted = false
    
    
    // MARK: - View Controller Setup -
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        locationManager.LMDelegate = self
        
        //from NewRun
        if(runTracking){
            
            if !mapViewHasSetUp {
                setUpMapView()
                centerUser()
                mapViewHasSetUp = true
            }
            setUpRun()
            startTrackingRun(UIButton())
        }
        
        if(userRun.isRace){
            //showTrack on Map First
            showTrack(track)
            if let firstRunOfTrack = track.runs.first {
            drawTrackCheckPointsFor(firstRunOfTrack)
                
            }
        }
    }
    
    func registerAsCurrentViewController(){
        locationManager.LMDelegate = self
    }
    
    
    //MARK: - MapView Updates -
    
    func setUpMapView(){
        
        if let userCurrentLocation = user.currentLocation {
            CLGeocoder().reverseGeocodeLocation(userCurrentLocation, completionHandler: {(placemarks, error) -> Void in
                if error != nil {
                    print("Reverse geocoder failed with error" + error!.localizedDescription)
                    return
                }
                if placemarks?.count > 0 {
                    let pm = placemarks![0]
                    self.trackLocationLabel.text = pm.locality
                    
                }
                else {
                    print("Problem with the data received from geocoder")
                }
            })
        }
        //setup zoomLevel
        self.mapView.showsUserLocation = true
        self.mapView.zoomLevel = 17
    }
    
    func showTrack(track: Track){
        
        var coordinates: [CLLocationCoordinate2D] = []
        
        for trackPoint in track.trackPoints {
            
            coordinates.append(trackPoint.trackPointToCLLocationCoordinate2D())
            
        }
        
        let line = MGLPolyline(coordinates: &coordinates, count: UInt(coordinates.count))
        line.title = "track"
        mapView.addAnnotation(line)
        
        mapView.setVisibleCoordinates(&coordinates, count: UInt(coordinates.count), edgePadding: UIEdgeInsetsMake(60.0, 40.0, 70.0, 40.0), animated: true)
        
        let startPointIndicator = MGLPointAnnotation()
        startPointIndicator.coordinate = (track.trackPoints.first?.trackPointToCLLocationCoordinate2D())!
        startPointIndicator.title = "Starting Point"
        mapView.addAnnotation(startPointIndicator)
        
        let endPointIndicator = MGLPointAnnotation()
        endPointIndicator.coordinate = (track.trackPoints.last?.trackPointToCLLocationCoordinate2D())!
        endPointIndicator.title = "Ending Point"
        mapView.addAnnotation(endPointIndicator)
        
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
    
    func drawRunFor(aRun: Run){
        
        var coordinates: [CLLocationCoordinate2D] = []
        
        if(aRun.footPrints.count >= 2){
            let trackPointSecondLast = aRun.footPrints[aRun.footPrints.count - 2]
            let trackPointLast = aRun.footPrints.last
            
            coordinates.append(trackPointSecondLast.trackPointToCLLocationCoordinate2D())
            coordinates.append(trackPointLast!.trackPointToCLLocationCoordinate2D())
            
            let line = MGLPolyline(coordinates: &coordinates, count: UInt(coordinates.count))
            
            if(aRun == userRun){
                line.title = "userBreadCrumbs"
            } else if (aRun == ghostRun){
                line.title = "ghostBreadCrumbs"
            }
            
            mapView.addAnnotation(line)
        }
    }
    
    func drawCheckPointsFor(aRun : Run){
        
        if aRun.footPrints.count > 0 {
            if(aRun.footPrints.last?.checkPoint > 0){
                
                let checkPoint = aRun.footPrints.last?.trackPointToCLLocationCoordinate2D()
                
                let checkPointIndicator = MGLPointAnnotation()
                checkPointIndicator.coordinate = checkPoint!
                checkPointIndicator.title = String(format: "%i km",(aRun.footPrints.last?.checkPoint)!)
                mapView.addAnnotation(checkPointIndicator)
            }
        }
    }
    
    func drawTrackCheckPointsFor(aRun: Run){
        
        if aRun.footPrints.count > 0 {
            
            for footPrint in aRun.footPrints {
                if footPrint.checkPoint > 0 {
                    let checkPoint = footPrint.trackPointToCLLocationCoordinate2D()
                    
                    let checkPointIndicator = MGLPointAnnotation()
                    checkPointIndicator.coordinate = checkPoint
                    checkPointIndicator.title = String(format: "%i km",(footPrint.checkPoint))
                    mapView.addAnnotation(checkPointIndicator)
                }
            }
        }
    }
    
    func mapView(mapView: MGLMapView, imageForAnnotation annotation: MGLAnnotation) -> MGLAnnotationImage? {
        // Try to reuse the existing ‘pisa’ annotation image, if it exists
        var checkPointAnnotationImage = mapView.dequeueReusableAnnotationImageWithIdentifier("checkPoint")
        var endPointAnnotationImage = mapView.dequeueReusableAnnotationImageWithIdentifier("endPoint")
        var ghostAnnotationImage = mapView.dequeueReusableAnnotationImageWithIdentifier("ghostAnnotation")
        
        checkPointAnnotationImage = MGLAnnotationImage(image: UIImage(named: "MapViewCheckPointOrange")!, reuseIdentifier: "checkPoint")
        endPointAnnotationImage = MGLAnnotationImage(image: UIImage(named: "MapViewFinishFlag")!, reuseIdentifier: "endPoint")
        ghostAnnotationImage = MGLAnnotationImage(image: UIImage(named: "GhostAnnotation")!, reuseIdentifier: "ghostAnnotation")
        
        if let annotationPoint = annotation as? MGLPointAnnotation{
            
            if annotationPoint.title == "Ending Point" {
                return endPointAnnotationImage
            } else if annotationPoint.title == "Ghost" {
                return ghostAnnotationImage
            }
            
            
        }
        return checkPointAnnotationImage
    }
    
    //MARK: - Runner Location Logic & Conditionals -
    
    func updatedLocation(currentLocation: CLLocation){
        
        user.currentLocation = currentLocation
        
        //setup mapView only runs once
        if(!userRun.isRace){
            if !mapViewHasSetUp {
                setUpMapView()
                centerUser()
                mapViewHasSetUp = true
            }
        } else {
            if !mapViewHasSetUp {
                
                NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: #selector(setUpMapView), userInfo: nil, repeats: false)
                NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: #selector(centerUser), userInfo: nil, repeats: false)
                mapViewHasSetUp = true
            }
        }
        
        
        if(!raceStarted && userRun.isRace){
            detectStartProximity()
        }
        
        if(runTracking){
            if(userRun.isRace){
                
                if ghost.ghostStepsCounter < track.trackPoints.count {
                    let ghostNewLocation = track.trackPoints[ghost.ghostStepsCounter]
                    
                    ghost.currentLocation = ghostNewLocation.trackPointToCLLocation()
                    
                    updateGhostAnnotation(ghost)
                    
                    ghost.ghostStepsCounter += 1
                }
                
                updateRunFor(ghost, aRun: ghostRun)
                drawRunFor(ghostRun)
                
                detectEndProximity()
                
            } else {
                drawCheckPointsFor(userRun)
            }
            
            //updateRun, drawRun
            updateRunFor(user, aRun: userRun)
            drawRunFor(userRun)
        }
    }

    func setUpRun(){
        //creat a new run object, set a new timer
        //userRun = Run()
        userRun.dateRan = NSDate()
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(secondIncrement), userInfo: nil, repeats: true)
        
        //because this is a run, set tint to only orange
        mapView.tintColor = UIColor.raceMeOrangeColor()
        
        //append current point as starting point
        let newStartPoint = TrackPoint()
        newStartPoint.altitude = user.currentLocation!.altitude
        newStartPoint.latitude = user.currentLocation!.coordinate.latitude
        newStartPoint.longitude = user.currentLocation!.coordinate.longitude
        userRun.footPrints.append(newStartPoint)
        
        //annotate the start Point
        annotateStartPoint()
        
        //declare the first checkPoint counter for the next kilometre
        checkPointTracker = 1
    }
    
    func setUpRace(){
        userRun.dateRan = NSDate()
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(secondIncrement), userInfo: nil, repeats: true)
        
        mapView.tintColor = UIColor.raceMeOrangeColor()
        
        //append current point as starting point
        let newStartPoint = TrackPoint()
        newStartPoint.altitude = user.currentLocation!.altitude
        newStartPoint.latitude = user.currentLocation!.coordinate.latitude
        newStartPoint.longitude = user.currentLocation!.coordinate.longitude
        userRun.footPrints.append(newStartPoint)
        
        //declare the first checkPoint counter for the next kilometre
        checkPointTracker = 1
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
        
        if(aRun.distanceRanInKilometres() > Double(checkPointTracker)){
            newTrackPoint.checkPoint = checkPointTracker
            checkPointTracker = checkPointTracker + 1
        }
        
        aRun.footPrints.append(newTrackPoint)
    }

    
    func detectStartProximity(){
        
        let distanceToStartPoint = user.currentLocation?.distanceFromLocation((track.trackPoints.first?.trackPointToCLLocation())!)
        proximityLabel.text = String(format: "You are %0.0f metres away", distanceToStartPoint!)
        
        if(distanceToStartPoint > 15){
            
            mapView.tintColor = UIColor.raceMeMutedGreyColor()
            fadeOutView(startRunButton)
            fadeInView(proximityLabel)
            
            if(promptProceedLabel.alpha == 0.0){
                fadeInView(promptProceedLabel)
            } else if (promptProceedLabel.alpha == 1.0){
                fadeOutView(promptProceedLabel)
            }
            
        } else {
            
            mapView.tintColor = UIColor.raceMeTextBlueColor()
            fadeOutView(proximityLabel)
            fadeOutView(promptProceedLabel)
            fadeInView(startRunButton)
        }
    }
    
    func detectEndProximity(){
        
        let distanceToStartPoint = user.currentLocation?.distanceFromLocation((track.trackPoints.last?.trackPointToCLLocation())!)
        
        if(distanceToStartPoint < 5){
            print("runEnded")
            finishRunButtonPressed(UIButton())
            userRun.finishedRace = true
        }
    }
    
    func secondIncrement(){
        userRun.totalTimeSeconds = userRun.totalTimeSeconds + 1
        //update the UI so it reflects the useful information by the second
        updateUI()
    }
    
    func checkToSeeIfLocationsFetchingInBackground(){
        if UIApplication.sharedApplication().applicationState == .Active {
            print(user.currentLocation!.coordinate)
        } else {
            print(user.currentLocation!.coordinate)
        }
    }
    
    //MARK: - UI Updates + Methods + Animations -
    
    func updateGhostAnnotation(aGhost: Runner){
        
        mapView.removeAnnotation(ghostAnnotation)
        
        ghostAnnotation.coordinate = (aGhost.currentLocation?.coordinate)!
        ghostAnnotation.title = "Ghost"
        mapView.addAnnotation(ghostAnnotation)
        
    }
    
    func annotateStartPoint(){
        let startPointIndicator = MGLPointAnnotation()
        startPointIndicator.coordinate = user.currentLocation!.coordinate
        startPointIndicator.title = "Starting Point"
        mapView.addAnnotation(startPointIndicator)
    }
    
    func annotateEndPoint(){
        let endPointIndicator = MGLPointAnnotation()
        endPointIndicator.coordinate = user.currentLocation!.coordinate
        endPointIndicator.title = "Ending Point"
        mapView.addAnnotation(endPointIndicator)
    }

    func updateUI(){
        
        distanceLabel.text = userRun.distanceRanInKilometresToString()
        paceLabel.text = user.paceToString()
        timeLabel.text = userRun.formattedTime()
        
        if userRun.isRace {
            
        }
    }
    
    func fadeOutView(view: UIView){
        
        UIView.animateWithDuration(0.75, delay: 0, options: .CurveEaseInOut, animations: {
            view.alpha = 0.0
            }, completion: nil)
    }
    
    func fadeInView(view : UIView){
        
        UIView.animateWithDuration(0.75, delay: 0.5, options: .CurveEaseInOut, animations: {
            view.alpha = 1.0
            }, completion: nil)
    }
    
    func overlayAnimation(view : UIView){
        
        view.transform =  CGAffineTransformMakeScale(0.1,0.1)
        
        UIView.animateWithDuration(0.15, animations: {
            
            view.alpha = 0.4
            view.transform =  CGAffineTransformMakeScale(1,1)
            
            }, completion: { (finished: Bool) -> Void in
                
                UIView.animateWithDuration(0.1, animations: {
                    
                    view.alpha = 0.0
                    view.transform =  CGAffineTransformMakeScale(1,1)
                    
                    }, completion: { (finished: Bool) -> Void in
                        
                })
        })
        
    }

    // MARK: - User Interaction Button Press -
    
    @IBAction func startTrackingRun(sender: UIButton) {
        
        if !runTracking {
            
            if(userRun.isRace){
               
                setUpRace()
                raceStarted = true
                
            } else {
                setUpRun()
            }
            runTracking = true
        }
        
        //
        longButtonOverlay.image = UIImage(named: "StartRunLongOverlay")
        overlayAnimation(longButtonOverlay)
        fadeOutView(startRunButton)
        fadeInView(finishRunButton)
        
    }
    
    @IBAction func finishRunButtonPressed(sender: UIButton) {
        
        //stop tracking user
        runTracking = false
        updateUI()
        //stop timer
        timer.invalidate()
        
        mapView.tintColor = UIColor.raceMeTextBlueColor()
        paceLabel.text = userRun.averagePaceToString()
        paceHeaderLabel.text = "Avg. Pace"
        
        //update UI to reflect the whole course
        if !userRun.isRace {
        annotateEndPoint()
        //userRun.finishedRace = true
        }
        
        endRunUpdateMapViewWith(userRun)
        
        //update UI to show clear buttons and save
        saveButton.userInteractionEnabled = true
        saveButton.alpha = 1.0
        
        longButtonOverlay.image = UIImage(named: "FinishRunOverlay")
        overlayAnimation(longButtonOverlay)
        fadeOutView(finishRunButton)
        fadeInView(clearSaveButtonContainer)
    }
    
    @IBAction func clearButtonPressed(sender: UIButton) {
        //remove annotations
        if(userRun.isRace){
            
            for annote in mapView.annotations! {
                
                if let lineAnnote = annote as? MGLPolyline {
                    if lineAnnote.title == "userBreadCrumbs" || lineAnnote.title == "ghostBreadCrumbs"{
                        mapView.removeAnnotation(lineAnnote)
                    }
                }
                
                if let pointAnnote = annote as? MGLPointAnnotation {
                    if pointAnnote.title == "Ghost" {
                        mapView.removeAnnotation(pointAnnote)
                    }
                }
            }

        } else {

           self.mapView.removeAnnotations(self.mapView.annotations!)

        }
        
        let isRaceContainer = userRun.isRace
        
        userRun = Run()
        userRun.isRace = isRaceContainer
        raceStarted = false
        
        user = Runner()
        
        //reset UI
        distanceLabel.text = "0.00 km"
        paceLabel.text = "0:00"
        timeLabel.text = "00:00:00"
        paceHeaderLabel.text = "Pace"
        
        //reset button UI
        overlayAnimation(clearButtonOverlay)
        fadeOutView(clearSaveButtonContainer)
        fadeInView(startRunButton)
    }
    
    @IBAction func saveButtonPressed(sender: UIButton) {
        saveRunToRealm()
        overlayAnimation(saveButtonOverlay)
        saveButton.alpha = 0.5
        saveButton.userInteractionEnabled = false
    }
    
    @IBAction func pinpointButtonPressed(sender: UIButton) {
        centerUser()
    }
    
    func centerUser(){
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
            return 6.0
        }
        else if (annotation.title == "ghostBreadCrumbs") {
            
            return 4.0
            
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
            
            return UIColor.raceMeRedColor()
            
        } else if (annotation.title == "userBreadCrumbs" && annotation is MGLPolyline) {
            
                return UIColor.raceMeOrangeColor()
            
        }
            return UIColor.raceMeOrangeColor()
    }
    
    func saveRunToRealm(){
        
        let myRealm = try! Realm()
        //write to Realm
        if(userRun.isRace){
            
            try! myRealm.write {
                track.runs.append(userRun)
            }
    
        print(track.runs.count)
            
        } else {
            
            let newTrack = Track()
            
            newTrack.trackLocation = userRun.areaLocation
            
            newTrack.totalDistanceMetres = userRun.distanceRanInMetres
            
            for trackPoint in userRun.footPrints{
                newTrack.trackPoints.append(trackPoint)
            }
            
            newTrack.runs.append(userRun)
 
            try! myRealm.write {
                myRealm.add(newTrack)
            }
        
        }
        
    }

    
    @IBAction func backButtonPressed(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
        finishRunButtonPressed(UIButton())
        clearButtonPressed(UIButton())
        
    }
    
    
}

