//
//  NewRunViewController.swift
//  RaceMe
//
//  Created by Enoch Ng on 2016-06-19.
//  Copyright © 2016 Enoch Ng. All rights reserved.
//

import Foundation
import UIKit

class NewRunViewController: UIViewController{
    
    
    @IBAction func startRunButtonPressed(sender: UIButton) {
        
        UIView.animateWithDuration(1, animations: {
            
            
            }, completion: { (finished: Bool) -> Void in
                
                self.performSegueWithIdentifier("newRunToRunMode", sender: nil)
                self.view.alpha = 1.0
        })
        
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if (segue.identifier == "newRunToRunMode") {
            
            if  let runModeViewController = segue.destinationViewController as? RunModeViewController {
                
                runModeViewController.userRun = Run()
                runModeViewController.userRun.isRace = false
                
                let parentViewController = self.parentViewController as? HomeViewController
                runModeViewController.user = Runner()
                runModeViewController.user.currentLocation = parentViewController?.currentLocation
                
                runModeViewController.runTracking = true
                
            }
        }
    }
}
