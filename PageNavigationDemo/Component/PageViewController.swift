//
//  PageViewController.swift
//  PageNavigationDemo
//
//  Created by Walid Kayhal on 22/01/2016.
//  Copyright © 2016 Walid Kayhal. All rights reserved.
//

import UIKit

// MARK: PageViewController

typealias PageViewControllerScrollingBlock = ((UIScrollView) -> Void)

protocol PageViewControllerScrolling: class {
  var scrollViewDidScrollBlock: PageViewControllerScrollingBlock? { get set }
  func scrollViewDidScroll(scrollView: UIScrollView)
  var shouldStretchAutomatically: Bool { get }
  var scrollInverted: Bool { get }
  var scrollViewProxy: UIScrollView { get }
  var infosView: UIView { get }
}

// MARK: PageViewControllerScrolling + Default implementations

extension PageViewControllerScrolling {
  var shouldStretchAutomatically: Bool { return false }
  var scrollInverted: Bool { return false }
  var infosView: UIView { return UIView() }
}

class PageViewController: UIViewController {
  
  // MARK: Some Parameters
  
  private struct Parameters {
    static let cursorViewHeight:CGFloat = 3.0
    static let cursorColor = UIColor(red: 102/255, green: 0/255, blue: 204/255, alpha: 1)
    static let bodyBackgroundColor = UIColor.whiteColor()
    static let headerBackgroundColor = UIColor(red: 204/255, green: 204/255, blue: 230/255, alpha: 1)
    static let navigationBarHeight: CGFloat = 44.0
    static let topBar = navigationBarHeight + UIApplication.sharedApplication().statusBarFrame.height
    static let headerMinHeight: CGFloat = 50.0 + topBar
    static let headerMaxHeight: CGFloat = headerMinHeight + 70
    static let selectedTitleColor = UIColor.whiteColor()
    static let unselectedTitleColor = UIColor.lightGrayColor()
    static let titleHeight: CGFloat = 50.0
    static let titleFontSize: CGFloat = 15.0
    static let titleSemiBoldFont = UIFont.boldSystemFontOfSize(titleFontSize)
    static let titleThinFont = titleSemiBoldFont
    static var titleWidth: CGFloat = 0.0
    static let defaultDurationAnimation: NSTimeInterval = 0.4
    static var firstIndex = 0
    static var maxVisibleTitles = 1 {
      didSet {
        if maxVisibleTitles < 1 { maxVisibleTitles = 1 }
      }
    }
  }
  
  // MARK: Properties
  
  private let cursorView = UIView()
  private let headerView = UIView()
  private var infosContainerView = UIView()
  private let headerScrollView = UIScrollView()
  private let bodyScrollView = UIScrollView()
  private var titlesButtons: [UIButton] = []
  private var currentPage = 0
  private var controllers = [UIViewController]()
  
  private var headerViewHeightConstraint: NSLayoutConstraint?
  private var cursorViewLeadingConstraint: NSLayoutConstraint?
  
  var controllerDidLoad: ((UIViewController) -> Void)?
  var controllerDidChange: ((oldController: UIViewController, newController: UIViewController) -> Void)?
  var childDidScroll: ((UIScrollView, animated: Bool, inverted: Bool) -> Void)?
  
  
  // MARK: Methods
  
  private func configureViews() {
    
    // Header
    headerView.removeFromSuperview()
    headerView.frame = view.frame
    headerView.frame.size.height = Parameters.headerMaxHeight
    headerView.backgroundColor = Parameters.headerBackgroundColor
    view.addSubview(headerView)
    
    // Infos view container
    infosContainerView.removeFromSuperview()
    infosContainerView.frame = CGRect(x: 0, y: Parameters.topBar, width: headerView.frame.width, height: (headerView.frame.height - Parameters.titleHeight))
    headerView.addSubview(infosContainerView)
    
    // Header Scroll
    headerScrollView.removeFromSuperview()
    headerScrollView.frame = CGRect(x: 0, y: Parameters.titleHeight, width: headerView.frame.width, height: Parameters.titleHeight)
    headerScrollView.showsHorizontalScrollIndicator = false
    headerScrollView.scrollEnabled = false
    Parameters.titleWidth = headerScrollView.frame.width / CGFloat(Parameters.maxVisibleTitles)
    headerScrollView.contentSize = CGSize(width: Parameters.titleWidth * CGFloat(controllers.count), height: headerScrollView.frame.height)
    headerView.addSubview(headerScrollView)
    
    // Body Scroll
    bodyScrollView.removeFromSuperview()
    bodyScrollView.frame = CGRect(x: 0, y: headerView.frame.height, width: view.frame.width, height: (view.frame.height - headerView.frame.height))
    bodyScrollView.pagingEnabled = true
    bodyScrollView.showsHorizontalScrollIndicator = false
    bodyScrollView.bounces = false
    bodyScrollView.delegate = self
    bodyScrollView.contentSize = CGSize(width: CGFloat(controllers.count) * view.frame.width, height: 0)
    bodyScrollView.contentOffset = CGPoint(x: view.frame.width * CGFloat(Parameters.firstIndex), y: 0)
    bodyScrollView.backgroundColor = Parameters.bodyBackgroundColor
    view.addSubview(bodyScrollView)
    
    // Cursor view
    cursorView.removeFromSuperview()
    cursorView.frame = CGRect(x: 0, y: headerView.frame.height - Parameters.cursorViewHeight, width: Parameters.titleWidth, height: Parameters.cursorViewHeight)
    cursorView.backgroundColor = Parameters.cursorColor
    headerView.addSubview(cursorView)
  }
  
