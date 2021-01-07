//
//  EventTableViewCell.swift
//  RxSwiftDive
//
//  Created by Дмитрий Константинов on 06.01.2021.
//  Copyright © 2021 Дмитрий Константинов. All rights reserved.
//

import UIKit

class EventTableViewCell: UITableViewCell {

    // MARK: - Outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var descrLabel: UILabel!

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool,
                              animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        titleLabel.text = nil
        dateLabel.text = nil
        descrLabel.text = nil
    }

    // MARK: - Public functions
    public func configure(with event: EOEvent) {

        titleLabel.text = event.title
        descrLabel.text = event.description

        let formatter = DateFormatter()
        formatter.dateStyle = .short
        if let when = event.date {
            dateLabel.text = formatter.string(for: when)
        } else {
            dateLabel.text = ""
        }
    }
}
