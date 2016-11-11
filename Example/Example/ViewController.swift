//
//  ViewController.swift
//  Example
//
//  Created by svpcadmin on 11/11/16.
//  Copyright © 2016 tamanyan. All rights reserved.
//

import UIKit

import UIKit
import PageTabViewController

private struct MenuOptions: MenuViewConfigurable {
    var displayMode: MenuDisplayMode {
        return .infinite(widthMode: .flexible)
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

    var menuPosition: MenuPosition {
        return .top
    }
}

private struct PagingTabOptions: PageTabConfigurable {
    var menuOptions: MenuViewConfigurable {
        return MenuOptions()
    }
    
    var defaultPage: Int {
        return 0
    }
    
    var backgroundColor: UIColor {
        return .white
    }
}

class TestViewController: UIViewController {
}

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib
        // Do any additional setup after loading the view, typically from a nib.
        let colors: [UIColor] = [.green, .gray, .red, .blue]
        let pageTabController = PageTabViewController(viewControllers: colors.map({
            let vc = UIViewController()
            vc.view.backgroundColor = $0
            return vc
        }), options: PagingTabOptions())

        addChildViewController(pageTabController)
        view.addSubview(pageTabController.view)
        pageTabController.didMove(toParentViewController: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

