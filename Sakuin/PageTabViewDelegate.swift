//
//  PageTabViewDelegate.swift
//  PageTabViewController
//
//  Created by svpcadmin on 12/7/16.
//  Copyright © 2016 tamanyan. All rights reserved.
//

import UIKit

@objc public protocol PageTabViewDelegate {
    @objc optional func pageTabViewWillShowPage(controller: PageTabViewControllerType, page: Int)
    @objc optional func pageTabViewWillHidePage(controller: PageTabViewControllerType, page: Int)
}
