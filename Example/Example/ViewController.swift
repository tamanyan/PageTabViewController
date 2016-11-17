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
        // return .standard(widthMode: .fixed(width: UIScreen.main.bounds.width / 4))
        return .standard(widthMode: .flexible)
    }

    var textColor: UIColor {
        return .white
    }

    var backgroundColor: UIColor {
        return UIColor(red: 10/255.0, green: 56/255.0, blue: 91/255.0, alpha: 1)
    }

    var selectedBackgroundColor: UIColor {
        return UIColor(red: 4/255.0, green: 25/255.0, blue: 38/255.0, alpha: 1)
    }

    var height: CGFloat {
        return 44
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
        // let colors: [UIColor] = [.green, .gray, .red, .blue, .yellow, .lightGray]
        let colors: [UIColor] = [.green, .gray, .red, .blue]
        let titles: [UIColor:String] = [
            .green: "1st Green Menu",
            .gray: "2nd Gray Menu",
            .red: "3rd Red Menu",
            .blue: "4th Blue Menu",
            .yellow: "5th Yellow Menu",
            .lightGray: "6th LightGray Menu",
        ]
        let items: [UIColor:[String]] = [
            .green: ["1st", "Apple", "Apricot", "Avocado", "Banana", "Blackberry", "Blueberry", "Cantaloupe", "Cherry", "Cherimoya"],
            .gray: ["2nd", "Clementine", "Coconut", "Cranberry", "Cucumber", "Custard apple", "Damson", "Date", "Dragonfruit", "Durian",
                    "Elderberry", "Feijoa", "Fig", "Grape", "Grapefruit", "Guava", "Udara", "Honeyberry", "Huckleberry", "Jabuticaba",
                    "Jackfruit", "Juniper berry", "Kiwi fruit", "Lemon", "Lime", "Lychee", "Mandarine",],
            .red: ["3rd", "Mango", "Marionberry"],
            .blue: ["4th", "Melon", "Nance", "Nectarine", "Olive", "Orange", "Papaya", "Peach"],
            .yellow: ["5th", "Pear", "Pineapple", "Raspberry", "Strawberry", "Tamarillo", "Tamarind", "Tomato",
                      "Ugli fruit", "Yuzu"],
            .lightGray: ["6th"],
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

