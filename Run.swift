//
//  Run.swift
//  RaceMe
//
//  Created by Enoch Ng on 2016-06-15.
//  Copyright © 2016 Enoch Ng. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit
import RealmSwift

class Run : Object {
    
    //admin specific
    dynamic var trackName : String?
    dynamic var dateRan : NSDate?
    dynamic var areaLocation : String?
    dynamic var trackImageURL: String?
    
    //track specifics
    let realmTrackedLocations = List<RealmCLLocation>()
    dynamic var totalDistance = 0.0
    
    //run specifics
    dynamic var totalAveragePace = 0.0
    dynamic var totalTime = 0.0
    
    func generateTrackName(){
        
        if(totalDistance > 1){
            trackName = String(format: "%0.1f KM ",totalDistance)+areaLocation!+" Track"
        } else {
            trackName = String(format: "%0.0f Metres ",totalDistance*1000)+areaLocation!+" Track"
        }
        
    }
    
    func totalDistanceTranslation() -> String{
        if(totalDistance > 1){
            return String(format: "%0.1f KM ",totalDistance)
        } else {
            return String(format: "%0.0f Metres ",totalDistance*1000)
        }
    }
    
    func totalTimeTranslation() -> String{
        
        let hours = (totalTime - totalTime % 3600) / 3600
        
        let minutes = ((totalTime - hours * 3600) - (totalTime - hours * 3600) % 60) / 60
        
        let seconds = (totalTime - hours * 3600 - minutes * 60)
        
        return zeroAdder(hours)+" : "+zeroAdder(minutes) + " : "+zeroAdder(seconds)
    }
    
    func zeroAdder(timeToString : Double) -> String{
        if(timeToString > 9){
            return String(format: "%0.0f", timeToString)
        } else {
            return String(format: "0%0.0f", timeToString)
        }
        
    }
}