//
//  PageTabCollectionCell.swift
//  PageTabViewController
//
//  Created by svpcadmin on 11/11/16.
//  Copyright © 2016 tamanyan. All rights reserved.
//

import UIKit

class PageTabCollectionCell: UICollectionViewCell {
    static let cellIdentifier = "PageTabCollectionCell"

    var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        self.contentView.addSubview(self.titleLabel)
        self.titleLabel.frame = CGRect(origin: CGPoint.zero, size: self.frame.size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.titleLabel.text = ""
    }
}
