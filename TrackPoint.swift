//
//  TrackPoint.swift
//  RaceMe
//
//  Created by Enoch Ng on 2016-06-17.
//  Copyright © 2016 Enoch Ng. All rights reserved.
//

import Foundation
import RealmSwift
import CoreLocation

class TrackPoint : Object {
    
      //MARK: - Admin Variables -
    dynamic var runID = ""
    dynamic var timeStamp : NSDate?
    dynamic var index = 0
    
    //MARK: - Location Variables -
    dynamic var latitude = 0.0
    dynamic var longitude  = 0.0
    dynamic var altitude = 0.0
    dynamic var checkPoint = 0
    dynamic var speed = 0.0
    
    //MARK: - Trackpoint Translation Methods -
    func trackPointToCLLocation() -> CLLocation{
        return CLLocation(coordinate: CLLocationCoordinate2DMake(self.latitude, self.longitude), altitude: self.altitude, horizontalAccuracy: 0.0, verticalAccuracy: 0.0, course: 0.0, speed: self.speed, timestamp: NSDate())
    }
    
    func trackPointToCLLocationCoordinate2D() -> CLLocationCoordinate2D{
        return CLLocationCoordinate2DMake(self.latitude, self.longitude)
    }
}
