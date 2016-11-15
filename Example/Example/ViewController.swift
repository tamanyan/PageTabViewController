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

    var textColor: UIColor {
        return .white
    }

    var backgroundColor: UIColor {
        return UIColor(red: 10/255.0, green: 56/255.0, blue: 91/255.0, alpha: 1)
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

class FruitsTableViewController: UITableViewController {
    var fruits = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }

    // MARK: - UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.fruits.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = self.fruits[indexPath.row]
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
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
        let items: [UIColor:[String]] = [
            .green: ["Apple", "Apricot", "Avocado", "Banana", "Blackberry", "Blueberry", "Cantaloupe", "Cherry", "Cherimoya"],
            .gray: ["Clementine", "Coconut", "Cranberry", "Cucumber", "Custard apple", "Damson", "Date", "Dragonfruit", "Durian",
                    "Elderberry", "Feijoa", "Fig", "Grape", "Grapefruit", "Guava", "Udara", "Honeyberry", "Huckleberry", "Jabuticaba",
                    "Jackfruit", "Juniper berry", "Kiwi fruit", "Lemon", "Lime", "Lychee", "Mandarine",],
            .red: ["Mango", "Marionberry"],
            .blue: ["Melon", "Nance", "Nectarine", "Olive", "Orange", "Papaya", "Peach"],
            .yellow: ["Pear", "Pineapple", "Raspberry", "Strawberry", "Tamarillo", "Tamarind", "Tomato",
                      "Ugli fruit", "Yuzu"],
        ]
        let pageTabController = PageTabViewController(pageItems: colors.map({
            let vc = FruitsTableViewController()
            vc.fruits = items[$0]!
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

