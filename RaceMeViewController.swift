//
//  RaceMeViewController.swift
//  RaceMe
//
//  Created by Enoch Ng on 2016-06-15.
//  Copyright © 2016 Enoch Ng. All rights reserved.
//

import UIKit
import RealmSwift
import CoreLocation
import Mapbox

class RaceMeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, setAsCurrentViewControllerDelegate {
    
    let uiRealm = try! Realm()
    var allRuns : Results<Run>!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        allRuns = uiRealm.objects(Run.self)
        // print(allRuns)
    }
    
    func registerAsCurrentViewController(){
        viewDidLoad()
        collectionView.reloadData()
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allRuns.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell : RaceMeCell = (collectionView.dequeueReusableCellWithReuseIdentifier("raceMeCell", forIndexPath: indexPath) as? RaceMeCell)!
        
        let run = allRuns?[indexPath.item]
        
        var coordinates: [CLLocationCoordinate2D] = []
        for trackedLocation in (run?.realmTrackedLocations)! {
            let coordinate = CLLocationCoordinate2DMake(trackedLocation.lat, trackedLocation.lng)
            coordinates.append(coordinate)
        }
        if(run?.totalDistance > 10){
            cell.mapView.tintColor = .redColor()
        } else if (run?.totalDistance < 10 && run?.totalDistance > 5){
            cell.mapView.tintColor = .yellowColor()
        } else {
            cell.mapView.tintColor = .greenColor()
            //                UIColor(red: 0.0, green: 0.817, blue: 0.714, alpha: 1.0)
        }
        
        if let annotations = cell.mapView.annotations {
        cell.mapView.removeAnnotations(annotations)
        }
        
        let line = MGLPolyline(coordinates: &coordinates, count: UInt(coordinates.count))
        cell.mapView.addAnnotation(line)
        
        cell.mapView.setVisibleCoordinates(&coordinates, count: UInt(coordinates.count), edgePadding: UIEdgeInsetsMake(20.0, 20.0, 50.0, 20.0), animated: true)
        
        cell.distanceLabel.text = run?.totalDistanceTranslation()
        cell.distanceLabel.textColor = cell.mapView.tintColor
        
        cell.timeLabel.text = run?.totalTimeTranslation()
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let run = allRuns?[indexPath.item]
        
        performSegueWithIdentifier("raceMeToRace", sender: run)
        
    }
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "raceMeToRace" {
            
            let raceViewController :  RaceViewController = segue.destinationViewController as! RaceViewController   
            raceViewController.track = sender as! Run
            
        }
    }
    
}
