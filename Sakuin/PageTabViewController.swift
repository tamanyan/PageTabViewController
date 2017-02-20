//
//  PageTabViewController.swift
//  PageTabViewController
//
//  Created by svpcadmin on 2/20/17.
//  Copyright © 2017 tamanyan. All rights reserved.
//

import Foundation
import UIKit

open class PageTabViewController: UIViewController {
    fileprivate var recyclablePageTabViewController: RecyclablePageTabViewController?
    fileprivate var nonRecyclablePageTabViewController: NonRecyclablePageTabViewController?

    open var delegate: PageTabViewDelegate? {
        set {
            self.recyclablePageTabViewController?.delegate = newValue
        }
        get {
            return self.recyclablePageTabViewController?.delegate
        }
    }

    public init(pageItems: [(viewController: UIViewController, menuTitle: String)], options: PageTabConfigurable) {
        super.init(nibName: nil, bundle: nil)
        if pageItems.count > 2 {
            self.recyclablePageTabViewController = RecyclablePageTabViewController(pageItems: pageItems, options: options)
        } else {
            self.nonRecyclablePageTabViewController = NonRecyclablePageTabViewController(pageItems: pageItems, options: options)
        }
        self.automaticallyAdjustsScrollViewInsets = false
    }

    override open func viewDidLoad() {
        super.viewDidLoad()

        guard let vc = self.recyclablePageTabViewController ?? self.nonRecyclablePageTabViewController else {
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
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
