//
//  PageTabView.swift
//  PageTabViewController
//
//  Created by svpcadmin on 11/11/16.
//  Copyright © 2016 tamanyan. All rights reserved.
//

import UIKit

class PageTabView: UIView {
    fileprivate var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.register(PageTabCollectionCell.self, forCellWithReuseIdentifier: PageTabCollectionCell.cellIdentifier)
        collectionView.scrollsToTop = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.decelerationRate = UIScrollViewDecelerationRateFast
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()

    lazy fileprivate var roundRectView: UIView = {
        $0.isUserInteractionEnabled = true
        return $0
    }(UIView(frame: .zero))

    fileprivate let titles: [String]

    let options: MenuViewConfigurable

    var currentIndex: Int

    var menuSelectedBlock: ((_ prevPage: Int, _ nextPage: Int) -> Void)?

    var menuItemWidth: CGFloat {
        let mode: MenuItemWidthMode = { [unowned self] in
            switch self.options.displayMode {
            case .infinite(let widthMode):
                return widthMode
            case .standard(let widthMode):
                return widthMode
            }
        }()
        switch mode {
        case .fixed(let width):
            return width
        case .flexible:
            return 0
        }
    }

    init(currentIndex: Int, titles: [String], options: MenuViewConfigurable) {
        self.currentIndex = currentIndex
        self.titles = titles
        self.options = options
        super.init(frame: CGRect.zero)

        self.backgroundColor = options.backgroundColor
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.backgroundColor = options.backgroundColor
        self.addSubview(self.collectionView)
        self.setupRoundRectView()

        let top = NSLayoutConstraint(item: self.collectionView,
            attribute: .top,
            relatedBy: .equal,
            toItem: self,
            attribute: .top,
            multiplier: 1.0,
            constant: 0.0)

        let left = NSLayoutConstraint(item: self.collectionView,
            attribute: .leading,
            relatedBy: .equal,
            toItem: self,
            attribute: .leading,
            multiplier: 1.0,
            constant: 0.0)

        let bottom = NSLayoutConstraint (item: self,
            attribute: .bottom,
            relatedBy: .equal,
            toItem: self.collectionView,
            attribute: .bottom,
            multiplier: 1.0,
            constant: 0.0)

        let right = NSLayoutConstraint(item: self,
            attribute: .trailing,
            relatedBy: .equal,
            toItem: self.collectionView,
            attribute: .trailing,
            multiplier: 1.0,
            constant: 0.0)

        self.collectionView.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraints([top, left, bottom, right])
        DispatchQueue.main.async { [unowned self] in
            self.moveTo(page: self.currentIndex)
        }
    }

    fileprivate func getTitle(byIndex index: Int) -> String {
        let index = index % self.titles.count
        return self.titles[index]
    }

    fileprivate func isEqualIndex(_ index: Int, indexPath: IndexPath) -> Bool {
        if case .infinite(_) = self.options.displayMode {
            return index == indexPath.row % self.titles.count ? true : false
        } else {
            return index == indexPath.row
        }
    }

    fileprivate func toPage(indexPath: IndexPath) -> Int {
        return indexPath.row % self.titles.count
    }

