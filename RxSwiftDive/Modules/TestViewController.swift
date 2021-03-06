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
import SnapKit

class TestViewController: UIViewController {

    private let label: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 40, weight: .semibold)
        label.text = "TEST ..."
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .darkGray
        learning()
        challenge()
        setupLabel()
    }

    private func setupLabel() {
        view.addSubview(label)
        label.snp.makeConstraints { maker in
            maker.top.equalTo(view.safeAreaLayoutGuide).inset(20)
            maker.leading.equalTo(view).inset(20)
        }
    }

    private func learning() {

        let disposeBag = DisposeBag()
        var start = 0
        func getStartNumber() -> Int {
            start += 1
            return start
        }

        example(of: "piy") {
            let numbers = Observable<Int>.create { observer in
                let start = getStartNumber()
                observer.onNext(start)
                observer.onNext(start+1)
                observer.onNext(start+2)
                observer.onCompleted()
                return Disposables.create()
            }

            numbers
                .subscribe(
                    onNext: { print("element [\($0)]") },
                    onCompleted: { print("-------------") })
                .disposed(by: disposeBag)

            numbers
                .subscribe(
                    onNext: { print("element [\($0)]") },
                    onCompleted: { print("-------------") })
                .disposed(by: disposeBag)
        }
    }

    func challenge() { }
}
