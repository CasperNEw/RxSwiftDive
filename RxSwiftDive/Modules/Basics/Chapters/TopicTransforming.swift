//
//  TopicTransforming.swift
//  RxSwiftDive
//
//  Created by Дмитрий Константинов on 02.12.2020.
//  Copyright © 2020 Дмитрий Константинов. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay

struct TopicTransforming: Topic {

    // MARK: - Properties
    var title: String { return String(describing: TopicTransforming.self) }
    var examplesWrapper: [Example] { return examples }

    private var examples: [Example] = []

    // MARK: - Public functions
    public mutating func learning() {
        learninigTransform()
    }

    // MARK: - Module functions
    mutating private func learninigTransform() {

        let firstExample = Example("toArray") {
            let disposeBag = DisposeBag()

            Observable.of("A", "B", "C")
                .toArray()
                .subscribe(onSuccess: { print($0) })
                .disposed(by: disposeBag)
        }

        let secondExample = Example("map") {
            let disposeBag = DisposeBag()

            let formatter = NumberFormatter()
            formatter.numberStyle = .spellOut

            Observable<Int>.of(123, 4, 56)
                .map { formatter.string(for: $0) ?? "" }
                .subscribe(onNext: { print($0) })
                .disposed(by: disposeBag)
        }

        examples.append(firstExample)
        examples.append(secondExample)
    }
}
