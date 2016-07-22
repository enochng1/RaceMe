//
//  RecordsViewController.swift
//  RaceMe
//
//  Created by Enoch Ng on 2016-06-19.
//  Copyright © 2016 Enoch Ng. All rights reserved.
//

import UIKit
import CoreLocation
import RealmSwift


class RecordsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let myRealm = try! Realm()
    
    var allTracks : Results<Track>!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var promptLabel: UILabel!
    
    var currentTrack = Track()
    
    
    override func viewDidLoad() {
        
        allTracks = myRealm.objects(Track.self)
        
        
    }

    
    override func viewDidAppear(animated: Bool) {
        
        if allTracks.count != 0 {
            promptLabel.alpha = 0.0
        }
        
        tableView.reloadData()
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if allTracks.count > 0 {
            return allTracks.count
            } else {
        return 0
        }        
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let recordHeader = tableView.dequeueReusableCellWithIdentifier("recordHeaderView") as! RecordHeaderView
        
        recordHeader.distanceLabel.text = allTracks[section].TotalDistanceKilometresToString()
        recordHeader.distanceLabel.textColor = colorOfCorrespondingDistance(allTracks[section].totalDistanceMetres)
        
        recordHeader.locationLabel.text = allTracks[section].trackLocation

        return recordHeader
    }
    
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           return allTracks[section].runs.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
    let cell : RecordCell = (tableView.dequeueReusableCellWithIdentifier("recordCell", forIndexPath: indexPath) as? RecordCell)!
  
    let track = allTracks[indexPath.section]
        
    let run = track.runs[indexPath.row]
    
        if run.isRace{         
            if run.finishedRace {
                cell.finishedLabel.text = "Race"
            } else {
                cell.finishedLabel.text = "Unfinished"
            }
        } else {
            cell.finishedLabel.text = "Run"
        }
        
        if run == track.fastestRecord() {
            cell.totalTimeLabel.textColor = .whiteColor()
            cell.finishedLabel.textColor = UIColor.raceMeOrangeColor()
            cell.timeStampLabel.textColor = UIColor.raceMeOrangeColor()
        } else {
            cell.totalTimeLabel.textColor = UIColor.raceMeMutedGreyColor()
            cell.finishedLabel.textColor = UIColor.raceMeMutedGreyColor()
            cell.timeStampLabel.textColor = UIColor.raceMeMutedGreyColor()
        }
        
        cell.totalTimeLabel.text = run.formattedTime()
        
        let shortDate = NSDateFormatter()
        
        shortDate.dateStyle = NSDateFormatterStyle.ShortStyle
        
        cell.timeStampLabel.text = shortDate.stringFromDate(run.dateRan!)
        
        if run.endTimeDifference > 0 {
        cell.timeDifference.text = String(format: "+ %0.2f sec", abs(run.endTimeDifference))
            cell.timeDifference.textColor = UIColor.raceMeNeonGreenColor()
        } else if run.endTimeDifference < 0 {
          cell.timeDifference.text = String(format: "- %0.2f sec", abs(run.endTimeDifference))
             cell.timeDifference.textColor = UIColor.raceMeRedColor()
        } else {
            cell.timeDifference.text = ""
        }
           
    return cell
    
    }
    
    

    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    

    @IBAction func uploadButtonPressed(sender: UIButton) {
        
//        UITableViewCell *clickedCell = (UITableViewCell *)[[sender superview] superview];
//        NSIndexPath *clickedButtonPath = [self.tableView indexPathForCell:clickedCell];
//        ...

        if let cell = sender.superview?.superview?.superview as? UITableViewCell {
        let indexPath = tableView.indexPathForCell(cell)
        
            let track = allTracks[indexPath!.section]
            
            let run = track.runs[indexPath!.row]
            
            saveToParse(run)
            print(run)
            
        }
        
    }
    func colorOfCorrespondingDistance(distanceInMetres : Double) -> UIColor {
        
        if (distanceInMetres >= 10000){
            
            return UIColor.raceMeRedColor()
            
        } else if (distanceInMetres >= 5000){
            
            return UIColor.raceMeNeonGreenColor()
            
        } else {
            
            return UIColor.raceMeTextBlueColor()
        }
        
    }
    
    func saveToParse(run : Run){
        
        let runObject = RunParse()
        
        runObject.runID = run.runID
        runObject.trackID = run.trackID
        runObject.dateRan = run.dateRan!
        runObject.areaLocation = run.areaLocation
        runObject.creator = run.creator
        runObject.totalTimeSeconds = run.totalTimeSeconds
        runObject.distanceRanInMetres = run.distanceRanInMetres
        
        runObject.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            print("uploaded to Parse")
        }
        
        for trackPoint in run.footPrints {
            
            let toUploadTrackPoint = TrackPointParse()
            
            toUploadTrackPoint.runID = trackPoint.runID
            toUploadTrackPoint.timeStamp = trackPoint.timeStamp!
            toUploadTrackPoint.altitude = trackPoint.altitude
            toUploadTrackPoint.latitude = trackPoint.latitude
            toUploadTrackPoint.longitude = trackPoint.longitude
            toUploadTrackPoint.checkPoint = trackPoint.checkPoint
            toUploadTrackPoint.speed = trackPoint.speed
            toUploadTrackPoint.index = trackPoint.index
            
            toUploadTrackPoint.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
                
            }
            
        }
        
    }


}

