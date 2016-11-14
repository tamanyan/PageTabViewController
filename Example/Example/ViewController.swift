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
        return 33
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
        return 1
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
        let colors: [UIColor] = [.green, .gray, .red, .blue, .yellow]
        let titles: [UIColor:String] = [
            .green: "Green Menu",
            .gray: "Gray Menu",
            .red: "Red Menu",
            .blue: "Blue Menu",
            .yellow: "Yellow Menu"
        ]
        let pageTabController = PageTabViewController(pageItems: colors.map({
            let vc = UIViewController()
            vc.view.backgroundColor = $0
            return (viewController: vc, menuTitle: titles[$0]!)
        }), options: PagingTabOptions())
        pageTabController.navigationItem.title = "PageTab Test"
        let navController = UINavigationController(rootViewController: pageTabController)

        addChildViewController(navController)
        view.addSubview(navController.view)
        navController.didMove(toParentViewController: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

