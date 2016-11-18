//
//  PageTabConfigurable.swift
//  PageTabViewController
//
//  Created by svpcadmin on 11/11/16.
//  Copyright © 2016 tamanyan. All rights reserved.
//

import Foundation

public protocol PageTabConfigurable {
    var defaultPage: Int { get }
    
    var backgroundColor: UIColor { get }
    
    var menuOptions: MenuViewConfigurable { get }
}

public extension PageTabConfigurable {
    public var defaultPage: Int {
        return 0
    }

    public var backgroundColor: UIColor {
        return .white
    }
}
