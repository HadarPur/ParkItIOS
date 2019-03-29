//
//  SplashViewController.swift
//  ParkItIOS
//
//  Created by Hadar Pur on 25/03/2019.
//  Copyright © 2019 Hadar Pur. All rights reserved.
//

import UIKit

class SplashViewController: UIViewController {
    
    @IBOutlet weak var mImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true

    }
    
    override func viewDidAppear(_ animated: Bool) {
        let deadlineTime = DispatchTime.now() + .seconds(2)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime, execute: {
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let newViewController = storyBoard.instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
            newViewController.modalTransitionStyle = .crossDissolve
            self.present(UINavigationController(rootViewController: newViewController), animated: true, completion: nil)
        })
        self.rotateView(view: self.mImageView)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        let kRotationAnimationKey = "com.myapplication.rotationanimationkey"
        
        if view.layer.animation(forKey: kRotationAnimationKey) != nil {
            view.layer.removeAnimation(forKey: kRotationAnimationKey)
        }
    }
    
    func rotateView(view: UIView, duration: Double = 1) {
        let kRotationAnimationKey = "com.myapplication.rotationanimationkey"
        
        if view.layer.animation(forKey: kRotationAnimationKey) == nil {
            let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
            
            rotationAnimation.fromValue = 0.0
            rotationAnimation.toValue = Float(.pi * 2.0)
            rotationAnimation.duration = duration
            
            view.layer.add(rotationAnimation, forKey: kRotationAnimationKey)
        }
    }
}
