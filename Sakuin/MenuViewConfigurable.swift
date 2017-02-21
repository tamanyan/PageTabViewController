//
//  MenuViewConfigurable.swift
//  Sakuin
//
//  Created by svpcadmin on 11/11/16.
//  Copyright © 2016 tamanyan. All rights reserved.
//

import Foundation
import UIKit

public protocol MenuViewConfigurable {
    var textColor: UIColor { get }
    var selectedTextColor: UIColor { get }
    var textFont: UIFont { get }
    var selectedTextFont: UIFont { get }
    var backgroundColor: UIColor { get }
    var selectedBackgroundColor: UIColor { get }
    var height: CGFloat { get }
    var displayMode: MenuDisplayMode { get }
    var menuPosition: MenuPosition { get }
}

public enum MenuItemWidthMode {
    case flexible
    case fixed(width: CGFloat)
}

public enum MenuDisplayMode {
    case standard(widthMode: MenuItemWidthMode)
    case infinite(widthMode: MenuItemWidthMode)
}

public enum MenuPosition {
    case top
    case bottom
}

public extension MenuViewConfigurable {
    public var textColor: UIColor {
        return .black
    }

    public var selectedTextColor: UIColor {
        return .black
    }

    public var textFont: UIFont {
        return UIFont.systemFont(ofSize: 13)
    }

    public var selectedTextFont: UIFont {
        return UIFont.systemFont(ofSize: 13)
    }

    public var backgroundColor: UIColor {
        return .white
    }

    public var selectedBackgroundColor: UIColor {
        return .white
    }

    public var height: CGFloat {
        return 66
    }

    public var displayMode: MenuDisplayMode {
        return .standard(widthMode: .fixed(width: 30))
    }

    public var menuPosition: MenuPosition {
        return .top
    }
}
