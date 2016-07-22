//
//  RunParse.swift
//  RaceMe
//
//  Created by Enoch Ng on 2016-06-22.
//  Copyright © 2016 Enoch Ng. All rights reserved.
//

import Foundation
import Parse

class RunParse : PFObject, PFSubclassing {
    
     //MARK: - Admin Variables -
    @NSManaged var runID : String
    @NSManaged var trackID : String
    @NSManaged var dateRan : NSDate
    @NSManaged var areaLocation : String
    @NSManaged var creator : String
    
    //MARK: - Run Statistics Variables -
    //@NSManaged var totalAveragePace : Double
    @NSManaged var totalTimeSeconds : Double
    @NSManaged var distanceRanInMetres : Double
    
     //MARK: - Methods -
    override class func initialize() {
        struct Static {
            static var onceToken : dispatch_once_t = 0;
        }
        dispatch_once(&Static.onceToken) {
            self.registerSubclass()
        }
    }
    
    static func parseClassName() -> String {
        return "RunParse"
    }
}