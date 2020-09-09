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

    public func example(of description: String,
                        action: () -> Void) {
      print("\n--- Example of:", description, "---")
      action()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .darkGray
        learning()
    }

    private func learning() {

        example(of: "BehaviorRelay") {

            let relay = BehaviorRelay(value: "Initial value")
            let disposeBag = DisposeBag()

            relay.accept("New initial value")

            relay
                .subscribe { customPrint(label: "s1 - ", event: $0) }
                .disposed(by: disposeBag)

            relay.accept("1")

            relay
                .subscribe { customPrint(label: "s2 - ", event: $0) }
                .disposed(by: disposeBag)

            relay.accept("2")
            print("BehaviorRelay.value = ", relay.value)
        }
    }
}

public func customPrint<T: CustomStringConvertible>(label: String,
                                                    event: Event<T>) {
    print(label, (event.element ?? event.error) ?? event)
}

enum MyError: Error {
    case anError
}
