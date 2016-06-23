//
//  RaceMeViewController.swift
//  RaceMe
//
//  Created by Enoch Ng on 2016-06-19.
//  Copyright © 2016 Enoch Ng. All rights reserved.
//

import UIKit
import Mapbox
import CoreLocation
import RealmSwift

class RaceMeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, setAsCurrentViewControllerDelegate, MGLMapViewDelegate  {
    
    @IBOutlet weak var startRunButton: UIButton!
    @IBOutlet weak var mapView: MGLMapView!
    
    @IBOutlet weak var promptLabel: UILabel!
    
    @IBOutlet weak var startRunLongOverlay: UIImageView!
    
    @IBOutlet weak var tableView: UITableView!
    
    let myRealm = try! Realm()
    
    var allTracks : Results<Track>!
    
    var currentTrack = Track()
    
    override func viewDidLoad() {
        
        mapView.delegate = self
        
       allTracks = myRealm.objects(Track.self)
        
        if let firstTrack = allTracks?.first {
            currentTrack = firstTrack
            updateMap(firstTrack)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        
        if allTracks.count > 0 {
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
        
            currentTrack = (allTracks?[index])!
            updateMap(currentTrack)
        }
        
        tableView.reloadData()
    }
    
    func registerAsCurrentViewController(){
        
         tableView.flashScrollIndicators()
        
        if let annotations = mapView.annotations {
            mapView.removeAnnotations(annotations)
        }
        
        let indexPaths = tableView.indexPathsForVisibleRows
        
        if let index = indexPaths?.first?.row {
            
            currentTrack = (allTracks?[index])!
            updateMap(currentTrack)
        }
        
        
        tableView.reloadData()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allTracks.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
       
        let cell : RaceMeTableViewCell = (tableView.dequeueReusableCellWithIdentifier("raceMeTableViewCell", forIndexPath: indexPath) as? RaceMeTableViewCell)!

        let track = allTracks?[indexPath.item]
        cell.locationLabel.text = track?.trackLocation
        cell.distanceLabel.text = String(format:"%0.2f", (track?.totalDistanceKilometres())!)
        cell.distanceLabel.textColor = colorOfCorrespondingDistance((track?.totalDistanceMetres)!)
        cell.kmLabel.textColor = colorOfCorrespondingDistance((track?.totalDistanceMetres)!)
        
        cell.bestTimeLabel.text = track?.fastestRecord().formattedTime()
        
        return cell
        
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        //let cell = tableView.visibleCells.first as? RaceMeTableViewCell
        
        let indexPaths = tableView.indexPathsForVisibleRows
    
        let index = indexPaths!.first!.row
        
        //scrollView.contentOffset
        
        if currentTrack != (allTracks?[index])! {
            if let annotations = mapView.annotations {
                mapView.removeAnnotations(annotations)
            }
            currentTrack = (allTracks?[index])!
            updateMap(currentTrack)
            
        }
    }
    

    @IBAction func startRaceButtonPressed(sender: UIButton) {
        
        
        startRunLongOverlay.transform =  CGAffineTransformMakeScale(0.1,0.1)
        
        UIView.animateWithDuration(0.2, animations: {
            
            self.startRunLongOverlay.alpha = 0.4
            self.startRunLongOverlay.transform =  CGAffineTransformMakeScale(1,1)
            
            }, completion: { (finished: Bool) -> Void in
                
                UIView.animateWithDuration(0.4, animations: {
                    
                    self.startRunLongOverlay.alpha = 0.0
                   self.startRunLongOverlay.transform =  CGAffineTransformMakeScale(1,1)
                    
                    }, completion: { (finished: Bool) -> Void in
                        
                        self.performSegueWithIdentifier("raceMeToRunMode", sender: nil)
                        
                })
        })


        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if (segue.identifier == "raceMeToRunMode") {
            
            if  let runModeViewController = segue.destinationViewController as? RunModeViewController {
                
                runModeViewController.userRun = Run()
                runModeViewController.userRun.isRace = true
                
                let parentViewController = self.parentViewController as? HomeViewController
                runModeViewController.user = Runner()
                runModeViewController.user.currentLocation = parentViewController?.currentLocation
                runModeViewController.track = currentTrack
                
            }
        }
    }
    
    
    func updateMap(track: Track){
        
        var coordinates: [CLLocationCoordinate2D] = []
        
        for trackPoint in track.trackPoints {
            
            coordinates.append(trackPoint.trackPointToCLLocationCoordinate2D())
            
        }
        
        
        let line = MGLPolyline(coordinates: &coordinates, count: UInt(coordinates.count))
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
        
        //mapViewSetCamera()
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
        return colorOfCorrespondingDistance(currentTrack.totalDistanceMetres)
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
