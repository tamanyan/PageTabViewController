//
//  InfiniteFlexibleWidthMenuOptions.swift
//  Example
//
//  Created by svpcadmin on 11/17/16.
//  Copyright © 2016 tamanyan. All rights reserved.
//

import Sakuin
import UIKit

struct InfiniteFlexibleWidthMenuOptions: PageTabConfigurable {
    struct MenuOptions: MenuViewConfigurable {
        var displayMode: MenuDisplayMode {
            return .infinite(widthMode: .flexible)
        }

        var textColor: UIColor {
            return .white
        }

        var selectedTextColor: UIColor {
            return .white
        }

        var backgroundColor: UIColor {
            return UIColor(red: 10/255.0, green: 56/255.0, blue: 91/255.0, alpha: 1)
        }

        var selectedBackgroundColor: UIColor {
            return UIColor.white.withAlphaComponent(0.3)
        }

        var height: CGFloat {
            return 44
        }

        var menuPosition: MenuPosition {
            return .top
        }
    }

    var menuOptions: MenuViewConfigurable {
        return MenuOptions()
    }
}
