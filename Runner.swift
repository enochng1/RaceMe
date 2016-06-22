//
//  Runner.swift
//  RaceMe
//
//  Created by Enoch Ng on 2016-06-17.
//  Copyright © 2016 Enoch Ng. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

class Runner : NSObject {
    
    var currentLocation : CLLocation?
    var ghostStepsCounter = 0
    
    func translateSpeedToPace() -> Double{
        //return 1000/(currentLocation!.speed*60)
        let kmPerSecond = currentLocation!.speed / 1000
        
        if kmPerSecond != 0 {
        let secondPerKM = 1 / kmPerSecond
        return secondPerKM
        } else {
        return 0
        }
    }
    
    func paceToString() -> String{
        
        let minutes = ( translateSpeedToPace() - translateSpeedToPace() % 60 ) / 60
        let seconds = round( translateSpeedToPace() - minutes * 60)
        
        let minuteString = String(format: "%0.0f", minutes)
        var secondString = String(format: "%0.0f", seconds)
        
        if(seconds < 10){
            secondString = "0"  + secondString
        }
        return minuteString+":"+secondString
    }
}