//
//  RootViewController.swift
//  PageNavigationDemo
//
//  Created by Walid Kayhal on 22/01/2016.
//  Copyright © 2016 Walid Kayhal. All rights reserved.
//

import UIKit

class RootViewController: PageViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    setupControllers()
    setupCallbacks()
  }
  
  private func setupControllers() {
    setViewControllers([
      UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("VC1"),
      UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("VC2"),
      UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("VC3"),
      UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("VC4"),
      UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("VC5")
      ], maxVisibleTitles: 3, firstIndex: 0)
  }
  
  private func setupCallbacks() {
    // Segment callback
    controllerDidLoad = { [weak self] controller in
      
      if let controller = controller as? PageViewControllerScrolling {
        let inverted = controller.scrollInverted
        controller.scrollViewDidScrollBlock = { [weak self] scrollView in
          self?.childDidScroll?(scrollView, animated: false, inverted: inverted)
        }
      }
    }
    
    controllerDidChange = { [weak self] oldController, newController in
      
      if let oldController = oldController as? PageViewControllerScrolling {
        oldController.scrollViewDidScrollBlock = nil
      }
      
      if let newController = newController as? PageViewControllerScrolling {
        
        let inverted = newController.scrollInverted
        newController.scrollViewDidScrollBlock = { [weak self] scrollView in
          self?.setInfosView(newController.infosView)
          self?.childDidScroll?(scrollView, animated: false, inverted: inverted)
        }
        
        if newController.shouldStretchAutomatically {
          self?.setInfosView(newController.infosView)
          self?.childDidScroll?(newController.scrollViewProxy, animated: true, inverted: inverted)
        }
      }
      
      if oldController is PageViewControllerScrolling && !(newController is PageViewControllerScrolling) {
        self?.closeMode()
      }
    }
  }
}
