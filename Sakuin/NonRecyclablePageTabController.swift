//
//  NonRecyclablePageTabController.swift
//  PageTabController
//
//  Created by svpcadmin on 2/20/17.
//  Copyright © 2017 tamanyan. All rights reserved.
//

import UIKit

class NonRecyclablePageTabController: UIViewController, PageTabControllerType {
    let controllers: [UIViewController]

    let menuTitles: [String]

    var delegate: PageTabDelegate?

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

    let options: PageTabConfigurable

    fileprivate var showingPages = Set<Int>()

    fileprivate let menuView: MenuView

    fileprivate var currentIndex: Int = 0 {
        didSet {
            self.menuView.moveTo(page: self.currentIndex)
        }
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
    var pageSize: CGSize {
        return self.contentScrollView.frame.size
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
        return self.currentPage - 1
    }

    /**
     next page index
     */
    var nextPage: Int {
        return self.currentPage + 1
    }

    var lastPage: Int {
        return self.controllers.count - 1
    }

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
        self.view.addSubview(self.contentScrollView)
        self.view.addSubview(self.menuView)

        // set layout of TabMenu and Content ScrollView
        self.layoutTabMenuView()
        self.layoutContentScrollView()

        self.setPageView(page: self.currentPage)
        self.contentScrollView.delegate = self

        self.menuView.menuSelectedBlock = { [unowned self] (prevPage: Int, nextPage: Int) in
            self.setPageView(page: nextPage)
            // will be hidden pages
            let hidingPages = self.showingPages.filter { $0 != nextPage }
            hidingPages.forEach {
                self.delegate?.pageTabWillHidePage(controller: self, page: $0)
                if let viewable = self.controllers[$0] as? PageTabChildDelegate {
                    viewable.pageTabWillHidePage()
                }
            }
            // will show pages
            self.delegate?.pageTabWillShowPage(controller: self, page: nextPage)
            if let viewable = self.controllers[nextPage] as? PageTabChildDelegate {
                viewable.pageTabWillShowPage()
            }
            self.showingPages = [nextPage]
        }
        self.menuView.moveToInitialPosition()
        self.menuView.moveTo(page: self.currentPage)

        if self.currentPage < self.controllers.count {
            if let viewable = self.controllers[self.currentPage] as? PageTabChildDelegate {
                viewable.pageTabWillShowPage()
            }
            self.showingPages.insert(self.currentPage)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        self.contentScrollView.contentSize = CGSize(
            width: self.contentScrollView.frame.width * CGFloat(self.visibleControllers.count),
            height: self.contentScrollView.frame.height)

        self.contentScrollView.contentOffset.x = self.contentScrollView.frame.width * CGFloat(currentPage)
    }

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    fileprivate func setPageView(page: Int) {
        self.updatePage(currentPage: page)
        self.constructPagingViewControllers()
        self.layoutPagingViewControllers()
        self.contentScrollView.contentOffset.x = self.contentScrollView.frame.width * CGFloat(currentPage)
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
    }

    fileprivate func constructPagingViewControllers() {
        for (_, controller) in controllers.enumerated() {
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
            guard let pageView = controller.view else {
                continue
            }

            if index == self.firstPage {
                pageView.leftAnchor.constraint(equalTo: self.contentScrollView.leftAnchor).isActive = true

                if let nextPagingView = self.controller(withPage: index + 1)?.view, index + 1 == self.lastPage {
                    pageView.rightAnchor.constraint(equalTo: nextPagingView.leftAnchor).isActive = true
                }
            } else if index == self.lastPage {
                pageView.rightAnchor.constraint(equalTo: self.contentScrollView.rightAnchor).isActive = true

                if let previousPagingView = self.controller(withPage: index - 1)?.view, index - 1 == self.firstPage {
                    pageView.leftAnchor.constraint(equalTo: previousPagingView.rightAnchor).isActive = true
                }
            } else {
                guard let previousPagingView = self.controller(withPage: index - 1)?.view,
                    let nextPagingView = self.controller(withPage: index + 1)?.view else { continue }

                pageView.leftAnchor.constraint(equalTo: previousPagingView.rightAnchor).isActive = true
                pageView.rightAnchor.constraint(equalTo: nextPagingView.leftAnchor).isActive = true
            }
            pageView.topAnchor.constraint(equalTo: self.contentScrollView.topAnchor).isActive = true
            pageView.bottomAnchor.constraint(equalTo: self.contentScrollView.bottomAnchor).isActive = true
            pageView.widthAnchor.constraint(equalTo: self.contentScrollView.widthAnchor).isActive = true
            pageView.heightAnchor.constraint(equalTo: self.contentScrollView.heightAnchor).isActive = true
        }
    }

    func controller(withPage page: Int) -> UIViewController? {
        return page >= 0 && page < self.controllers.count ? self.controllers[page] : nil
    }

    func updatePage(currentPage page: Int) {
        self.currentIndex = page
    }

    fileprivate func isVaildPage(_ page: Int) -> Bool {
        return page < self.controllers.count && page >= 0
    }
}


// MARK: - Scroll view delegate

extension NonRecyclablePageTabController: UIScrollViewDelegate {
    private var nextPageThresholdX: CGFloat {
        return (self.contentScrollView.contentSize.width / 2) + self.pageSize.width * 1.5
    }

    private var prevPageThresholdX: CGFloat {
        return (self.contentScrollView.contentSize.width / 2) - self.pageSize.width * 1.5
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
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
                self.delegate?.pageTabWillShowPage(controller: self, page: i)
                if let viewable = self.controllers[i] as? PageTabChildDelegate {
                    viewable.pageTabWillShowPage()
                }
            }
        }
        for i in self.showingPages {
            if (intersection.contains(i) == false) {
                self.delegate?.pageTabWillHidePage(controller: self, page: i)
                if let viewable = self.controllers[i] as? PageTabChildDelegate {
                    viewable.pageTabWillHidePage()
                }
            }
        }
        self.showingPages = nowShowingPages

        let minimumVisibleX = visibleBounds.minX
        let maximumVisibleX = visibleBounds.maxX
        if self.lastPage == self.currentPage &&
            maximumVisibleX <= (self.contentScrollView.contentSize.width / 2) + self.pageSize.width * 0.5 {

            self.updatePage(currentPage: self.previousPage)
            return
        } else if self.firstPage == self.currentPage &&
            minimumVisibleX >= (self.contentScrollView.contentSize.width / 2) - self.pageSize.width * 0.5 {

            self.updatePage(currentPage: self.nextPage)
            return
        }
    }
}
