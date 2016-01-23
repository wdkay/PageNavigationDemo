//
//  FirstViewController.swift
//  PageNavigationDemo
//
//  Created by Walid Kayhal on 22/01/2016.
//  Copyright © 2016 Walid Kayhal. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController, PageViewControllerScrolling {

  // MARK: IBOutlets
  
  @IBOutlet weak var scrollView: UIScrollView!
  
  // MARK: PageViewControllerScrolling Protocol
  
  var scrollViewDidScrollBlock: PageViewControllerScrollingBlock?
  var shouldStretchAutomatically: Bool { return true }
  var scrollViewProxy: UIScrollView { return scrollView }
  var infosView: UIView {
    let view = NSBundle.mainBundle().loadNibNamed("InfoView", owner: InfoView.self, options: nil).first as! InfoView
    view.gameTypeImageView.image = UIImage(named: "Github")
    view.gameTitleLabel.text = "Page Navigation Demo"
    return view
  }

  // MARK: Life cycle
  
  override func viewDidLoad() {
      super.viewDidLoad()
  }
}

// MARK: Extension for ScrollViewDelegate

extension FirstViewController: UIScrollViewDelegate {
  
  func scrollViewDidScroll(scrollView: UIScrollView) {
    scrollViewDidScrollBlock?(scrollView)
  }
}
