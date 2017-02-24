//
//  Pageable.swift
//  Sakuin
//
//  Created by svpcadmin on 12/7/16.
//  Copyright © 2016 tamanyan. All rights reserved.
//

import UIKit

public protocol Pageable {
    func pageTabWillShowPage(controller: UIViewController, page: Int)
    func pageTabWillHidePage(controller: UIViewController, page: Int)
    func pageTabDidMovePage(controller: UIViewController, page: Int)
}

extension Pageable where Self: UIViewController {
    public var parentTabController: UIViewController? {
        return self.parent?.parent
    }
}
