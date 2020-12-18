//
//  TopicCombining.swift
//  RxSwiftDive
//
//  Created by Дмитрий Константинов on 18.12.2020.
//  Copyright © 2020 Дмитрий Константинов. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay

struct TopicCombining: Topic {

    // MARK: - Properties
    var title: String { return String(describing: TopicCombining.self) }
    var examplesWrapper: [Example] { return examples }

    private var examples: [Example] = []

    // MARK: - Public functions
    public mutating func learning() {
        learningConcationg()
        learningMerging()
        learningCombining()
    }

    // MARK: - Module functions
    mutating private func learningConcationg() {

        let firstExample = Example("startWith") {

            _ = Observable.of(2, 3, 4)
                .startWith(1)
                .subscribe(onNext: { print($0) },
                           onDisposed: { print("disposed") })
        }

        let secondExample = Example("Observable.concat") {

            let first = Observable.of(1, 2, 3)
            let second = Observable.of(4, 5, 6)

            _ = Observable.concat([first, second])
                .subscribe(onNext: { print($0) },
                           onDisposed: { print("disposed") })
        }

        let thirdExample = Example("concat") {

            let germanCities = Observable.of("Berlin", "Münich", "Frankfurt")
            let spanishCities = Observable.of("Madrid", "Barcelona", "Valencia")

            _ = germanCities.concat(spanishCities)
                .subscribe(onNext: { print($0) },
                           onDisposed: { print("disposed") })
        }

        let fourthExample = Example("concatMap") {

            let sequences = [
                "German cities": Observable.of("Berlin", "Münich", "Frankfurt"),
                "Spanish cities": Observable.of("Madrid", "Barcelona", "Valencia")
            ]

            _ = Observable.of("German cities", "Spanish cities")
                .concatMap { country in sequences[country] ?? .empty() }
                .subscribe(onNext: { print($0) },
                           onDisposed: { print("disposed") })
        }

        examples.append(firstExample)
        examples.append(secondExample)
        examples.append(thirdExample)
        examples.append(fourthExample)
    }

    mutating private func learningMerging() {

        let firstExample = Example("merge") {

            let left = PublishSubject<String>()
            let right = PublishSubject<String>()

            let source = Observable.of(left.asObserver(), right.asObserver())

            _ = source.merge()
                .subscribe(onNext: { print($0) },
                           onDisposed: { print("disposed") })

            var leftValues = ["Berlin", "Munich", "Frankfurt"]
            var rightValues = ["Madrid", "Barcelona", "Valencia"]

            repeat {
                switch Bool.random() {
                case true where !leftValues.isEmpty:
                    left.onNext("Left: " + leftValues.removeFirst())
                case false where !rightValues.isEmpty:
                    right.onNext("Right: " + rightValues.removeFirst())
                default:
                    break
                }
            } while !leftValues.isEmpty || !rightValues.isEmpty

            left.onCompleted()
            right.onCompleted()
        }

        examples.append(firstExample)
    }

    mutating private func learningCombining() {

    }
}
