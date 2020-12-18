//
//  Table&Collection+.swift
//  RxSwiftDive
//
//  Created by Дмитрий Константинов on 17.12.2020.
//  Copyright © 2020 Дмитрий Константинов. All rights reserved.
//

import UIKit

protocol  Identity: AnyObject {
    static var identifier: String { get }
}

extension Identity {

    static var identifier: String {
        return String(describing: self)
    }
}

extension UITableViewCell: Identity { }
extension UICollectionViewCell: Identity { }

extension UITableView {

    func register(_ type: UITableViewCell.Type) {
        register(UINib(nibName: type.identifier, bundle: nil),
                 forCellReuseIdentifier: type.identifier)
    }

    func dequeueReusableCell<T: UITableViewCell>(for indexPath: IndexPath) -> T {

        guard let cell = dequeueReusableCell(withIdentifier: T.identifier,
                                             for: indexPath) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.identifier)")
        }
        return cell
    }
}

extension UICollectionView {

    func dequeueReusableCell<T: UICollectionViewCell>(for indexPath: IndexPath) -> T {

        guard let cell = dequeueReusableCell(withReuseIdentifier: T.identifier,
                                             for: indexPath) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.identifier)")
        }
        return cell
    }
}
