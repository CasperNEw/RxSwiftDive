//
//  TestViewController.swift
//  RxSwiftDive
//
//  Created by Дмитрий Константинов on 08.09.2020.
//  Copyright © 2020 Дмитрий Константинов. All rights reserved.
//

import UIKit
import RxSwift
import RxRelay

class TestViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .darkGray
        learning()
    }

    private func learning() {

        example(of: "BehaviorRelay") {

        }
    }
}
