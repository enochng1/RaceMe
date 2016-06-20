//
//  ViewController.swift
//  RaceMe
//
//  Created by Enoch Ng on 2016-06-13.
//  Copyright © 2016 Enoch Ng. All rights reserved.
//

import UIKit
import Mapbox

protocol setAsvasdfasdfCurrentViewControllerDelegate : class {
    
    func registerAsCurrentViewController()
    
}

class ViewController: UIViewController, UIScrollViewDelegate{

    @IBOutlet weak var scrollView: UIScrollView!
    
      var locationManager = LocationManager.sharedInstance
    weak var VCDelegate : setAsCurrentViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        locationManager.startLocationManager()
    }

    @IBOutlet weak var scrollerConstraintX: NSLayoutConstraint!
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        //update scroller according to scrollView
        self.scrollerConstraintX.constant = self.scrollView.contentOffset.x/3;
        self.view.layoutIfNeeded()
        
//        if self.scrollView.contentOffset.x >= 0.0 && self.scrollView.contentOffset.x < self.view.frame.width{
//            
//            print ("in trainview")
//            
//        } else if self.scrollView.contentOffset.x >= self.view.frame.width && self.scrollView.contentOffset.x < self.view.frame.width*2{
//            
//            print ("in raceMeview")
//        
//        } else if self.scrollView.contentOffset.x >= self.view.frame.width * 2 {
//            
//            print ("in competeview")
//        }
        
        if self.scrollView.contentOffset.x == 0.0 {
                
//            self.VCDelegate = self.childViewControllers[0] as? TrainViewController
//            self.VCDelegate?.registerAsCurrentViewController()
            
        } else if self.scrollView.contentOffset.x == self.view.frame.width {
            
//            self.VCDelegate = self.childViewControllers[1].childViewControllers[0] as? RaceMeViewController
//            self.VCDelegate?.registerAsCurrentViewController()
            
        } else if self.scrollView.contentOffset.x == self.view.frame.width * 2 {

        }
    }
    
    @IBAction func trainNavButtonPressed(sender: UIButton) {
        //animation for resetting the content to the particular view controller and also adjusting scroller
        self.scrollerConstraintX.constant = 0.0;
        UIView.animateWithDuration(1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.1, options: [], animations: {
            self.scrollView.contentOffset.x = 0.0;
            self.view.layoutIfNeeded()
            }, completion: nil)
    }

    @IBAction func competeNavButtonPressed(sender: UIButton) {
        //animation for resetting the content to the particular view controller and also adjusting scroller
        self.scrollerConstraintX.constant = self.view.frame.width/3;
        UIView.animateWithDuration(1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.1, options: [], animations: {
            self.scrollView.contentOffset.x = self.view.frame.width;
            self.view.layoutIfNeeded()
            }, completion: nil)
        
        
        
    }
    
    
    @IBAction func recordsNavButtonPressed(sender: UIButton) {  
        //animation for resetting the content to the particular view controller and also adjusting scroller
        self.scrollerConstraintX.constant = self.view.frame.width*2/3;
        UIView.animateWithDuration(1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.1, options: [], animations: {
            self.scrollView.contentOffset.x = self.view.frame.width*2;
            self.view.layoutIfNeeded()
            }, completion: nil)
    }
    
}

