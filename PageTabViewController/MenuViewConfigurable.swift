//
//  MenuViewConfigurable.swift
//  PageTabViewController
//
//  Created by svpcadmin on 11/11/16.
//  Copyright © 2016 tamanyan. All rights reserved.
//

import Foundation

public protocol MenuViewConfigurable {
    var textColor: UIColor { get }
    var textFont: UIFont { get }
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

extension MenuViewConfigurable {
    var textColor: UIColor {
        return .black
    }

    var textFont: UIFont {
        return UIFont.systemFont(ofSize: 13)
    }

    var backgroundColor: UIColor {
        return .white
    }

    var selectedBackgroundColor: UIColor {
        return .white
    }

    var height: CGFloat {
        return 66
    }

    var displayMode: MenuDisplayMode {
        return .standard(widthMode: .fixed(width: 30))
    }

    var menuPosition: MenuPosition {
        return .top
    }
}
