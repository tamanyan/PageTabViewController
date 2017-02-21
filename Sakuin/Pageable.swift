//
//  Pageable.swift
//  Sakuin
//
//  Created by svpcadmin on 12/7/16.
//  Copyright © 2016 tamanyan. All rights reserved.
//

import UIKit

public protocol Pageable {
    func pageTabWillShowPage(controller: UIViewController)
    func pageTabWillHidePage(controller: UIViewController)
}
