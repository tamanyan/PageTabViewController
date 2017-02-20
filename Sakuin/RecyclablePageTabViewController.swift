//
//  RecyclablePageTabViewController.swift
//  PageTabViewController
//
//  Created by svpcadmin on 11/11/16.
//  Copyright © 2016 tamanyan. All rights reserved.
//

import UIKit

class RecyclablePageTabViewController: UIViewController, PageTabViewControllerType {
    public let controllers: [UIViewController]

    public let menuTitles: [String]

    public var delegate: PageTabViewDelegate?

    public internal(set) var currentViewController: UIViewController!

    public fileprivate(set) var visibleControllers = [UIViewController]()

    let contentScrollView: UIScrollView = {
        $0.isPagingEnabled = true
        $0.isDirectionalLockEnabled = true
        $0.showsHorizontalScrollIndicator = false
        $0.showsVerticalScrollIndicator = false
        $0.scrollsToTop = false
        $0.bounces = true
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(UIScrollView(frame: .zero))

    fileprivate var showingPages = Set<Int>()

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
        self.pageTabView = PageTabView(titles: self.menuTitles, options: self.options.menuOptions)

        super.init(nibName: nil, bundle: nil)

        self.automaticallyAdjustsScrollViewInsets = false
        self.view.backgroundColor = options.backgroundColor
        self.view.addSubview(self.contentScrollView)
        self.view.addSubview(self.pageTabView)

        // set layout of TabMenu and Content ScrollView
        self.layoutTabMenuView()
        self.layoutContentScrollView()

        self.setPageView(page: self.currentPage)
        self.contentScrollView.delegate = self

        self.pageTabView.menuSelectedBlock = { [unowned self] (prevPage: Int, nextPage: Int) in
            self.setPageView(page: nextPage)
            // will be hidden pages
            let hidingPages = self.showingPages.filter { $0 != nextPage }
            hidingPages.forEach {
                self.delegate?.pageTabViewWillHidePage?(controller: self, page: $0)
                if let viewable = self.controllers[$0] as? PageTabChildDelegate {
                    viewable.pageTabViewWillHidePage?()
                }
            }
            // will show pages
            self.delegate?.pageTabViewWillShowPage?(controller: self, page: nextPage)
            if let viewable = self.controllers[nextPage] as? PageTabChildDelegate {
                viewable.pageTabViewWillShowPage?()
            }
            self.showingPages = [nextPage]
        }
        self.pageTabView.moveToInitialPosition()
        self.pageTabView.moveTo(page: self.currentPage)

        if self.currentPage < self.controllers.count {
            if let viewable = self.controllers[self.currentPage] as? PageTabChildDelegate {
                viewable.pageTabViewWillShowPage?()
            }
            self.showingPages.insert(self.currentPage)
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
        if case .standard(_) = self.menuOptions.displayMode {
            if self.currentPage == self.lastPage {
                self.contentScrollView.contentOffset.x = self.pageSize.width * 2
            } else if self.currentPage == self.firstPage {
                self.contentScrollView.contentOffset.x = 0
            } else {
                self.setCenterContentOffset()
            }
        } else {
            self.setCenterContentOffset()
        }
    }

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    fileprivate func setPageView(page: Int) {
        if case .standard(_) = self.menuOptions.displayMode {
            if page == self.lastPage {
                self.updatePage(currentPage: page - 1)
            } else if page == self.firstPage {
                self.updatePage(currentPage: page + 1)
            } else {
                self.updatePage(currentPage: page)
            }

            self.contentScrollView.delegate = nil
            self.constructPagingViewControllers()
            self.layoutPagingViewControllers()
            self.setCenterContentOffset()
            self.contentScrollView.delegate = self

            if page == self.lastPage {
                self.contentScrollView.delegate = nil
                self.contentScrollView.contentOffset.x += self.pageSize.width
                self.updatePage(currentPage: page)
                self.contentScrollView.delegate = self
            } else if page == self.firstPage {
                self.contentScrollView.delegate = nil
                self.contentScrollView.contentOffset.x -= self.pageSize.width
                self.updatePage(currentPage: page)
                self.contentScrollView.delegate = self
            }
        } else {
            self.updatePage(currentPage: page)
            self.constructPagingViewControllers()
            self.layoutPagingViewControllers()
        }
    }

    fileprivate func layoutContentScrollView() {
        self.contentScrollView.translatesAutoresizingMaskIntoConstraints = false
        if self.menuOptions.menuPosition == .top {
            self.contentScrollView.topAnchor.constraint(equalTo: self.pageTabView.bottomAnchor).isActive = true
            self.contentScrollView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
            self.contentScrollView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
            self.contentScrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        } else {
            self.contentScrollView.topAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor).isActive = true
            self.contentScrollView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
            self.contentScrollView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
            self.contentScrollView.bottomAnchor.constraint(equalTo: self.pageTabView.topAnchor).isActive = true
        }
    }

