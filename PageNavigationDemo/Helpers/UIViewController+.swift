//
//  UIViewController+.swift
//  PageNavigationDemo
//
//  Created by Walid Kayhal on 22/01/2016.
//  Copyright © 2016 Walid Kayhal. All rights reserved.
//

import UIKit

extension UIViewController {
  
  func removeFromViewController() {
    willMoveToParentViewController(nil)
    view.removeFromSuperview()
    removeFromParentViewController()
  }
  
  func resignFirstResponders() {
    UIApplication.sharedApplication().keyWindow?.endEditing(true)
  }
}