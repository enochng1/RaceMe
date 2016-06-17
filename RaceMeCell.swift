//
//  RaceMeCell.swift
//  RaceMe
//
//  Created by Enoch Ng on 2016-06-15.
//  Copyright © 2016 Enoch Ng. All rights reserved.
//

import UIKit
import Mapbox

class RaceMeCell: UICollectionViewCell {

    @IBOutlet weak var mapView: MGLMapView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
}
