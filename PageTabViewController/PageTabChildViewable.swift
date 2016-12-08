//
//  PageTabChildManageable.swift
//  PageTabViewController
//
//  Created by svpcadmin on 12/7/16.
//  Copyright © 2016 tamanyan. All rights reserved.
//

import UIKit

@objc public protocol PageTabChildManageable {
    @objc optional func pageTabViewWillShowPage()
    @objc optional func pageTabViewWillHidePage()
}
