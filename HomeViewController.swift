//
//  HomeViewController.swift
//  RaceMe
//
//  Created by Enoch Ng on 2016-06-19.
//  Copyright © 2016 Enoch Ng. All rights reserved.
//

import Foundation
import UIKit

protocol setAsCurrentViewControllerDelegate : class {
    
    func registerAsCurrentViewController()
    
}

class HomeViewController: UIViewController, UIScrollViewDelegate{

    @IBOutlet weak var scrollView: UIScrollView!

    @IBOutlet weak var scrollerLeadingSpaceConstraint: NSLayoutConstraint!
    
    var locationManager = LocationManager.sharedInstance
    
    weak var ViewControllerDelegate : setAsCurrentViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.startLocationManager()
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        //update scroller according to scrollView
        self.scrollerLeadingSpaceConstraint.constant = self.scrollView.contentOffset.x/4;
       // self.view.layoutIfNeeded()

        
        if self.scrollView.contentOffset.x == 0.0 {
            
            //            self.VCDelegate = self.childViewControllers[0] as? TrainViewController
            //            self.VCDelegate?.registerAsCurrentViewController()
            
        } else if self.scrollView.contentOffset.x == self.view.frame.width {
            
            //            self.VCDelegate = self.childViewControllers[1].childViewControllers[0] as? RaceMeViewController
            //            self.VCDelegate?.registerAsCurrentViewController()
            
        } else if self.scrollView.contentOffset.x == self.view.frame.width * 2 {
            
        } else if self.scrollView.contentOffset.x == self.view.frame.width * 3 {
            
        }
        
    }

    
    @IBAction func newRunButtonPressed(sender: UIButton) {
        //animation for resetting the content to the particular view controller and also adjusting scroller
        self.scrollerLeadingSpaceConstraint.constant = 0.0;
        UIView.animateWithDuration(1, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.05, options: [], animations: {
            self.scrollView.contentOffset.x = 0.0;
            self.view.layoutIfNeeded()
            }, completion: nil)
        
    }
    
    @IBAction func raceMeButtonPressed(sender: UIButton) {
        //animation for resetting the content to the particular view controller and also adjusting scroller
        self.scrollerLeadingSpaceConstraint.constant = self.view.frame.width*1/4;
        UIView.animateWithDuration(1, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.05, options: [], animations: {
            self.scrollView.contentOffset.x = self.view.frame.width;
            self.view.layoutIfNeeded()
            }, completion: nil)

    }
    
    @IBAction func competeButtonPressed(sender: UIButton) {
        //animation for resetting the content to the particular view controller and also adjusting scroller
        self.scrollerLeadingSpaceConstraint.constant = self.view.frame.width*2/4;
        UIView.animateWithDuration(1, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.05, options: [], animations: {
            self.scrollView.contentOffset.x = self.view.frame.width*2;
            self.view.layoutIfNeeded()
            }, completion: nil)

    }
    
    @IBAction func recordButtonPressed(sender: UIButton) {
        //animation for resetting the content to the particular view controller and also adjusting scroller
        self.scrollerLeadingSpaceConstraint.constant = self.view.frame.width*3/4;
        UIView.animateWithDuration(1, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.05, options: [], animations: {
            self.scrollView.contentOffset.x = self.view.frame.width*3;
            self.view.layoutIfNeeded()
            }, completion: nil)

    }
    
    
}