    func moveTo(page: Int) {
        self.currentIndex = page
        /**
         move to the closest item
         */
        let sortedVisibleItem = self.collectionView.indexPathsForVisibleItems.sorted()
        let visibleItemCount = sortedVisibleItem.count
        let centeredItem = sortedVisibleItem[visibleItemCount % 2 == 0 ? visibleItemCount/2 : visibleItemCount/2 - 1]

        for indexPath in sortedVisibleItem {
            self.collectionView.deselectItem(at: indexPath, animated: false)
        }

        if self.isEqualIndex(page, indexPath: centeredItem) {
            self.collectionView.selectItem(at: centeredItem, animated: true, scrollPosition: .centeredHorizontally)
            if let cell = self.collectionView.cellForItem(at: centeredItem) {
                self.moveRoundRectView(target: cell)
            }
            return
        }

        let halfCount = self.dummyCount % 2 == 0 ? self.dummyCount/2 : self.dummyCount/2 - 1
        for i in 1...halfCount {
            let nextIndexPath = IndexPath(row: centeredItem.row + i, section: 0)
            if self.isEqualIndex(page, indexPath: nextIndexPath) {
                self.collectionView.selectItem(at: nextIndexPath, animated: true, scrollPosition: .centeredHorizontally)
                if let cell = self.collectionView.cellForItem(at: nextIndexPath) {
                    self.moveRoundRectView(target: cell)
                }
                return
            }

            let prevIndexPath = IndexPath(row: centeredItem.row - i, section: 0)
            if self.isEqualIndex(page, indexPath: prevIndexPath) {
                self.collectionView.selectItem(at: prevIndexPath, animated: true, scrollPosition: .centeredHorizontally)
                if let cell = self.collectionView.cellForItem(at: prevIndexPath) {
                    self.moveRoundRectView(target: cell)
                }
                return
            }
        }
    }

    fileprivate func setupRoundRectView() {
        let padding: CGFloat = 5
        self.roundRectView.frame = CGRect(
            origin: CGPoint(x: 100, y: padding),
            size: CGSize(width: 100, height: self.options.height - padding * 2))
        self.roundRectView.layer.cornerRadius = 10
        self.roundRectView.backgroundColor = self.options.selectedBackgroundColor
        self.collectionView.addSubview(self.roundRectView)
    }

    fileprivate func moveRoundRectView(target: UIView) {
//        UIView.animate(withDuration: 0.5) { [weak self] in
//            guard let this = self else { return }
//
//            let padding: CGFloat = 5
//            this.roundRectView.frame = CGRect(
//                origin: CGPoint(x: target.frame.origin.x, y: padding),
//                size: CGSize(width: target.frame.width, height: this.options.height - padding * 2))
//        }
        let padding: CGFloat = 5
        self.roundRectView.frame = CGRect(
            origin: CGPoint(x: target.frame.origin.x, y: padding),
            size: CGSize(width: target.frame.width, height: self.options.height - padding * 2))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension PageTabView: UICollectionViewDataSource {
    fileprivate var dummyCount: Int {
        if case .infinite(_) = self.options.displayMode {
            // dummy count
            return self.titles.count * 3
        } else {
            return self.titles.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dummyCount
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: PageTabCollectionCell.cellIdentifier, for: indexPath) as! PageTabCollectionCell

        cell.contentView.backgroundColor = .clear
        cell.titleLabel.text = self.getTitle(byIndex: indexPath.row)
        cell.titleLabel.frame = CGRect(origin: CGPoint.zero, size: cell.frame.size)
        cell.titleLabel.backgroundColor = .clear
        cell.titleLabel.textColor = self.options.textColor
        cell.titleLabel.font = self.options.textFont
        cell.backgroundColor = .clear

        return cell
    }
}

extension PageTabView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.menuItemWidth
        if width <= 0 {
            let title = self.getTitle(byIndex: indexPath.row) as NSString
            let size = title.size(attributes: [
                NSFontAttributeName: self.options.textFont
            ])
            return CGSize(width: size.width + 10, height: self.options.height)
        } else {
            return CGSize(width: width, height: self.options.height)
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

extension PageTabView: UICollectionViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard case .infinite(_) = self.options.displayMode else {
            return
        }

        let pageTabItemsWidth = floor(scrollView.contentSize.width / 3.0)

        if (scrollView.contentOffset.x <= 0.0) || (scrollView.contentOffset.x > pageTabItemsWidth * 2.0) {
            scrollView.contentOffset.x = pageTabItemsWidth
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.menuSelectedBlock?(self.currentIndex, self.toPage(indexPath: indexPath))
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if self.isEqualIndex(self.currentIndex, indexPath: indexPath) {
            self.moveRoundRectView(target: cell)
        }

        self.collectionView.sendSubview(toBack: self.roundRectView)
    }
}
