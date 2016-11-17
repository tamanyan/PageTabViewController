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

    public let menuTitles: [String]

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

    fileprivate let pageTabView: PageTabView

    fileprivate let options: PageTabConfigurable

    fileprivate var currentIndex: Int = 0 {
        didSet {
            self.pageTabView.moveTo(page: self.currentIndex)
        }
    }

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
        return self.contentScrollView.frame.size
    }

    private var centerContentOffsetX: CGFloat {
        return CGFloat(self.numberOfVisiblePages / 2) * self.contentScrollView.frame.width
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

    var lastPage: Int {
        return self.controllers.count - 1
    }

    var firstPage: Int {
        return 0
    }

    public init(pageItems: [(viewController: UIViewController, menuTitle: String)], options: PageTabConfigurable) {
        self.controllers = pageItems.map { $0.viewController }
        self.menuTitles = pageItems.map { $0.menuTitle }
        self.options = options
        self.currentIndex = options.defaultPage
        self.pageTabView = PageTabView(currentIndex: self.currentIndex, titles: self.menuTitles, options: self.options.menuOptions)

        super.init(nibName: nil, bundle: nil)

        self.automaticallyAdjustsScrollViewInsets = false
        self.view.backgroundColor = options.backgroundColor
        self.view.addSubview(self.contentScrollView)
        self.view.addSubview(self.pageTabView)

        // set layout of TabMenu and Content ScrollView
        self.layoutTabMenuView()
        self.layoutContentScrollView()

        self.constructPagingViewControllers()
        self.layoutPagingViewControllers()
        self.contentScrollView.delegate = self

        self.pageTabView.menuSelectedBlock = { [unowned self] (prevPage: Int, nextPage: Int) in
            if case .standard(_) = self.menuOptions.displayMode {
                if nextPage == self.lastPage {
                    self.updatePage(currentPage: nextPage - 1)
                } else if nextPage == self.firstPage {
                    self.updatePage(currentPage: nextPage + 1)
                } else {
                    self.updatePage(currentPage: nextPage)
                }

                self.constructPagingViewControllers()
                self.layoutPagingViewControllers()
                self.setCenterContentOffset()

                if nextPage == self.lastPage {
                    self.contentScrollView.contentOffset.x += self.pageSize.width
                } else if nextPage == self.firstPage {
                    self.contentScrollView.contentOffset.x -= self.pageSize.width
                }
            } else {
                self.updatePage(currentPage: nextPage)
                self.constructPagingViewControllers()
                self.layoutPagingViewControllers()
            }
        }
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        self.contentScrollView.contentSize = CGSize(
            width: self.contentScrollView.frame.width * CGFloat(self.visibleControllers.count),
            height: self.contentScrollView.frame.height)
        self.setCenterContentOffset()
    }

    fileprivate func layoutContentScrollView() {
        self.contentScrollView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addConstraints([
            // top
            NSLayoutConstraint(
                item: self.contentScrollView,
                attribute: .top,
                relatedBy: .equal,
                toItem: self.pageTabView,
                attribute: .bottom,
                multiplier:1.0,
                constant: 0.0),
            // left
            NSLayoutConstraint(
                item: self.contentScrollView,
                attribute: .leading,
                relatedBy: .equal,
                toItem: self.view,
                attribute: .leading,
                multiplier: 1.0,
                constant: 0),
            // right
            NSLayoutConstraint(
                item: self.view,
                attribute: .trailing,
                relatedBy: .equal,
                toItem: self.contentScrollView,
                attribute: .trailing,
                multiplier: 1.0,
                constant: 0),
            // bottom
            NSLayoutConstraint(
                item: self.view,
                attribute: .bottom,
                relatedBy: .equal,
                toItem: self.contentScrollView,
                attribute: .bottom,
                multiplier: 1.0,
                constant: 0),
            ])
    }

    fileprivate func layoutTabMenuView() {
        self.pageTabView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addConstraints([
            NSLayoutConstraint(item: self.pageTabView,
                               attribute: .height,
                               relatedBy: .equal,
                               toItem: nil,
                               attribute: .height,
                               multiplier: 1.0,
                               constant: self.menuOptions.height),
            NSLayoutConstraint(item: self.pageTabView,
                               attribute: .top,
                               relatedBy: .equal,
                               toItem: topLayoutGuide,
                               attribute: .bottom,
                               multiplier:1.0,
                               constant: 0.0),
            NSLayoutConstraint(item: self.pageTabView,
                               attribute: .leading,
                               relatedBy: .equal,
                               toItem: view,
                               attribute: .leading,
                               multiplier: 1.0,
                               constant: 0.0),
            NSLayoutConstraint(item: view,
                               attribute: .trailing,
                               relatedBy: .equal,
                               toItem: self.pageTabView,
                               attribute: .trailing,
                               multiplier: 1.0,
                               constant: 0.0),
            ])

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

            self.contentScrollView.addSubview(pagingView)
            addChildViewController(controller as UIViewController)
            controller.didMove(toParentViewController: self)

            self.visibleControllers.append(controller)
        }
    }

    fileprivate func layoutPagingViewControllers() {
        NSLayoutConstraint.deactivate(self.contentScrollView.constraints)

        for (index, controller) in controllers.enumerated() {
            guard let pageView = controller.view, self.shouldLoad(page: index) else {
                continue
            }

            switch index {
            case self.previousPage:
                self.contentScrollView.addConstraints([
                    // left
                    NSLayoutConstraint(
                        item: pageView,
                        attribute: .leading,
                        relatedBy: .equal,
                        toItem: self.contentScrollView,
                        attribute: .leading,
                        multiplier: 1.0,
                        constant: 0),
                    ])
                break
            case self.currentPage:
                guard let previousPagingView = self.controllers[self.previousPage].view,
                    let nextPagingView = self.controllers[self.nextPage].view else { continue }

                self.contentScrollView.addConstraints([
                    // left
                    NSLayoutConstraint(
                        item: previousPagingView,
                        attribute: .trailing,
                        relatedBy: .equal,
                        toItem: pageView,
                        attribute: .leading,
                        multiplier: 1.0,
                        constant: 0),
                    // right
                    NSLayoutConstraint(
                        item: pageView,
                        attribute: .trailing,
                        relatedBy: .equal,
                        toItem: nextPagingView,
                        attribute: .leading,
                        multiplier: 1.0,
                        constant: 0),
                    ])
                break
            case self.nextPage:
                self.contentScrollView.addConstraints([
                    // right
                    NSLayoutConstraint(
                        item: pageView,
                        attribute: .trailing,
                        relatedBy: .equal,
                        toItem: self.contentScrollView,
                        attribute: .trailing,
                        multiplier: 1.0,
                        constant: 0),
                    ])
                break
            default: break
            }
            self.contentScrollView.addConstraints([
                    // top
                    NSLayoutConstraint(
                        item: pageView,
                        attribute: .top,
                        relatedBy: .equal,
                        toItem: self.contentScrollView,
                        attribute: .top,
                        multiplier:1.0,
                        constant: 0.0),
                    // bottom
                    NSLayoutConstraint(
                        item: self.contentScrollView,
                        attribute: .bottom,
                        relatedBy: .equal,
                        toItem: pageView,
                        attribute: .bottom,
                        multiplier: 1.0,
                        constant: 0),
                    // width
                    NSLayoutConstraint(
                        item: pageView,
                        attribute: .width,
                        relatedBy: .equal,
                        toItem: self.contentScrollView,
                        attribute: .width,
                        multiplier: 1.0,
                        constant: 0),
                    // height
                    NSLayoutConstraint(
                        item: pageView,
                        attribute: .height,
                        relatedBy: .equal,
                        toItem: self.contentScrollView,
                        attribute: .height,
                        multiplier: 1.0,
                        constant: 0),
            ])
        }
    }

    func updatePage(currentPage page: Int) {
        self.currentIndex = page
        print("currentPage: \(page)")
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
        if visibleBounds.size.equalTo(CGSize.zero) {
            return
        }

        let minimumVisibleX = visibleBounds.minX
        let maximumVisibleX = visibleBounds.maxX
        if case .standard(_) = self.menuOptions.displayMode {
            if self.lastPage == self.currentPage &&
                maximumVisibleX <= (self.contentScrollView.contentSize.width / 2) + self.pageSize.width * 0.5 {

                self.updatePage(currentPage: self.previousPage)
                return
            } else if self.firstPage == self.currentPage &&
                minimumVisibleX >= (self.contentScrollView.contentSize.width / 2) - self.pageSize.width * 0.5 {

                self.updatePage(currentPage: self.nextPage)
                return
            }

            if self.nextPageThresholdX <= maximumVisibleX && self.isVaildPage(self.nextPage) {
                self.updatePage(currentPage: self.nextPage)

                guard self.isVaildPage(self.nextPage) else {
                    return
                }

                self.constructPagingViewControllers()
                self.layoutPagingViewControllers()
                self.contentScrollView.contentOffset.x -= self.pageSize.width
            } else if self.prevPageThresholdX >= minimumVisibleX && self.isVaildPage(self.previousPage) {
                self.updatePage(currentPage: self.previousPage)

                guard self.isVaildPage(self.previousPage) else {
                    return
                }

                self.constructPagingViewControllers()
                self.layoutPagingViewControllers()
                self.contentScrollView.contentOffset.x += self.pageSize.width
            }
        } else {
            if self.nextPageThresholdX <= maximumVisibleX && self.isVaildPage(self.nextPage) {
                self.updatePage(currentPage: self.nextPage)
                self.constructPagingViewControllers()
                self.layoutPagingViewControllers()
                self.contentScrollView.contentOffset.x -= self.pageSize.width
            } else if self.prevPageThresholdX >= minimumVisibleX && self.isVaildPage(self.previousPage) {
                self.updatePage(currentPage: self.previousPage)
                self.constructPagingViewControllers()
                self.layoutPagingViewControllers()
                self.contentScrollView.contentOffset.x += self.pageSize.width
            }
        }
    }
}
