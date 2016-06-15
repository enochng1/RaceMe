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

class Run : NSObject {
    
    //admin specific
    var trackName : String?
    var dateRan : NSDate?
    var areaLocation : String?
    var trackImageURL: String?
    
    //track specifics
    var trackedLocations = [CLLocation]()
    var totalDistance = 0.0
    
    //run specifics
    var totalAveragePace = 0.0
    var totalTime = 0.0
    
    
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