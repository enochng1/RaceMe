//
//  TrackPointParse.swift
//  RaceMe
//
//  Created by Enoch Ng on 2016-06-22.
//  Copyright © 2016 Enoch Ng. All rights reserved.
//

import Foundation
import Parse


class TrackPointParse : PFObject, PFSubclassing {
    
    //MARK: - Admin Variables -
    @NSManaged var runID : String
    @NSManaged var timeStamp : NSDate
    @NSManaged var index : Int
    //MARK: - Location Variables -
    @NSManaged var latitude : Double
    @NSManaged var longitude  : Double
    @NSManaged var altitude : Double
    @NSManaged var checkPoint : Int
    @NSManaged var speed : Double

    //MARK: - Parse Methods -
    override class func initialize() {
        struct Static {
            static var onceToken : dispatch_once_t = 0;
        }
        dispatch_once(&Static.onceToken) {
            self.registerSubclass()
        }
    }
    
    static func parseClassName() -> String {
        return "TrackPointParse"
    }
  
}