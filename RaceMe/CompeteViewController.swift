//
//  CompeteViewController.swift
//  RaceMe
//
//  Created by Enoch Ng on 2016-06-15.
//  Copyright © 2016 Enoch Ng. All rights reserved.
//

import UIKit
import CoreLocation
import Parse
import Mapbox
import RealmSwift

class CompeteViewController: UIViewController, setAsCurrentViewControllerDelegate, UITableViewDelegate, UITableViewDataSource, MGLMapViewDelegate {
    
    var currentLocation : CLLocation!
    
    @IBOutlet weak var startRunLongOverlay: UIImageView!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var startRunButton: UIButton!
    
    @IBOutlet weak var promptLabel: UILabel!
    
    @IBOutlet weak var mapView: MGLMapView!
    
    var currentRun : Run?
    
    var areaLocation : String!
    
    var areaLocationFound = false
    
    var fetchedTranslatedRuns = [Run]()
    
    var fetchedTranslatedRunsID = Set<String>()
    
    
    override func viewDidLoad() {
        mapView.delegate = self
        tableView.delegate = self
        
    }
    
    override func viewDidAppear(animated: Bool) {
        
        if fetchedTranslatedRuns.count > 0 {
            startRunButton.alpha = 1.0
            startRunButton.userInteractionEnabled = true
            promptLabel.alpha = 0.0
        } else {
            startRunButton.userInteractionEnabled = false
            startRunButton.alpha = 0.4
            promptLabel.alpha = 1.0
        }
        
        if let annotations = mapView.annotations {
            mapView.removeAnnotations(annotations)
        }
        
        let indexPaths = tableView.indexPathsForVisibleRows
        
        
        if let index = indexPaths?.first?.row {
            
            currentRun = fetchedTranslatedRuns[index]
            
            if let cRun = currentRun {
                updateMap(cRun)
            }
        }
        
        tableView.reloadData()
    }
    
    func registerAsCurrentViewController(){
        if let areaLocate = self.areaLocation {
            fetchRunsWithAreaLocation(areaLocate)
        }
        tableView.flashScrollIndicators()
        
        print(fetchedTranslatedRuns)
        
    }
    
    @IBAction func startRunButtonPressed(sender: UIButton) {
        startRunLongOverlay.transform =  CGAffineTransformMakeScale(0.1,0.1)
        
        UIView.animateWithDuration(0.2, animations: {
            
            self.startRunLongOverlay.alpha = 0.4
            self.startRunLongOverlay.transform =  CGAffineTransformMakeScale(1,1)
            
            }, completion: { (finished: Bool) -> Void in
                
                UIView.animateWithDuration(0.4, animations: {
                    
                    self.startRunLongOverlay.alpha = 0.0
                    self.startRunLongOverlay.transform =  CGAffineTransformMakeScale(1,1)
                    
                    }, completion: { (finished: Bool) -> Void in
                        
                        self.performSegueWithIdentifier("competeToRunMode", sender: nil)
                        
                })
        })
        
        
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if (segue.identifier == "competeToRunMode") {
            
            if  let runModeViewController = segue.destinationViewController as? RunModeViewController {
                
                runModeViewController.userRun = Run()
                runModeViewController.userRun.isRace = true
                
                let parentViewController = self.parentViewController as? HomeViewController
                runModeViewController.user = Runner()
                runModeViewController.user.currentLocation = parentViewController?.currentLocation
                
                let myRealm = try! Realm()
                
                try! myRealm.write {
                    
                    let newTrack = Track()
                    
                    newTrack.trackLocation = currentRun!.areaLocation
                    newTrack.trackID = (currentRun?.trackID)!
                    newTrack.totalDistanceMetres = currentRun!.distanceRanInMetres
                    newTrack.dateCreated = NSDate()
                    
                    for trackPoint in (currentRun?.footPrints)!{
                        newTrack.trackPoints.append(trackPoint)
                    }
                    
                    myRealm.add(newTrack)
                    runModeViewController.track = newTrack
                }
                
                
                
            }
        }
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedTranslatedRuns.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell : RaceMeTableViewCell = (tableView.dequeueReusableCellWithIdentifier("raceMeTableViewCell", forIndexPath: indexPath) as? RaceMeTableViewCell)!
        
        let run = fetchedTranslatedRuns[indexPath.item]
        cell.locationLabel.text = run.areaLocation
        cell.distanceLabel.text = String(format:"%0.2f", (run.distanceRanInKilometres()))
        cell.distanceLabel.textColor = colorOfCorrespondingDistance(run.distanceRanInMetres)
        cell.kmLabel.textColor = colorOfCorrespondingDistance(run.distanceRanInMetres)
        
        cell.bestTimeLabel.text = run.formattedTime()
        
        return cell
        
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        let indexPaths = tableView.indexPathsForVisibleRows
        
        let index = indexPaths!.first!.row
        
        //scrollView.contentOffset
        
        if currentRun != fetchedTranslatedRuns[index] {
            if let annotations = mapView.annotations {
                mapView.removeAnnotations(annotations)
            }
            currentRun = fetchedTranslatedRuns[index]
            updateMap(currentRun!)
            
        }
    }
    
    
    func getAreaLocation(currentLocation : CLLocation){
        if !areaLocationFound {
            CLGeocoder().reverseGeocodeLocation(currentLocation, completionHandler: {(placemarks, error) -> Void in
                if error != nil {
                    print("Reverse geocoder failed with error" + error!.localizedDescription)
                    return
                }
                if placemarks?.count > 0 {
                    let pm = placemarks![0]
                    self.areaLocation = pm.locality
                    self.fetchRunsWithAreaLocation(self.areaLocation)
                    
                }
                else {
                    print("Problem with the data received from geocoder")
                }
            })
        }
    }
    
