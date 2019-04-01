//
//  UIViewControllerExtentions.swift
//  ParkItIOS
//
//  Created by Hadar Pur on 01/04/2019.
//  Copyright © 2019 Hadar Pur. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    func observerToSwipe()  {
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
    }
    
    @objc func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        if gesture.direction == UISwipeGestureRecognizer.Direction.right {
            print("Swipe Right")
            _=self.navigationController?.popViewController(animated: true)
        }
    }
}
