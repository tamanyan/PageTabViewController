//
//  PageTabViewDelegate.swift
//  PageTabViewController
//
//  Created by svpcadmin on 12/7/16.
//  Copyright © 2016 tamanyan. All rights reserved.
//

import UIKit

public protocol PageTabViewDelegate {
    func pageTabViewMovePage(controller: PageTabViewController, nextPage: Int, previousPage: Int)
    func pageTabViewWillShowPage(controller: PageTabViewController, page: Int)
    func pageTabViewWillHidePage(controller: PageTabViewController, page: Int)
}
