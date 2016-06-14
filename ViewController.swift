//
//  ViewController.swift
//  RaceMe
//
//  Created by Enoch Ng on 2016-06-13.
//  Copyright © 2016 Enoch Ng. All rights reserved.
//

import UIKit
import Mapbox


class ViewController: UIViewController, UIScrollViewDelegate{

    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
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

