//
//  RecyclablePageTabController.swift
//  Sakuin
//
//  Created by svpcadmin on 11/11/16.
//  Copyright © 2016 tamanyan. All rights reserved.
//

import UIKit

class RecyclablePageTabController: UIViewController, PageTabControllerType {
    let controllers: [UIViewController]

    let menuTitles: [String]

    internal(set) var currentViewController: UIViewController!

    fileprivate(set) var visibleControllers = [UIViewController]()

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

    fileprivate let menuView: MenuView

    fileprivate var ready: Bool = false

    let options: PageTabConfigurable

    fileprivate var currentIndex: Int = 0 {
        didSet {
            guard ready else {
                return
            }

            self.menuView.moveTo(page: self.currentIndex)
            if let child = self.controllers[self.currentIndex] as? Pageable {
                child.pageTabDidMovePage(controller: self.controllers[self.currentIndex], page: self.currentIndex)
            }
        }
    }

    /**
     Menu Options
     */
    fileprivate var menuOptions: MenuViewConfigurable {
        return self.options.menuOptions
    }

    fileprivate var centerContentOffsetX: CGFloat {
        return CGFloat(self.numberOfVisiblePages / 2) * self.contentScrollView.frame.width
    }

    /**
     number of valid page
     */
    var numberOfVisiblePages: Int {
        return 3
    }

    /**
     unit page size
     */
    var pageSize: CGSize {
        return self.contentScrollView.frame.size
    }

    /**
     Count of all pages
     */
    var pageCount: Int {
        return self.controllers.count
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

    /**
     last page index
     */
    var lastPage: Int {
        return self.controllers.count - 1
    }

    /**
     first page index
     */
    var firstPage: Int {
        return 0
    }

    init(pageItems: [(viewController: UIViewController, menuTitle: String)], options: PageTabConfigurable) {
        self.controllers = pageItems.map { $0.viewController }
        self.menuTitles = pageItems.map { $0.menuTitle }
        self.options = options
        self.currentIndex = options.defaultPage
        self.menuView = MenuView(titles: self.menuTitles, options: self.options.menuOptions)

        super.init(nibName: nil, bundle: nil)

        self.automaticallyAdjustsScrollViewInsets = false
        self.view.backgroundColor = options.backgroundColor
    }

    func setupChildViews() {
        self.view.addSubview(self.contentScrollView)
        self.view.addSubview(self.menuView)

        // set layout of TabMenu and Content ScrollView
        self.layoutTabMenuView()
        self.layoutContentScrollView()

        self.setPageView(page: self.currentPage)

        self.menuView.menuSelectedBlock = { [unowned self] (prevPage: Int, nextPage: Int) in
            self.setPageView(page: nextPage)
            // will be hidden pages
            let hidingPages = self.showingPages.filter { $0 != nextPage }
            hidingPages.forEach {
                if let child = self.controllers[$0] as? Pageable {
                    child.pageTabWillHidePage(controller: self.controllers[$0], page: $0)
                }
            }
            // will show pages
            if let child = self.controllers[nextPage] as? Pageable {
                child.pageTabWillShowPage(controller: self.controllers[nextPage], page: nextPage)
            }
            self.showingPages = [nextPage]
        }
        self.menuView.moveToInitialPosition()
        self.menuView.moveTo(page: self.currentPage)

        if self.currentPage < self.controllers.count {
            if let child = self.controllers[self.currentPage] as? Pageable {
                child.pageTabWillShowPage(controller: self.controllers[self.currentPage], page: self.currentPage)
                child.pageTabDidMovePage(controller: self.controllers[self.currentPage], page: self.currentPage)
            }
            self.showingPages.insert(self.currentPage)
        }
        self.ready = true
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        self.contentScrollView.contentSize = CGSize(
            width: self.contentScrollView.frame.width * CGFloat(self.visibleControllers.count),
            height: self.contentScrollView.frame.height)

        self.contentScrollView.delegate = nil
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
        self.contentScrollView.delegate = self
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
            self.contentScrollView.topAnchor.constraint(equalTo: self.menuView.bottomAnchor).isActive = true
            self.contentScrollView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
            self.contentScrollView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
            self.contentScrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        } else {
            self.contentScrollView.topAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor).isActive = true
            self.contentScrollView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
            self.contentScrollView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
            self.contentScrollView.bottomAnchor.constraint(equalTo: self.menuView.topAnchor).isActive = true
        }
        self.contentScrollView.layoutIfNeeded()
    }

    fileprivate func layoutTabMenuView() {
        self.menuView.translatesAutoresizingMaskIntoConstraints = false
        if self.menuOptions.menuPosition == .top {
            self.menuView.heightAnchor.constraint(equalToConstant: self.menuOptions.height).isActive = true
            self.menuView.topAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor).isActive = true
            self.menuView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
            self.menuView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        } else {
            self.menuView.heightAnchor.constraint(equalToConstant: self.menuOptions.height).isActive = true
            self.menuView.bottomAnchor.constraint(equalTo: self.bottomLayoutGuide.topAnchor).isActive = true
            self.menuView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
            self.menuView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        }
        self.menuView.layoutIfNeeded()
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
            pageView.layoutIfNeeded()
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

extension RecyclablePageTabController: UIScrollViewDelegate {
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
                if let child = self.controllers[i] as? Pageable {
                    child.pageTabWillShowPage(controller: self.controllers[i], page: i)
                }
            }
        }
        for i in self.showingPages {
            if (intersection.contains(i) == false) {
                if let child = self.controllers[i] as? Pageable {
                    child.pageTabWillHidePage(controller: self.controllers[i], page: i)
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
