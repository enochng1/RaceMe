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
    
    func translateSpeedToPace() -> Double{
        return 1000/(currentLocation!.speed*60)
    }
    
    func paceToString() -> String{
        return String(format:"%0.2f min/km", translateSpeedToPace())
    }
}