//
//  ViewController.swift
//  RaceMe
//
//  Created by Enoch Ng on 2016-06-13.
//  Copyright © 2016 Enoch Ng. All rights reserved.
//

import UIKit


class ViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    @IBAction func trainNavButtonPressed(sender: UIButton) {
       
        //animates offset
        UIView.animateWithDuration(1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.1, options: [], animations: {
            self.scrollView.contentOffset.x = 0.0;
            }, completion: nil)
        
    }

    
    @IBAction func competeNavButtonPressed(sender: UIButton) {
        
        UIView.animateWithDuration(1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.1, options: [], animations: {
            self.scrollView.contentOffset.x = self.view.frame.width;
            }, completion: nil)
    }
    
    
    @IBAction func recordsNavButtonPressed(sender: UIButton) {
        UIView.animateWithDuration(1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.1, options: [], animations: {
            self.scrollView.contentOffset.x = self.view.frame.width*2;
            }, completion: nil)
    }
    
}

