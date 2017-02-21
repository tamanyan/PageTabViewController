Sakuin
===================================

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/hsylife/SwiftyPickerPopover)

Customizable Page Tab ViewController in Swift

Features

- Infinite Scroll Page/Menu
- Top/Bottom Menu
- Custom Color Menu

This framework is inspired by [kitasuke/PagingMenuController](https://github.com/kitasuke/PagingMenuController)

## Requirements

- iOS 9.0+
- Swift 3

## Sample

Define Child View Controller to be displayed in Tab.

```swift
import Sakuin
import UIKit

class FruitsTableViewController: UITableViewController, Pageable {
    var fruits = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }

    // MARK: - Pageable

    func pageTabWillShowPage(controller: UIViewController) {
        print("pageTabWillShowPage \(self.fruits[0])")
    }

    func pageTabWillHidePage(controller: UIViewController) {
        print("pageTabWillHidePage \(self.fruits[0])")
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
```

Define Custom Settings for PageTabController.

```swift
import Sakuin
import UIKit

struct StandardFixedWidthMenuOptions: PageTabConfigurable {
    struct MenuOptions: MenuViewConfigurable {
        var displayMode: MenuDisplayMode {
            return .standard(widthMode: .fixed(width: UIScreen.main.bounds.width / 3))
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

    var defaultPage: Int {
        return 0
    }
}
```

Setup PageTabController and Child View Controllers.

```swift
let menuTitles: [UIColor: String] = [
    .green: "1st Green Menu",
    .gray: "2nd Gray Menu",
    .red: "3rd Red Menu",
]

let items: [UIColor: [String]] = [
    .green: ["1st", "Apple", "Apricot", "Avocado", "Banana", "Blackberry", "Blueberry", "Cantaloupe", "Cherry", "Cherimoya"],
    .gray: ["2nd", "Clementine", "Coconut", "Cranberry", "Cucumber", "Custard apple", "Damson", "Date", "Dragonfruit", "Durian",
            "Elderberry", "Feijoa", "Fig", "Grape", "Grapefruit", "Guava", "Udara", "Honeyberry", "Huckleberry", "Jabuticaba",
            "Jackfruit", "Juniper berry", "Kiwi fruit", "Lemon", "Lime", "Lychee", "Mandarine",],
    .red: ["3rd", "Mango", "Marionberry"],
]

let colors: [UIColor] = [.green, .gray, .red]

let pageTabController = PageTabController(pageItems: colors.map({ [unowned self] in
    let vc = FruitsTableViewController()
    vc.fruits = items[$0]!
    return (viewController: vc, menuTitle: menuTitles[$0]!)
}), options: StandardFixedWidthMenuOptions())
```