  private func setupChildControllers() {
    
    // Creation of containers views
    for i in 0..<controllers.count {
      
      // Child view controller
      let childViewController = controllers[i]
      
      // New frame of each child view controller
      let frame = CGRect(x: CGFloat(i) * view.frame.width, y: 0, width: view.frame.width, height: bodyScrollView.frame.height)
      
      // Add child view controller to his parent (page view controller).
      controllerDidLoad?(childViewController)
      addChildViewController(childViewController)
      
      childViewController.view.frame = frame
      childViewController.view.backgroundColor = Parameters.bodyBackgroundColor
      
      // Add child view to the "body" scroll view
      bodyScrollView.addSubview(childViewController.view)
      childViewController.didMoveToParentViewController(self)
    }
  }
  
  private func updateTitleButtons(currentPage: Int) {
    titlesButtons.forEach {
      $0.titleLabel?.font = ($0 == titlesButtons[currentPage])
        ? Parameters.titleSemiBoldFont
        : Parameters.titleThinFont
      $0.setTitleColor($0 == titlesButtons[currentPage]
        ? Parameters.selectedTitleColor
        : Parameters.unselectedTitleColor, forState: .Normal)
    }
  }
  
  private func setupChildControllerTitles() {
    
    // Clean titles button array
    titlesButtons.forEach { $0.removeFromSuperview() }
    titlesButtons = []
    
    // Creation of titles
    for i in 0..<controllers.count {
      
      // Child view controller
      let childViewController = controllers[i]
      let title = childViewController.title?.uppercaseString
      
      // Button containing the title
      let buttonFrame = CGRect(x: CGFloat(i) * Parameters.titleWidth, y: 0, width: Parameters.titleWidth, height: headerScrollView.frame.height)
      let titleButton = UIButton(frame: buttonFrame)
      titleButton.tag = i
      titleButton.setTitle(title, forState: .Normal)
      titleButton.setTitleColor(Parameters.selectedTitleColor, forState: .Normal)
      titleButton.addTarget(self, action: "didPressTitle:", forControlEvents: .TouchUpInside)
      // Add to the array (saving)
      titlesButtons.append(titleButton)
      
      // Add label to the "header" scroll view
      headerScrollView.addSubview(titleButton)
    }
    updateTitleButtons(Parameters.firstIndex)
  }
  
  private func layoutIfNeeded() {
    UIView.animateWithDuration(Parameters.defaultDurationAnimation, animations: { [weak self] in
      self?.view.layoutIfNeeded() })
  }
  
  
  // MARK: Life cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // I remove the navigation bar line
    navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
    navigationController?.navigationBar.shadowImage = UIImage()
    
