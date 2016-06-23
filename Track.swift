//
//  Track.swift
//  RaceMe
//
//  Created by Enoch Ng on 2016-06-17.
//  Copyright © 2016 Enoch Ng. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit
import RealmSwift

class Track : Object {
    
     //MARK: - Admin Variables -
    dynamic var trackCreator = ""
    dynamic var trackLocation = ""
    dynamic var trackID = ""
    dynamic var dateCreated : NSDate?

     //MARK: - Track Variables -
    var trackPoints = List<TrackPoint>()
    dynamic var totalDistanceMetres = 0.0
    dynamic var fastestRecordInSeconds = 0.0
    
    //MARK: - Session Runs Variable -
    var runs = List<Run>()

    //MARK: - Admin Methods -
    func generateRandomTrackID() {
        let uuid = NSUUID().UUIDString
        trackID = uuid
    }
    
    //MARK: - Track Methods -
    func totalDistanceKilometres () -> Double {
        return totalDistanceMetres / 1000
    }
    
    func TotalDistanceKilometresToString() -> String {
        return String(format: "%0.2f km", self.totalDistanceKilometres())
    }
    
    func TotalDistanceMetresToString() -> String {
        return String(format: "%0.0f metres ",totalDistanceMetres)
    }
    
    func maxAltitude() -> CLLocationDistance {
        return 0.0
    }
    
    func minAltitude() -> CLLocationDistance {
        return 0.0
    }
    
    //MARK: - Checkpoint Methods -
    func startPointAsCLLocation() -> CLLocation{
        return trackPoints.first!.trackPointToCLLocation()
    }
    
    func startPointAsCLLocationCoordinate2D() -> CLLocationCoordinate2D{
        return trackPoints.first!.trackPointToCLLocationCoordinate2D()
    }
    
    func endPointAsCLLocation() -> CLLocation{
        return trackPoints.last!.trackPointToCLLocation()
    }
    
    func endPointAsCLLocationCoordinate2D() -> CLLocationCoordinate2D{
        return trackPoints.last!.trackPointToCLLocationCoordinate2D()
    }
    
    //MARK: - Run Handling Methods -
    func finishedRuns() -> [Run]{
    
        var finishedRuns = [Run]()
        
        if self.runs.count > 0 {
            
            for run in self.runs {
                
                if run.finishedRace {
                    finishedRuns.append(run)
                }
            }
        }
        return finishedRuns
    }
    
    //get the fastest record
    func fastestRecord() -> Run{
        
        let finRuns = self.finishedRuns()
        
        if finRuns.count > 0 {
            
            let timeSortDescriptor = NSSortDescriptor(key: "totalTimeSeconds", ascending: true)
            
            if let finishedRunsSortedByTime = (finRuns as NSArray).sortedArrayUsingDescriptors([timeSortDescriptor]) as? [Run] {
                
                return finishedRunsSortedByTime.first!
                
             }
                
           }
         return Run()
    }
    
}