//
//  ViewController.swift
//  Example
//
//  Created by svpcadmin on 11/11/16.
//  Copyright © 2016 tamanyan. All rights reserved.
//

import Sakuin
import UIKit

class FruitsTableViewController: UITableViewController, Pageable {
    var fruits = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }

    // MARK: - Pageable

    func pageTabWillShowPage(controller: UIViewController, page: Int) {
        print("pageTabWillShowPage \(page)")
    }

    func pageTabWillHidePage(controller: UIViewController, page: Int) {
        print("pageTabWillHidePage \(page)")
    }

    public func pageTabDidMovePage(controller: UIViewController, page: Int) {
        print("pageTabDidMovePage \(page)")
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

class ViewController: UITableViewController, UIGestureRecognizerDelegate {
    let titles: [String] = [
        "standard + fixwidth menu",
        "standard + few page fixwidth menu",
        "standard + flexible width menu",
        "standard + flexible width bottom menu",
        "infinite + flexible width menu"
    ]

    let menuTitles: [UIColor: String] = [
        .green: "1st Green Menu",
        .gray: "2nd Gray Menu",
        .red: "3rd Red Menu",
        .blue: "4th Blue Menu",
        .yellow: "5th Yellow Menu",
        .lightGray: "6th LightGray Menu",
    ]

    let items: [UIColor: [String]] = [
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

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "PageTabController"
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }

    // MARK: - UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.titles.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = self.titles[indexPath.row]
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 {
            let colors: [UIColor] = [.green, .gray, .red]
            let pageTabController = PageTabController(pageItems: colors.map({ [unowned self] in
                let vc = FruitsTableViewController()
                vc.fruits = self.items[$0]!
                return (viewController: vc, menuTitle: self.menuTitles[$0]!)
            }), options: StandardFixedWidthMenuOptions())
            pageTabController.navigationItem.title = self.titles[indexPath.row]
            self.showPageTabController(pageTabController)
        } else if indexPath.row == 1 {
            let colors: [UIColor] = [.green, .gray]
            let pageTabController = PageTabController(pageItems: colors.map({ [unowned self] in
                let vc = FruitsTableViewController()
                vc.fruits = self.items[$0]!
                return (viewController: vc, menuTitle: self.menuTitles[$0]!)
            }), options: StandardFixedWidthMenuOptions())
            pageTabController.navigationItem.title = self.titles[indexPath.row]
            self.showPageTabController(pageTabController)
        } else if indexPath.row == 2 {
            let colors: [UIColor] = [.green, .gray, .red, .blue, .yellow, .lightGray]
            let pageTabController = PageTabController(pageItems: colors.map({ [unowned self] in
                let vc = FruitsTableViewController()
                vc.fruits = self.items[$0]!
                return (viewController: vc, menuTitle: self.menuTitles[$0]!)
            }), options: StandardFlexibleWidthMenuOptions())
            pageTabController.navigationItem.title = self.titles[indexPath.row]
            self.showPageTabController(pageTabController)
        } else if indexPath.row == 3 {
            let colors: [UIColor] = [.green, .gray, .red, .blue, .yellow, .lightGray]
            let pageTabController = PageTabController(pageItems: colors.map({ [unowned self] in
                let vc = FruitsTableViewController()
                vc.fruits = self.items[$0]!
                return (viewController: vc, menuTitle: self.menuTitles[$0]!)
            }), options: StandardFlexibleWidthBottomMenuOptions())
            pageTabController.navigationItem.title = self.titles[indexPath.row]
            self.showPageTabController(pageTabController)
        } else if indexPath.row == 4 {
            let colors: [UIColor] = [.green, .gray, .red, .blue, .yellow, .lightGray]
            let pageTabController = PageTabController(pageItems: colors.map({ [unowned self] in
                let vc = FruitsTableViewController()
                vc.fruits = self.items[$0]!
                return (viewController: vc, menuTitle: self.menuTitles[$0]!)
            }), options: InfiniteFlexibleWidthMenuOptions())
            pageTabController.navigationItem.title = self.titles[indexPath.row]
            self.showPageTabController(pageTabController)
        }
    }

    func showPageTabController(_ pageTabController: PageTabController) {
        self.navigationController?.pushViewController(pageTabController, animated: true)
    }
}