    func fetchRunsWithAreaLocation(receivedAreaLocation: String){
        
        let query = PFQuery(className:"RunParse")
        
        query.whereKey("areaLocation", equalTo: receivedAreaLocation)
        
        query.findObjectsInBackgroundWithBlock {
            
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                // The find succeeded.
                print("Successfully retrieved \(objects!.count) run.")
                // Do something with the found objects
                self.areaLocationFound = true
                
                if let runsParse = objects {
                    for run in runsParse {
                        
                        if let retrievedRun = run as? RunParse {
                            
                            
                            let competeRun = Run()
                            
                            competeRun.runID = retrievedRun.runID
                            competeRun.trackID = retrievedRun.trackID
                            competeRun.dateRan = retrievedRun.dateRan
                            competeRun.areaLocation = retrievedRun.areaLocation
                            competeRun.creator = retrievedRun.creator
                            competeRun.totalTimeSeconds = retrievedRun.totalTimeSeconds
                            competeRun.distanceRanInMetres = retrievedRun.distanceRanInMetres
                            
                            let query = PFQuery(className: "TrackPointParse")
                            
                            query.whereKey("runID", equalTo: competeRun.runID)
                            
                            query.findObjectsInBackgroundWithBlock {
                                
                                
                                (objects: [PFObject]?, error: NSError?) -> Void in
                                
                                if error == nil {
                                    // The find succeeded.
                                    print("Successfully retrieved \(objects!.count) trackPoints.")
                                    
                                    if let trackPointsParse = objects {
                                        
                                        var unsortedTrackPoints = [TrackPoint]()
                                        
                                        for trackPoint in trackPointsParse {
                                            
                                            if let retrievedTrackPoint = trackPoint as? TrackPointParse {
                                                
                                                let competeTrackPoint = TrackPoint()
                                                
                                                competeTrackPoint.runID = retrievedTrackPoint.runID
                                                competeTrackPoint.timeStamp = retrievedTrackPoint.timeStamp
                                                competeTrackPoint.altitude = retrievedTrackPoint.altitude
                                                competeTrackPoint.latitude = retrievedTrackPoint.latitude
                                                competeTrackPoint.longitude = retrievedTrackPoint.longitude
                                                competeTrackPoint.checkPoint = retrievedTrackPoint.checkPoint
                                                competeTrackPoint.speed = retrievedTrackPoint.speed
                                                competeTrackPoint.index = retrievedTrackPoint.index
                                                
                                                unsortedTrackPoints.append(competeTrackPoint)
                                                
                                            }
                                        }
                                        
                                        
                                        if unsortedTrackPoints.count > 0 {
                                            
                                            let indexSortDescriptor = NSSortDescriptor(key: "index", ascending: true)
                                            
                                            if  let sortedTrackPoints = (unsortedTrackPoints as NSArray).sortedArrayUsingDescriptors([indexSortDescriptor]) as? [TrackPoint]{
                                                
                                                
                                                for sortedTrackPoint in sortedTrackPoints {
                                                    competeRun.footPrints.append(sortedTrackPoint)
                                                }
                                            }
                                            
                                            
                                        }
                                        
                                        
                                        if !(self.fetchedTranslatedRunsID.contains(competeRun.runID)) {
                                            self.fetchedTranslatedRuns.append(competeRun)
                                            self.fetchedTranslatedRunsID.insert(competeRun.runID)
                                        }
                                        print(self.fetchedTranslatedRuns.count)
                                        
                                        if self.fetchedTranslatedRuns.count > 0 {
                                            self.startRunButton.alpha = 1.0
                                            self.startRunButton.userInteractionEnabled = true
                                            self.promptLabel.alpha = 0.0
                                        } else {
                                            self.startRunButton.userInteractionEnabled = false
                                            self.startRunButton.alpha = 0.4
                                            self.promptLabel.alpha = 1.0
                                        }
                                        
                                        
                                        if let firstFetchedRun = self.fetchedTranslatedRuns.first {
                                            self.currentRun = firstFetchedRun
                                            self.updateMap(firstFetchedRun)
                                        }
                                        self.tableView.reloadData()
                                        
                                    }
                                    
                                    
                                } else {
                                    // Log details of the failure
                                    print("Error: \(error!) \(error!.userInfo)")
                                }
                                
                                
                                
                            }
                            
                        }
                        
                    }
                }
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
    }
    
    func updateMap(run: Run){
        
        var coordinates: [CLLocationCoordinate2D] = []
        
        for trackPoint in run.footPrints {
            
            coordinates.append(trackPoint.trackPointToCLLocationCoordinate2D())
            
        }
        
        
        
        let line = MGLPolyline(coordinates: &coordinates, count: UInt(coordinates.count))
        mapView.addAnnotation(line)
        
        coordinates.append((mapView.userLocation?.coordinate)!)
        mapView.setVisibleCoordinates(&coordinates, count: UInt(coordinates.count), edgePadding: UIEdgeInsetsMake(60.0, 40.0, 70.0, 40.0), animated: true)
        
        
        let startPointIndicator = MGLPointAnnotation()
        startPointIndicator.coordinate = (run.footPrints.first?.trackPointToCLLocationCoordinate2D())!
        startPointIndicator.title = "Starting Point"
        mapView.addAnnotation(startPointIndicator)
        
        let endPointIndicator = MGLPointAnnotation()
        endPointIndicator.coordinate = (run.footPrints.last?.trackPointToCLLocationCoordinate2D())!
        endPointIndicator.title = "Ending Point"
        mapView.addAnnotation(endPointIndicator)
        
    }
    
    
    func mapView(mapView: MGLMapView, imageForAnnotation annotation: MGLAnnotation) -> MGLAnnotationImage? {
        // Try to reuse the existing ‘pisa’ annotation image, if it exists
        var checkPointAnnotationImage = mapView.dequeueReusableAnnotationImageWithIdentifier("checkPoint")
        var endPointAnnotationImage = mapView.dequeueReusableAnnotationImageWithIdentifier("endPoint")
        
        checkPointAnnotationImage = MGLAnnotationImage(image: UIImage(named: "MapViewCheckPointOrange")!, reuseIdentifier: "checkPoint")
        endPointAnnotationImage = MGLAnnotationImage(image: UIImage(named: "MapViewFinishFlag")!, reuseIdentifier: "endPoint")
        
        if let annotationPoint = annotation as? MGLPointAnnotation{
            
            if annotationPoint.title == "Ending Point" {
                
                return endPointAnnotationImage
            }
        }
        return checkPointAnnotationImage
    }
    
    func mapView(mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }
    
    func mapView(mapView: MGLMapView, strokeColorForShapeAnnotation annotation: MGLShape) -> UIColor {
        // Give our polyline a unique color by checking for its `title` property
        if let cRun = currentRun {
            return colorOfCorrespondingDistance(cRun.distanceRanInMetres)
        }
            
        else {
            return UIColor.clearColor()
        }
    }
    
    func colorOfCorrespondingDistance(distanceInMetres : Double) -> UIColor {
        
        if (distanceInMetres >= 10000){
            
            return UIColor.raceMeRedColor()
            
        } else if (distanceInMetres >= 5000){
            
            return UIColor.raceMeNeonGreenColor()
            
        } else {
            
            return UIColor.raceMeTextBlueColor()
        }
        
    }
}
