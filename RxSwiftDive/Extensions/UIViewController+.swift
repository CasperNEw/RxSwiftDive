//
//  UIViewController+.swift
//  RxSwiftDive
//
//  Created by Дмитрий Константинов on 10.09.2020.
//  Copyright © 2020 Дмитрий Константинов. All rights reserved.
//

import UIKit
import RxSwift

extension UIViewController {

    public class var identifier: String {
        return String.className(self)
    }

    public func showAlert(title: String, description: String?) -> Completable {

        return Completable.create { [weak self] completable -> Disposable in

            let alert = UIAlertController(title: title,
                                          message: description,
                                          preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "Close",
                                          style: .default,
                                          handler: { _ in
                completable(.completed)
            }))

            self?.present(alert, animated: true)

            return Disposables.create {
                self?.dismiss(animated: true)
            }
        }
    }
}