    childDidScroll = { [weak self] scrollView, animated, inverted in
      self?.childScrollViewDidScroll(scrollView, animated: animated, inverted: inverted)
    }
  }
  
  override func viewDidDisappear(animated: Bool) {
    super.viewDidDisappear(animated)
    deleteViewControllers()
  }
  
  // MARK: Actions
  
  func didPressTitle(button: UIButton!) {
    bodyScrollView.setContentOffset(CGPoint(x: bodyScrollView.frame.width * CGFloat(button.tag), y: 0), animated: true)
  }
  
  // MARK: Methods
  
  private func render() {
    
    // Configurations
    configureViews()
    setupChildControllers()
    setupChildControllerTitles()
    
    // Constraints
    [headerScrollView, bodyScrollView, headerView, cursorView, infosContainerView].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
    setupCursorViewConstraint()
    setupHeaderViewContraints()
    setupBodyScrollViewConstraints()
    setupHeaderScrollViewConstraints()
    setupInfosContainerViewConstraints()
  }
  
  func setViewControllers(viewControllers: [UIViewController], maxVisibleTitles: Int = 1, firstIndex: Int = 0) {
    
    // Remove old
    controllers.forEach { $0.removeFromViewController() }
    controllers = viewControllers
    
    // Init
    Parameters.maxVisibleTitles = min(maxVisibleTitles, controllers.count)
    Parameters.firstIndex = min(firstIndex, controllers.count-1)
    
    // Display
    render()
  }
  
  private func deleteViewControllers() {
    controllers.forEach {
      $0.removeFromViewController()
      // Avoid retain cycle
      if let controller = $0 as? PageViewControllerScrolling {
        controller.scrollViewDidScrollBlock = nil
      }
    }
  }
  
  func setInfosView(infosView: UIView) {
    
    // View
    infosContainerView.subviews.forEach { $0.removeFromSuperview() }
    infosContainerView.addSubview(infosView)
    
    // Constraints
    infosView.translatesAutoresizingMaskIntoConstraints = false
    let bindings = ["infosView": infosView]
    let constraints = [NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[infosView]-0-|", options: NSLayoutFormatOptions(), metrics: nil, views: bindings),
      NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[infosView]-0-|", options: NSLayoutFormatOptions(), metrics: nil, views: bindings)]
    constraints.forEach { infosContainerView.addConstraints($0) }
    infosContainerView.layoutIfNeeded()
    
  }
  
  func openMode() {
    infosContainerView.hidden = true
    headerViewHeightConstraint?.constant = Parameters.headerMaxHeight
    layoutIfNeeded()
  }
  
  func closeMode() {
    infosContainerView.hidden = true
    headerViewHeightConstraint?.constant = Parameters.headerMinHeight
    layoutIfNeeded()
  }
}

// MARK: Extension for UIScrollViewDelegate

extension PageViewController : UIScrollViewDelegate {
  
  // MARK: Delegate
  
  func scrollViewDidScroll(scrollView: UIScrollView) {
    manageHeaderScrollView(scrollView)
  }
  
  func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
    moveToPage(scrollView)
  }
  
  func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
    moveToPage(scrollView)
  }
  
  // MARK: Private methods
  
  private func childScrollViewDidScroll(scrollView: UIScrollView, animated: Bool = false, inverted: Bool) {
    
    let toTop: CGFloat
    
    if !inverted {
      toTop = scrollView.contentOffset.y + scrollView.contentInset.top
    } else {
      toTop = scrollView.contentSize.height - scrollView.frame.size.height + scrollView.contentInset.bottom - scrollView.contentOffset.y
    }
    
    // Avoiding parallax only when animation is false
    if !animated {
      // To avoid parallax
      if headerViewHeightConstraint?.constant < Parameters.headerMaxHeight && headerViewHeightConstraint?.constant > Parameters.headerMinHeight {
        if !inverted {
          scrollView.contentInset = UIEdgeInsets(top: toTop, left: 0, bottom: 0, right: 0)
          scrollView.scrollIndicatorInsets = scrollView.contentInset
          scrollView.contentOffset = CGPointZero
        } else {
        }
      }
    }
    
    headerViewHeightConstraint?.constant = Parameters.headerMaxHeight - toTop
    
    if (headerViewHeightConstraint?.constant > Parameters.headerMaxHeight) {
      headerViewHeightConstraint?.constant = Parameters.headerMaxHeight
    }
    if (headerViewHeightConstraint?.constant < Parameters.headerMinHeight) {
      headerViewHeightConstraint?.constant = Parameters.headerMinHeight
    }
    
    infosViewDidScroll()
    
    if animated { layoutIfNeeded() }
  }
  
  private func infosViewDidScroll() {
    
    infosContainerView.hidden = false
    
    let headerHeight = headerViewHeightConstraint?.constant ?? 0
    let infosViewStaticHeight = Parameters.headerMaxHeight - (Parameters.topBar + Parameters.titleHeight)
    let scretchableHeight = headerHeight - (Parameters.topBar + Parameters.titleHeight)
    
    (infosContainerView.subviews.first as? InfoViewProtocol)?.infosViewDidScroll(navigationController, scretchableHeight: scretchableHeight, infosViewStaticHeight: infosViewStaticHeight)
  }
  
  private func moveToPage(scrollView: UIScrollView) {
    let page = scrollView.contentOffset.x / scrollView.frame.size.width
    let lastIndex = currentPage
    currentPage = Int(round(page))
    let newIndex = currentPage
    
    if lastIndex < controllers.count {
      controllers[lastIndex].resignFirstResponders()
      controllerDidChange?(oldController: controllers[lastIndex], newController: controllers[newIndex])
    }
  }
  
  private func updateCursorWithPage(page: CGFloat, move: CGFloat) {
    cursorViewLeadingConstraint?.constant = (Parameters.titleWidth * (page + 1)) - Parameters.titleWidth/2 - cursorView.frame.width/2 - move
  }
  
  func manageHeaderScrollView(scrollView: UIScrollView) {
    let page = scrollView.contentOffset.x / scrollView.frame.size.width
    let hiddenTitlesCount = controllers.count - Parameters.maxVisibleTitles
    let widthOfHiddenTitles = Parameters.titleWidth * CGFloat(hiddenTitlesCount)
    let ratio = widthOfHiddenTitles/CGFloat(controllers.count-1)
    let move = page * ratio
    
    // Moving cursor
    updateCursorWithPage(page, move: move)
    headerScrollView.contentOffset = CGPoint(x: move, y: 0)
    updateTitleButtons(Int(round(page)))
  }
}

