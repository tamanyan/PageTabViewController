//
//  PageTabViewDelegate.swift
//  PageTabController
//
//  Created by svpcadmin on 12/7/16.
//  Copyright © 2016 tamanyan. All rights reserved.
//

import UIKit

public protocol PageTabDelegate {
    func pageTabWillShowPage(controller: PageTabControllerType, page: Int)
    func pageTabWillHidePage(controller: PageTabControllerType, page: Int)
}
