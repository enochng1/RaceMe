//
//  NewRunViewController.swift
//  RaceMe
//
//  Created by Enoch Ng on 2016-06-19.
//  Copyright © 2016 Enoch Ng. All rights reserved.
//

import Foundation
import UIKit
import DynamicBlurView
import NVActivityIndicatorView

class NewRunViewController: UIViewController{
    
    
    @IBOutlet weak var counterLabel: UILabel!
    
    @IBOutlet weak var startRunButtonOverlay: UIImageView!
    
    @IBOutlet weak var startRunButton: UIButton!
    
    @IBOutlet weak var orbiterImage: UIImageView!
    
    var counter = 3
    
    var timer = NSTimer()
    
    override func viewDidDisappear(animated: Bool) {
            startRunButton.alpha = 1.0
        counter = 3
        orbiterImage.alpha = 0.0
    }
    
    @IBAction func startRunButtonPressed(sender: UIButton) {
        
       
        

        //        UIView.animateWithDuration(0.25, animations: {
        //
        //            startRunButton.alpha = 0.0
        //            orbiter.transform = CGAffineTransformMakeRotation(<#T##angle: CGFloat##CGFloat#>)
        //
        //            }, completion: { (finished: Bool) -> Void in
        //
        //
        //
        //
        //                ((angle) / 180.0 * M_PI)
        //
        //        })
        
        orbiterImage.layer.anchorPoint = CGPointMake(1, 1);
            self.orbiterImage.transform = CGAffineTransformMakeRotation(90)
        //
        startRunButtonOverlay.transform =  CGAffineTransformMakeScale(0.1,0.1)
     
                    self.timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(self.updateCounter), userInfo: nil, repeats: true)
        
        UIView.animateWithDuration(0.2, animations: {
            
            self.startRunButtonOverlay.alpha = 0.4
            self.startRunButtonOverlay.transform =  CGAffineTransformMakeScale(1,1)
            
     
            
            }, completion: { (finished: Bool) -> Void in
                
                UIView.animateWithDuration(0.4, animations: {
                    
                    self.startRunButtonOverlay.alpha = 0.0
                    self.startRunButtonOverlay.transform =  CGAffineTransformMakeScale(1,1)
                    self.startRunButton.alpha = 0.0
                    
                    }, completion: { (finished: Bool) -> Void in
                        
                   
                       
                })
        })
        
    }
    
    func updateCounter() {
        
        if(counter > 0){
            counterLabel.text = String(format:"%i", counter)
            
            counterLabel.transform = CGAffineTransformMakeScale(0.4,0.4)
            
            UIView.animateWithDuration(0.2, animations: {
                
                self.counterLabel.alpha = 1.0
                self.counterLabel.transform =  CGAffineTransformMakeScale(1,1)
                
                }, completion: { (finished: Bool) -> Void in
                    
                    self.runOrbiter()
                    UIView.animateWithDuration(0.8, animations: {
                        
                        self.counterLabel.alpha = 0.0
                        self.counterLabel.transform =  CGAffineTransformMakeScale(1,1)
                        
                        }, completion: { (finished: Bool) -> Void in
                            
                            
                    })
            })
            
        }
        counter = counter - 1
        
        if(counter == -1){
            self.performSegueWithIdentifier("newRunToRunMode", sender: nil)
            timer.invalidate()
        }
        

    }
    
    func runOrbiter(){
        UIView.animateWithDuration(0.25, delay: 0, options: .CurveLinear, animations: {
            
            self.orbiterImage.alpha = 1.0
            self.orbiterImage.transform = CGAffineTransformMakeRotation(180)
            }, completion: { (finished: Bool) -> Void in
                
                UIView.animateWithDuration(0.25, delay: 0, options: .CurveLinear, animations: {
                    
                    self.orbiterImage.alpha = 1.0
                    self.orbiterImage.transform = CGAffineTransformMakeRotation(270)
                    }, completion: { (finished: Bool) -> Void in
                        
                        UIView.animateWithDuration(0.25, delay: 0, options: .CurveLinear, animations: {
                            
                            self.orbiterImage.alpha = 0.0
                            self.orbiterImage.transform = CGAffineTransformMakeRotation(0)
                            }, completion: { (finished: Bool) -> Void in
                               
                                if(self.counter > 0){
                                UIView.animateWithDuration(0.25, delay: 0, options: .CurveLinear, animations: {
                                    
                                    self.orbiterImage.alpha = 1.0
                                    self.orbiterImage.transform = CGAffineTransformMakeRotation(90)
                                    
                                    }, completion: { (finished: Bool) -> Void in
                                })
                                }
                                })
                })
        })
    }
    
    func overlayAnimation(view : UIView){
        
        view.transform =  CGAffineTransformMakeScale(0.1,0.1)
        
        UIView.animateWithDuration(0.2, animations: {
            
            view.alpha = 0.4
            view.transform =  CGAffineTransformMakeScale(1,1)
            
            }, completion: { (finished: Bool) -> Void in
                
                UIView.animateWithDuration(0.4, animations: {
                    
                    view.alpha = 0.0
                    view.transform =  CGAffineTransformMakeScale(1,1)
                    
                    }, completion: { (finished: Bool) -> Void in
                        
                })
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
