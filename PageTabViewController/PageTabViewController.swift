//
//  PageTabViewController.swift
//  PageTabViewController
//
//  Created by svpcadmin on 11/11/16.
//  Copyright © 2016 tamanyan. All rights reserved.
//

import UIKit

open class PageTabViewController: UIViewController {
    public let controllers: [UIViewController]
    
    public internal(set) var currentViewController: UIViewController!
    
    public fileprivate(set) var visibleControllers = [UIViewController]()
    
    let contentScrollView: UIScrollView = {
        $0.isPagingEnabled = true
        $0.isDirectionalLockEnabled = true
        $0.showsHorizontalScrollIndicator = false
        $0.showsVerticalScrollIndicator = false
        $0.scrollsToTop = false
        $0.bounces = false
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(UIScrollView(frame: .zero))
    
    fileprivate let options: PageTabConfigurable
    
    fileprivate var currentIndex: Int = 0

    /**
     number of valid page
     */
    public var numberOfVisiblePages: Int {
        return 3
    }

    /**
     Menu Options
     */
    var menuOptions: MenuViewConfigurable {
        return self.options.menuOptions
    }
    
    /**
     Count of all pages
     */
    var pageCount: Int {
        return self.controllers.count
    }

    /**
     unit page size
     */
    public var pageSize: CGSize {
        return self.view.frame.size
    }

    private var centerContentOffsetX: CGFloat {
        return CGFloat(self.numberOfVisiblePages / 2) * self.pageSize.width
    }
    
    /**
     current page index
     */
    var currentPage: Int {
        return self.currentIndex
    }
    
    /**
     previous page index
     */
    var previousPage: Int {
        switch self.menuOptions.displayMode {
        case .infinite:
            return self.currentPage - 1 < 0 ? self.pageCount - 1 : self.currentPage - 1
        default:
            return self.currentPage - 1
        }
    }
    
    /**
     next page index
     */
    var nextPage: Int {
        switch self.menuOptions.displayMode {
        case .infinite:
            return self.currentPage + 1 > self.pageCount - 1 ? 0 : self.currentPage + 1
        default:
            return self.currentPage + 1
        }
    }
    
    public init(viewControllers: [UIViewController], options: PageTabConfigurable) {
        self.controllers = viewControllers
        self.options = options
        
        super.init(nibName: nil, bundle: nil)
        
        self.view.addSubview(self.contentScrollView)
        self.view.backgroundColor = options.backgroundColor
        
        self.contentScrollView.frame = self.view.frame
        self.contentScrollView.delegate = self
        
        self.constructPagingViewControllers()
        self.layoutPagingViewControllers()
        self.setCenterContentOffset()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func constructPagingViewControllers() {
        for (index, controller) in controllers.enumerated() {
            guard self.shouldLoad(page: index) else {
                // remove unnecessary child view controllers
                if self.isVisible(controller: controller) {
                    controller.willMove(toParentViewController: nil)
                    controller.view!.removeFromSuperview()
                    controller.removeFromParentViewController()
                    
                    let _ = visibleControllers.index(of: controller).flatMap { visibleControllers.remove(at: $0) }
                }
                continue
            }

            if self.isVisible(controller: controller) {
                continue
            }
            
            guard let pagingView = controller.view else {
                fatalError("\(controller) doesn't have any view")
            }
            
            pagingView.frame = .zero
            pagingView.translatesAutoresizingMaskIntoConstraints = false
            
            contentScrollView.addSubview(pagingView)
            addChildViewController(controller as UIViewController)
            controller.didMove(toParentViewController: self)
            
            visibleControllers.append(controller)
        }
    }
    
    fileprivate func layoutPagingViewControllers() {
        self.contentScrollView.contentSize = CGSize(width: self.view.frame.width * CGFloat(self.visibleControllers.count), height: 0)
        
        for (index, controller) in controllers.enumerated() {
            guard let pageView = controller.view, self.shouldLoad(page: index) else {
                continue
            }
            
            let originPoint = self.contentScrollView.frame.origin
            let pageSize = self.contentScrollView.frame.size
            
            switch index {
            case self.currentPage:
                pageView.frame = CGRect(origin: CGPoint(x: originPoint.x + pageSize.width, y: originPoint.y), size: pageSize)
                break
            case self.previousPage:
                pageView.frame = CGRect(origin: CGPoint(x: originPoint.x, y: originPoint.y), size: pageSize)
                break
            case self.nextPage:
                pageView.frame = CGRect(origin: CGPoint(x: originPoint.x + pageSize.width * 2, y: originPoint.y), size: pageSize)
                break
            default: break
            }
        }
    }
    
    /**
     前のページ
     */
    func updatePage(currentPage page: Int) {
        self.currentIndex = page
    }
    
    func shouldLoad(page: Int) -> Bool {
        if self.currentPage == page ||
            self.previousPage == page ||
            self.nextPage == page {
            return true
        }
        return false
    }

    fileprivate func setCenterContentOffset() {
        self.contentScrollView.contentOffset = CGPoint(x: self.centerContentOffsetX, y: self.contentScrollView.contentOffset.y)
    }
    
    fileprivate func isVisible(controller: UIViewController) -> Bool {
        return self.childViewControllers.contains(controller)
    }

    fileprivate func isVaildPage(_ page: Int) -> Bool {
        return page < self.controllers.count && page >= 0
    }
}


// MARK: - Scroll view delegate

extension PageTabViewController: UIScrollViewDelegate {
    private var nextPageThresholdX: CGFloat {
        return (self.contentScrollView.contentSize.width / 2) + self.pageSize.width * 1.5
    }
    
    private var prevPageThresholdX: CGFloat {
        return (self.contentScrollView.contentSize.width / 2) - self.pageSize.width * 1.5
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let visibleBounds = self.contentScrollView.bounds
        let minimumVisibleX = visibleBounds.minX
        let maximumVisibleX = visibleBounds.maxX
        if self.nextPageThresholdX <= maximumVisibleX && self.isVaildPage(self.nextPage) {
            self.currentIndex = self.nextPage
            self.constructPagingViewControllers()
            self.layoutPagingViewControllers()
            self.contentScrollView.contentOffset.x -= self.pageSize.width
        } else if self.prevPageThresholdX >= minimumVisibleX && self.isVaildPage(self.previousPage) {
            self.currentIndex = self.previousPage
            self.constructPagingViewControllers()
            self.layoutPagingViewControllers()
            self.contentScrollView.contentOffset.x += self.pageSize.width
        }
    }
}
