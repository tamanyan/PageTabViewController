//
//  Sakuin.swift
//  Sakuin
//
//  Created by svpcadmin on 2/20/17.
//  Copyright © 2017 tamanyan. All rights reserved.
//

import Foundation
import UIKit

open class PageTabController: UIViewController {
    /**
     for more than 3 pages
     */
    fileprivate var recyclablePageTabController: RecyclablePageTabController?

    /**
     for less than 2 pages
     */
    fileprivate var nonRecyclablePageTabController: NonRecyclablePageTabController?

    fileprivate var pageTabController: PageTabControllerType? {
        return self.recyclablePageTabController ?? self.nonRecyclablePageTabController
    }

    /**
     Count of all pages
     */
    public var pageCount: Int {
        return self.pageTabController?.pageCount ?? 0
    }

    /**
     current page index
     */
    public var currentPage: Int {
        return self.pageTabController?.currentPage ?? 0
    }

    /**
     previous page index
     */
    public var previousPage: Int {
        return self.pageTabController?.previousPage ?? 0
    }

    /**
     next page index
     */
    public var nextPage: Int {
        return self.pageTabController?.nextPage ?? 0
    }

    /**
     last page index
     */
    public var lastPage: Int {
        return self.pageTabController?.lastPage ?? 0
    }

    /**
     first page index
     */
    public var firstPage: Int {
        return self.pageTabController?.firstPage ?? 0
    }

    /**
     Options
     */
    public var options: PageTabConfigurable? {
        return self.pageTabController?.options
    }

    public init(pageItems: [(viewController: UIViewController, menuTitle: String)], options: PageTabConfigurable) {
        super.init(nibName: nil, bundle: nil)

        if pageItems.count > 2 {
            self.recyclablePageTabController = RecyclablePageTabController(pageItems: pageItems, options: options)
        } else {
            self.nonRecyclablePageTabController = NonRecyclablePageTabController(pageItems: pageItems, options: options)
        }
        self.automaticallyAdjustsScrollViewInsets = false
    }

    public func reload(pageItems: [(viewController: UIViewController, menuTitle: String)], options: PageTabConfigurable? = nil) {
        guard let newOptions = self.pageTabController?.options ?? options else {
            return
        }

        if pageItems.count > 2 {
            self.recyclablePageTabController = RecyclablePageTabController(pageItems: pageItems, options: newOptions)
        } else {
            self.nonRecyclablePageTabController = NonRecyclablePageTabController(pageItems: pageItems, options: newOptions)
        }

        self.reloadChildViewController()
    }

    override open func viewDidLoad() {
        super.viewDidLoad()

        self.reloadChildViewController()
    }

    func reloadChildViewController() {
        if let controller = self.childViewControllers.first {
            controller.willMove(toParentViewController: nil)
            controller.view.removeFromSuperview()
            controller.removeFromParentViewController()
        }

        guard let vc = self.recyclablePageTabController ?? self.nonRecyclablePageTabController else {
            return
        }

        self.addChildViewController(vc)
        self.view.addSubview(vc.view)
        vc.didMove(toParentViewController: self)

        vc.view.translatesAutoresizingMaskIntoConstraints = false
        vc.view.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        vc.view.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        vc.view.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        vc.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        vc.view.layoutIfNeeded()

        self.pageTabController?.setupChildViews()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
