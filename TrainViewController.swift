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
import QuartzCore

class TrainViewController: UIViewController,  MGLMapViewDelegate, LocationManagerDelegate, setAsCurrentViewControllerDelegate{
    
    @IBOutlet weak var mapView: MGLMapView!
    
    var didSetup:Bool = false
    var tracking:Bool = false
    
    @IBOutlet weak var paceLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    @IBOutlet weak var trackingAreaHeightConstant: NSLayoutConstraint!
    @IBOutlet weak var trackingAreaLabel: UILabel!
    @IBOutlet weak var trackingAreaContainerView: UIView!
    @IBOutlet weak var pinpointLocationButton: UIButton!
    
    var currentLocation : CLLocation!
    var trackStartingArea : String?
    var checkPointTracker = 1.0
    
    var sessionRun : Run?
    lazy var sessionPaces = [Double]()
    lazy var timer = NSTimer()
    
    var locationManager = LocationManager.sharedInstance
    
    let uiRealm = try! Realm()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self

        locationManager.LMDelegate = self
    }
    
    
    func registerAsCurrentViewController(){
    locationManager.LMDelegate = self
    }
    
    func updatedLocation(currentLocation: CLLocation) {

        self.currentLocation = currentLocation
        
        if(tracking){
            updateRun()
        } else {
            
            if(!didSetup){
                preTrackSetup()
                didSetup = true
            }
        }
    }
    
    
    func preTrackSetup(){
        
        CLGeocoder().reverseGeocodeLocation(self.currentLocation, completionHandler: {(placemarks, error) -> Void in
            if error != nil {
                print("Reverse geocoder failed with error" + error!.localizedDescription)
                return
            }
            if placemarks?.count > 0 {
                let pm = placemarks![0]
                self.trackStartingArea = pm.locality
                self.trackingAreaLabel.text = "Track Location: "+self.trackStartingArea!
                self.mapView.setCenterCoordinate(self.currentLocation.coordinate, animated:true)
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
    
    @IBAction func startTracking(sender: UIButton) {
        
        if(tracking){
            tracking = false
            updateUI()
            endRun()
            
        } else {
            tracking = true
            setUpRun()
        }
    }
    
    func saveRunToRealm(){
        //write to Realm
        try! uiRealm.write { () -> Void in
            uiRealm.add(sessionRun!)
        }
    }
    
    func setUpRun(){
        //setup run object to prepare for location updates
        sessionRun = Run()
        sessionRun?.dateRan = NSDate()
        sessionRun?.areaLocation = trackStartingArea
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(secondIncrement), userInfo: nil, repeats: true)
        
        //setup trackPointChecker
        checkPointTracker = 1.0
        
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
        
        if sessionRun?.realmTrackedLocations.last != nil {
            
          let distanceBetweenLastPointAndCurrentLocation = currentLocation.distanceFromLocation(CLLocation(latitude: (sessionRun?.realmTrackedLocations.last!.lat)!, longitude: (sessionRun?.realmTrackedLocations.last?.lng)!))
            
            sessionRun?.totalDistance += distanceBetweenLastPointAndCurrentLocation/1000
            
        }
    
        //taking raw data from location manager and translating to useful information for the user
        //sessionRun?.totalDistance += currentLocation.speed/1000
        sessionPaces.append(1000/(currentLocation.speed*60))
        
        //add the next location
        let realmLocation = RealmCLLocation()
        realmLocation.speed = 1000/(currentLocation.speed*60)
        realmLocation.lat = currentLocation.coordinate.latitude
        realmLocation.lng = currentLocation.coordinate.longitude
        
        if(sessionRun?.totalDistance > checkPointTracker){
            realmLocation.checkPoint = Int(checkPointTracker)
            print("checkpoint #"+String(format:"%0.0f",checkPointTracker))
            checkPointTracker = checkPointTracker + 1.0
        }
        
        
        sessionRun?.realmTrackedLocations.append(realmLocation)
        mapView.setCenterCoordinate(currentLocation.coordinate, animated:true)
        
        //draw the run path
        drawRun()
    
    }
    
    func endRun(){
        //stop timer
        timer.invalidate()
        checkPointTracker = 0.0
        
        //calculate average page
        //**
//        sessionRun?.totalAveragePace =
        
            
        sessionRun?.generateTrackName()
        
        //end Run UIupdates
        mapView.tintColor = UIColor(red: 0.0, green: 0.817, blue: 0.714, alpha: 1.0)
        
        //centered on track
        var coordinates: [CLLocationCoordinate2D] = []
        for trackedLocation in (sessionRun?.realmTrackedLocations)! {
            let coordinate = CLLocationCoordinate2DMake(trackedLocation.lat, trackedLocation.lng)
            coordinates.append(coordinate)
        }
        mapView.setVisibleCoordinates(&coordinates, count: UInt(coordinates.count), edgePadding: UIEdgeInsetsMake(60.0, 40.0, 70.0, 40.0), animated: true)
        
        var checkPoints: [CLLocationCoordinate2D] = []
        for trackedLocation in (sessionRun?.realmTrackedLocations)! {
            if(trackedLocation.checkPoint > 0){
                let checkPoint = CLLocationCoordinate2DMake(trackedLocation.lat, trackedLocation.lng)
                checkPoints.append(checkPoint)
                
                let checkPointIndicator = MGLPointAnnotation()
                checkPointIndicator.coordinate = checkPoint
                checkPointIndicator.title = String(format: "%i km",trackedLocation.checkPoint)
                mapView.addAnnotation(checkPointIndicator)
            }
        }
        
        self.trackingAreaLabel.text = sessionRun?.trackName
        
        UIView.animateWithDuration(0.5, delay: 0, options: .CurveEaseInOut, animations: {
            self.trackingAreaLabel.alpha = 1.0
            }, completion: nil)
        
        self.trackingAreaHeightConstant.constant = 30.0
        UIView.animateWithDuration(1, delay: 0, options: .CurveEaseInOut, animations: {
            self.trackingAreaContainerView.alpha = 1.0
            self.trackingAreaContainerView.layoutIfNeeded()
            self.pinpointLocationButton.alpha = 0.8
            }, completion: nil)
    }

    @IBAction func pinpointButtonPressed(sender: UIButton) {
        if(self.currentLocation != nil){
             mapView.setCenterCoordinate(currentLocation.coordinate, animated:true)
        }
    }

    func drawRun(){
        var coordinates: [CLLocationCoordinate2D] = []
        
        for trackedLocation in (sessionRun?.realmTrackedLocations)! {
            let coordinate = CLLocationCoordinate2DMake(trackedLocation.lat, trackedLocation.lng)
            coordinates.append(coordinate)
        }
        let line = MGLPolyline(coordinates: &coordinates, count: UInt(coordinates.count))
        mapView.addAnnotation(line)
    }

    func checkToSeeIfLocationsFetchingInBackground(){
                if UIApplication.sharedApplication().applicationState == .Active {
                     print(currentLocation.coordinate)
                } else {
                     print(currentLocation.coordinate)
                }
    }

    func mapView(mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }

    func saveTrackAsBitmap(){
        //Get the size of the screen
        let screenRect = UIScreen.mainScreen().bounds
        
        //Create a bitmap-based graphics context and make 
        //it the current context passing in the screen size 
        UIGraphicsBeginImageContext(screenRect.size);
        
        let ctx = UIGraphicsGetCurrentContext();
        CGContextFillRect(ctx, screenRect);
        
        //render the receiver and its sublayers into the specified context 
        //choose a view or use the window to get a screenshot of the 
        //entire device
        view.layer.renderInContext(ctx!)
        let newImage = UIGraphicsGetImageFromCurrentImageContext();
        //End the bitmap-based graphics context 
        UIGraphicsEndImageContext();
        //Save UIImage to camera roll 
        UIImageWriteToSavedPhotosAlbum(newImage, nil, nil, nil);
    }
    
    @IBAction func saveRun(sender: UIButton) {
        
        if(!tracking){
            saveRunToRealm()
        }
        
    }
}
