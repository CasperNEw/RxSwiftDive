//
//  GitTableViewCell.swift
//  RxSwiftDive
//
//  Created by Дмитрий Константинов on 17.12.2020.
//  Copyright © 2020 Дмитрий Константинов. All rights reserved.
//

import UIKit
import SDWebImage

class GitTableViewCell: UITableViewCell {

    // MARK: - Outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        userImageView.sd_imageTransition = .fade
    }

    // MARK: - Public functions
    public func configure(title: String,
                          detail: String,
                          url: URL) {

        titleLabel.text = title
        detailLabel.text = detail
        userImageView.sd_setImage(with: url)
    }
}