    fileprivate func layoutTabMenuView() {
        self.pageTabView.translatesAutoresizingMaskIntoConstraints = false
        if self.menuOptions.menuPosition == .top {
            self.pageTabView.heightAnchor.constraint(equalToConstant: self.menuOptions.height).isActive = true
            self.pageTabView.topAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor).isActive = true
            self.pageTabView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
            self.pageTabView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        } else {
            self.pageTabView.heightAnchor.constraint(equalToConstant: self.menuOptions.height).isActive = true
            self.pageTabView.bottomAnchor.constraint(equalTo: self.bottomLayoutGuide.topAnchor).isActive = true
            self.pageTabView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
            self.pageTabView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        }
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
                pageView.leftAnchor.constraint(equalTo: self.contentScrollView.leftAnchor).isActive = true
                break
            case self.currentPage:
                guard let previousPagingView = self.controllers[self.previousPage].view,
                    let nextPagingView = self.controllers[self.nextPage].view else { continue }

                pageView.leftAnchor.constraint(equalTo: previousPagingView.rightAnchor).isActive = true
                pageView.rightAnchor.constraint(equalTo: nextPagingView.leftAnchor).isActive = true
                break
            case self.nextPage:
                pageView.rightAnchor.constraint(equalTo: self.contentScrollView.rightAnchor).isActive = true
                break
            default: break
            }
            pageView.topAnchor.constraint(equalTo: self.contentScrollView.topAnchor).isActive = true
            pageView.bottomAnchor.constraint(equalTo: self.contentScrollView.bottomAnchor).isActive = true
            pageView.widthAnchor.constraint(equalTo: self.contentScrollView.widthAnchor).isActive = true
            pageView.heightAnchor.constraint(equalTo: self.contentScrollView.heightAnchor).isActive = true
        }
    }

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

extension RecyclablePageTabViewController: UIScrollViewDelegate {
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

        var nowShowingPages = Set<Int>()
        for (i, controller) in self.controllers.enumerated() {
            if controller.view.frame.intersects(visibleBounds) && self.visibleControllers.contains(controller) {
                nowShowingPages.insert(i)
            }
        }
        let intersection = nowShowingPages.intersection(self.showingPages)
        for i in nowShowingPages {
            if (intersection.contains(i) == false) {
                self.delegate?.pageTabViewWillShowPage?(controller: self, page: i)
                if let viewable = self.controllers[i] as? PageTabChildDelegate {
                    viewable.pageTabViewWillShowPage?()
                }
            }
        }
        for i in self.showingPages {
            if (intersection.contains(i) == false) {
                self.delegate?.pageTabViewWillHidePage?(controller: self, page: i)
                if let viewable = self.controllers[i] as? PageTabChildDelegate {
                    viewable.pageTabViewWillHidePage?()
                }
            }
        }
        self.showingPages = nowShowingPages

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
                self.contentScrollView.delegate = nil
                self.contentScrollView.contentOffset.x -= self.pageSize.width
                self.contentScrollView.delegate = self
            } else if self.prevPageThresholdX >= minimumVisibleX && self.isVaildPage(self.previousPage) {
                self.updatePage(currentPage: self.previousPage)

                guard self.isVaildPage(self.previousPage) else {
                    return
                }

                self.constructPagingViewControllers()
                self.layoutPagingViewControllers()
                self.contentScrollView.delegate = nil
                self.contentScrollView.contentOffset.x += self.pageSize.width
                self.contentScrollView.delegate = self
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
