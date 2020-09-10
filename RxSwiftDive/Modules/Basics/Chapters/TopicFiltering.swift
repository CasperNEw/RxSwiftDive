//
//  TopicFiltering.swift
//  RxSwiftDive
//
//  Created by Дмитрий Константинов on 10.09.2020.
//  Copyright © 2020 Дмитрий Константинов. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay

struct TopicFiltering: Topic {

    // MARK: - Properties
    var title: String { return String(describing: TopicFiltering.self) }
    var examplesWrapper: [Example] { return examples }

    private var examples: [Example] = []

    // MARK: - Public functions
    public mutating func learning() {
        learningIgnoring()
        learningSkip()
        learningTake()
        learningDistincts()
        takeTheChallenges()
    }

    // MARK: - Module functions
    mutating private func learningIgnoring() {

        let firstExample = Example("ignoreElements") {

            let strikes = PublishSubject<String>()
            let disposeBag = DisposeBag()

            strikes.ignoreElements().subscribe { _ in
                print("You're out!")
            }
            .disposed(by: disposeBag)

            strikes.onNext("X")
            strikes.onNext("X")
            strikes.onNext("X")
            strikes.onCompleted()
        }

        let secondExample = Example("elementAt") {

            let strikes = PublishSubject<String>()
            let disposeBag = DisposeBag()

            strikes
                .elementAt(2) .subscribe(onNext: {
                    print("You're out! ", $0)
                })
                .disposed(by: disposeBag)

            strikes.onNext("X_1")
            strikes.onNext("X_2")
            strikes.onNext("X_3")
            strikes.onNext("X_4")
        }

        let thirdExample = Example("filter") {
            let disposeBag = DisposeBag()

            Observable.of(1, 2, 3, 4, 5, 6)
                .filter { $0.isMultiple(of: 2) }
                .subscribe(onNext: { print($0) })
                .disposed(by: disposeBag) }

        examples.append(firstExample)
        examples.append(secondExample)
        examples.append(thirdExample)
    }

    private mutating func learningSkip() {

        let firstExample = Example("skip") {
            let disposeBag = DisposeBag()

            Observable.of("A", "B", "C", "D", "E", "F")
                .skip(3)
                .subscribe(onNext: { print($0) })
                .disposed(by: disposeBag) }

        let secondExample = Example("skipWhile") {
            let disposeBag = DisposeBag()

            Observable.of(2, 2, 3, 4, 4)
                .skipWhile { $0.isMultiple(of: 2) }
                .subscribe(onNext: { print($0) })
                .disposed(by: disposeBag) }

        let thirdExample = Example("skipUntil trigger") {
            let disposeBag = DisposeBag()

            let subject = PublishSubject<String>()
            let trigger = PublishSubject<String>()

            subject
                .skipUntil(trigger)
                .subscribe(onNext: { print($0) })
                .disposed(by: disposeBag)

            subject.onNext("A")
            subject.onNext("B")
            trigger.onNext("X")
            subject.onNext("C")
            subject.onNext("D")
            subject.onNext("E")
        }

        examples.append(firstExample)
        examples.append(secondExample)
        examples.append(thirdExample)
    }

    private mutating func learningTake() {

        let firstExample = Example("take") {
            let disposeBag = DisposeBag()

            Observable.of(1, 2, 3, 4, 5, 6)
                .take(3)
                .subscribe(onNext: { print($0) })
                .disposed(by: disposeBag) }

        let secondExample = Example("takeWhile") {
            let disposeBag = DisposeBag()

            Observable.of(2, 2, 4, 4, 6, 6)
                .enumerated()
                .takeWhile { index, integer in
                    integer.isMultiple(of: 2) && index < 3 }
                .map(\.element)
                .subscribe(onNext: { print($0) })
                .disposed(by: disposeBag)
        }

        let thirdExample = Example("takeUntil") {
            let disposeBag = DisposeBag()

            Observable.of(1, 2, 3, 4, 5)
                .takeUntil(.inclusive) { $0.isMultiple(of: 4) }
                .subscribe(onNext: { print($0) })
                .disposed(by: disposeBag) }

        let fourthExample = Example("takeUntil trigger") {
            let disposeBag = DisposeBag()

            let subject = PublishSubject<String>()
            let trigger = PublishSubject<String>()

            subject
                .takeUntil(trigger)
                .subscribe(onNext: { print($0) })
                .disposed(by: disposeBag)

            subject.onNext("1")
            subject.onNext("2")
            trigger.onNext("X")
            subject.onNext("3") }

        examples.append(firstExample)
        examples.append(secondExample)
        examples.append(thirdExample)
        examples.append(fourthExample)
    }

    mutating private func learningDistincts() {

        let firstExample = Example("distinctUntilChanged") {
        let disposeBag = DisposeBag()

        Observable.of("A", "A", "B", "B", "B", "A")
            .distinctUntilChanged()
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag) }

        let secondExample = Example("distinctUntilChanged(_:)") {
            let disposeBag = DisposeBag()

            let formatter = NumberFormatter()
            formatter.numberStyle = .spellOut

            Observable<NSNumber>.of(10, 110, 20, 200, 210, 310)
                .distinctUntilChanged { first, second in
                    guard
                        let aWords = formatter
                            .string(from: first)?
                            .components(separatedBy: " "),
                        let bWords = formatter
                            .string(from: second)?
                            .components(separatedBy: " ")
                        else { return false }

                    var containsMatch = false

                    for aWord in aWords where bWords.contains(aWord) { containsMatch = true
                        break
                    }
                    return containsMatch
            }.subscribe(onNext: { print($0) })
                .disposed(by: disposeBag)
        }

        examples.append(firstExample)
        examples.append(secondExample)
    }

    mutating private func takeTheChallenges() {

        let firstChallenge = Example("Challenge #1") {
            let disposeBag = DisposeBag()

            let contacts = [
                "603-555-1212": "Florent",
                "212-555-1212": "Shai",
                "408-555-1212": "Marin",
                "617-555-1212": "Scott"
            ]

            func phoneNumber(from inputs: [Int]) -> String {
                var phone = inputs.map(String.init).joined()

                phone.insert("-", at: phone.index(
                    phone.startIndex,
                    offsetBy: 3)
                )

                phone.insert("-", at: phone.index(
                    phone.startIndex,
                    offsetBy: 7)
                )

                return phone
            }

            let input = PublishSubject<Int>()

            // Add your code here
            input
                .skipWhile { $0 == 0 }
                .filter { 0...9 ~= $0 }
                .take(10)
                .toArray()
                .subscribe(
                    onSuccess: {
                        let phone = phoneNumber(from: $0)
                        if let contact = contacts[phone] {
                            print("Dialing \(contact) (\(phone))...")
                        } else {
                            print("Contact not found")
                        }
                },
                    onError: { print($0) })
                .disposed(by: disposeBag)

            input.onNext(0)
            input.onNext(603)

            input.onNext(2)
            input.onNext(1)

            // Confirm that 7 results in "Contact not found",
            // and then change to 2 and confirm that Shai is found
            input.onNext(2)

            "5551212".forEach {
                if let number = (Int("\($0)")) {
                    input.onNext(number)
                }
            }

            input.onNext(9)
        }

        examples.append(firstChallenge)
    }
}
