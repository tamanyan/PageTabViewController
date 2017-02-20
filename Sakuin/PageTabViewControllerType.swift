//
//  PageTabViewControllerType.swift
//  PageTabViewController
//
//  Created by Tamanyan on 2/20/29 H.
//  Copyright © 29 Heisei tamanyan. All rights reserved.
//

import Foundation

@objc public protocol PageTabViewControllerType: class {
    /**
     Delegate
     */
    var delegate: PageTabViewDelegate? { set get }

    /**
     Count of all pages
     */
    var pageCount: Int { get }

    /**
     current page index
     */
    var currentPage: Int { get }

    /**
     previous page index
     */
    var previousPage: Int { get }

    /**
     next page index
     */
    var nextPage: Int { get }

    /**
     last page index
     */
    var lastPage: Int { get }

    /**
     first page index
     */
    var firstPage: Int { get }
}
