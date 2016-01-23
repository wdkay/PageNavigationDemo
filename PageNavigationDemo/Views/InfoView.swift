//
//  InfoView.swift
//  PageNavigationDemo
//
//  Created by Walid Kayhal on 22/01/2016.
//  Copyright © 2016 Walid Kayhal. All rights reserved.
//

import UIKit


protocol InfoViewProtocol {
  func infosViewDidScroll(navigationController: UINavigationController?, scretchableHeight: CGFloat, infosViewStaticHeight: CGFloat)
}

class InfoView: UIView, InfoViewProtocol {

  // MARK: Outlets
  
  @IBOutlet weak var gameTypeImageView: UIImageView!
  @IBOutlet weak var gameTitleLabel: UILabel!
  
  // MARK: Methods
  func infosViewDidScroll(navigationController: UINavigationController?, scretchableHeight: CGFloat, infosViewStaticHeight: CGFloat) {
    
    let value = scretchableHeight/infosViewStaticHeight
    let scale = CGAffineTransformMakeScale(max(value, 0.9), max(value, 0.9))
    let translation = CGAffineTransformMakeTranslation(0, scretchableHeight-infosViewStaticHeight)
    
    navigationController?.navigationBar.subviews
      .flatMap { $0 as? UIButton }
      .filter { $0.tag == 1 }
      .forEach {
        $0.alpha = scretchableHeight/infosViewStaticHeight
    }
    
    subviews
      .filter { $0.tag == 2 }
      .forEach {
        $0.transform = scale
    }
    
    subviews
      .filter { $0.tag == 1 }
      .forEach {
        $0.transform = translation
        $0.alpha = scretchableHeight/infosViewStaticHeight
    }
  }

}
