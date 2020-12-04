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

    // MARK: - Types
    struct Student {
        let score: BehaviorSubject<Int>
    }

    enum MyError: Error {
        case anError
    }

    // MARK: - Properties
    var title: String { return String(describing: TopicTransforming.self) }
    var examplesWrapper: [Example] { return examples }

    private var examples: [Example] = []

    // MARK: - Public functions
    public mutating func learning() {
        learninigTransform()
        learningInnerTransforming()
        learningObservingEvents()
        takeTheChallenges()
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

        let thirdExample = Example("enumerated and map") {
            let disposeBag = DisposeBag()

            Observable.of(1, 2, 3, 4, 5, 6, 7)
                .enumerated()
                .map { index, element in
                    index > 2 ? element * 2 : element }
                .subscribe(onNext: { print($0) })
                .disposed(by: disposeBag)
        }

        let fourthExample = Example("compactMap") {
            let disposeBag = DisposeBag()

            Observable.of("To", "be", nil, "or", "not", "to", "be", nil)
                .compactMap { $0 }
                .toArray()
                .map { $0.joined(separator: " ")}
                .subscribe(onSuccess: { print($0) })
                .disposed(by: disposeBag)
        }

        examples.append(firstExample)
        examples.append(secondExample)
        examples.append(thirdExample)
        examples.append(fourthExample)
    }

    mutating private func learningInnerTransforming() {

        let firstExample = Example("flatMap") {
            let disposeBag = DisposeBag()

            let laura = Student(score: .init(value: 80))
            let charlotte = Student(score: .init(value: 90))

            let student = PublishSubject<Student>()

            student
                .flatMap { $0.score }
                .subscribe(onNext: { print($0) })
                .disposed(by: disposeBag)

            student.onNext(laura)
            laura.score.onNext(85)
            student.onNext(charlotte)
            charlotte.score.onNext(95)
            charlotte.score.onNext(100)
        }

        let secondExample = Example("flatMapLates") {
            let disposeBag = DisposeBag()

            let laura = Student(score: .init(value: 80))
            let charlotte = Student(score: .init(value: 90))

            let student = PublishSubject<Student>()

            student
                .flatMapLatest { $0.score }
                .subscribe(onNext: { print($0) })
                .disposed(by: disposeBag)

            student.onNext(laura)
            laura.score.onNext(85)
            student.onNext(charlotte)
            laura.score.onNext(95)
            charlotte.score.onNext(100)
        }

        examples.append(firstExample)
        examples.append(secondExample)
    }

    mutating private func learningObservingEvents() {

        let firstExample = Example("materialize and dematerialize") {
            let disposeBag = DisposeBag()

            let laura = Student(score: .init(value: 80))
            let charlotte = Student(score: .init(value: 100))

            let student = BehaviorSubject(value: laura)

            let studentScore = student
                .flatMapLatest { $0.score.materialize() }

            studentScore
                .filter {
                    guard $0.error == nil else {
                        print($0.error!)
                        return false
                    }
                    return true }
                .dematerialize()
                .subscribe(onNext: { print($0) })
                .disposed(by: disposeBag)

            laura.score.onNext(85)
            laura.score.onError(MyError.anError)
            laura.score.onNext(90)

            student.onNext(charlotte)
        }

        examples.append(firstExample)
    }

    mutating private func takeTheChallenges() {

        let firstChallenge = Example("Challenge #1") {
            let disposeBag = DisposeBag()

            let contacts = [
              "603-555-1212": "Florent",
              "212-555-1212": "Junior",
              "408-555-1212": "Marin",
              "617-555-1212": "Scott"
            ]

            let convert: (String) -> UInt? = { value in
              if let number = UInt(value),
                number < 10 {
                return number
              }

              let keyMap: [String: UInt] = [
                "abc": 2, "def": 3, "ghi": 4,
                "jkl": 5, "mno": 6, "pqrs": 7,
                "tuv": 8, "wxyz": 9
              ]

              let converted = keyMap
                .filter { $0.key.contains(value.lowercased()) }
                .map { $0.value }
                .first

              return converted
            }

            let format: ([UInt]) -> String = {
              var phone = $0.map(String.init).joined()

              phone.insert("-", at: phone.index(
                phone.startIndex,
                offsetBy: 3)
              )

              phone.insert("-", at: phone.index(
                phone.startIndex,
                offsetBy: 7)
              )

                print(phone)
              return phone
            }

            let dial: (String) -> String = {
              if let contact = contacts[$0] {
                return "Dialing \(contact) (\($0))..."
              } else {
                return "Contact not found"
              }
            }

            let input = PublishSubject<String>()

            // Add your code here
            input
                .map(convert)
                .compactMap { $0 }
                .skipWhile { $0 == 0 }
                .take(10)
                .toArray()
                .map(format)
                .map(dial)
                .subscribe(onSuccess: { print($0) })
                .disposed(by: disposeBag)

            input.onNext("")
            input.onNext("0")
            input.onNext("408")

            input.onNext("6")
            input.onNext("")
            input.onNext("0")
            input.onNext("3")

            "JKL1A1B".forEach {
              input.onNext("\($0)")
            }

            input.onNext("9")
          }

        examples.append(firstChallenge)
    }
}