// MARK: Extension for constraints

extension PageViewController {
  
  private func setupHeaderViewContraints() {
    
    let constraints = [NSLayoutConstraint(item: headerView, attribute: .Top, relatedBy:  .Equal, toItem: topLayoutGuide, attribute: .Top, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: headerView, attribute: .Bottom, relatedBy:  .Equal, toItem: bodyScrollView, attribute: .Top, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: headerView, attribute: .Leading, relatedBy:  .Equal, toItem: view, attribute: .Leading, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: headerView, attribute: .Trailing, relatedBy:  .Equal, toItem: view, attribute: .Trailing, multiplier: 1, constant: 0)]
    
    headerViewHeightConstraint =  NSLayoutConstraint(item: headerView, attribute: .Height, relatedBy:  .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: Parameters.headerMinHeight)
    headerViewHeightConstraint?.priority = UILayoutPriorityDefaultHigh
    
    view.addConstraints(constraints)
    view.addConstraint(headerViewHeightConstraint!)
  }
  
  private func setupBodyScrollViewConstraints() {
    
    let constraints = [NSLayoutConstraint(item: bodyScrollView, attribute: .Bottom, relatedBy:  .Equal, toItem: bottomLayoutGuide, attribute: .Bottom, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: bodyScrollView, attribute: .Leading, relatedBy:  .Equal, toItem: view, attribute: .Leading, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: bodyScrollView, attribute: .Trailing, relatedBy:  .Equal, toItem: view, attribute: .Trailing, multiplier: 1, constant: 0)]
    view.addConstraints(constraints)
  }
  
  private func setupInfosContainerViewConstraints() {
    
    let constraints = [NSLayoutConstraint(item: infosContainerView, attribute: .Top, relatedBy:  .Equal, toItem: topLayoutGuide, attribute: .Top, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: infosContainerView, attribute: .Bottom, relatedBy:  .Equal, toItem: headerScrollView, attribute: .Top, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: infosContainerView, attribute: .Leading, relatedBy:  .Equal, toItem: view, attribute: .Leading, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: infosContainerView, attribute: .Trailing, relatedBy:  .Equal, toItem: view, attribute: .Trailing, multiplier: 1, constant: 0)]
    
    view.addConstraints(constraints)
  }
  
  private func setupHeaderScrollViewConstraints() {
    
    let constraints = [NSLayoutConstraint(item: headerScrollView, attribute: .Bottom, relatedBy:  .Equal, toItem: headerView, attribute: .Bottom, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: headerScrollView, attribute: .Leading, relatedBy:  .Equal, toItem: headerView, attribute: .Leading, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: headerScrollView, attribute: .Trailing, relatedBy:  .Equal, toItem: headerView, attribute: .Trailing, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: headerScrollView, attribute: .Height, relatedBy:  .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: headerScrollView.frame.height)]
    view.addConstraints(constraints)
  }
  
  private func setupCursorViewConstraint() {
    
    let constraints = [NSLayoutConstraint(item: cursorView, attribute: .Bottom, relatedBy:  .Equal, toItem: headerView, attribute: .Bottom, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: cursorView, attribute: .Height, relatedBy:  .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: cursorView.frame.height),
      NSLayoutConstraint(item: cursorView, attribute: .Width, relatedBy:  .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: cursorView.frame.width)]
    
    cursorViewLeadingConstraint = NSLayoutConstraint(item: cursorView, attribute: .Left, relatedBy:  .Equal, toItem: headerView, attribute: .Left, multiplier: 1, constant: 0)
    
    updateCursorWithPage(CGFloat(Parameters.firstIndex), move: 0)
    
    view.addConstraints(constraints)
    view.addConstraint(cursorViewLeadingConstraint!)
  }
}
