//
//  TopicSubjects.swift
//  RxSwiftDive
//
//  Created by Дмитрий Константинов on 08.09.2020.
//  Copyright © 2020 Дмитрий Константинов. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay

struct TopicSubjects: Topic {

    // MARK: - typealias
    typealias Example = (title: String, action: () -> Void)

    // MARK: - Properties
    var title: String { return String(describing: TopicSubjects.self) }
    private var examples: [Example] = []
    var examplesWrapper: [Example] { return examples }

    enum MyError: Error {
      case anError
    }

    // MARK: - Public functions
    public mutating func learning() {
        learningSubjects()
        learningRelays()
    }

    // MARK: - Module functions
    mutating private func learningSubjects() {

        let firstExample = Example("PublishSubject") {

            let subject = PublishSubject<String>()

            subject.on(.next("Is anyone listening?"))

            let subscriptionOne = subject.subscribe(onNext: { print("s1 - ", $0) })

            subject.on(.next("1"))
            subject.onNext("2")

            let subscriptionTwo = subject.subscribe { print("s2 - ", $0.element ?? $0) }

            subject.onNext("3")
            subscriptionOne.dispose()
            subject.onNext("4")

            subject.onCompleted()
            subject.onNext("5")

            let disposeBag = DisposeBag()

            subject
                .subscribe { print("s3 - ", $0.element ?? $0) }
                .disposed(by: disposeBag)

            subject.onNext("?")
            subscriptionTwo.dispose()
        }

        let secondExample = Example("BehaviorSubject") {

            let subject = BehaviorSubject(value: "Initial value")
            let disposeBag = DisposeBag()

            subject.onNext("X")

            subject.subscribe {
                print("s2 - ", ($0.element ?? $0.error) ?? $0)
            }
            .disposed(by: disposeBag)

            subject.onError(MyError.anError)

            subject.subscribe {
                print("s2 - ", ($0.element ?? $0.error) ?? $0)
            }
            .disposed(by: disposeBag)
        }

        let thirdExample = Example("ReplaySubject") {

            let subject = ReplaySubject<String>.create(bufferSize: 2)
            let disposeBag = DisposeBag()

            subject.onNext("1")
            subject.onNext("2")
            subject.onNext("3")

            subject
                .subscribe { print("s1 - ", ($0.element ?? $0.error) ?? $0) }
                .disposed(by: disposeBag)

            subject
                .subscribe { print("s2 - ", ($0.element ?? $0.error) ?? $0) }
                .disposed(by: disposeBag)

            subject.onError(MyError.anError)
            subject.onNext("4")
            subject.dispose()

            subject
                .subscribe { print("s3 - ", ($0.element ?? $0.error) ?? $0) }
                .disposed(by: disposeBag)

            subject
                .subscribe(
                    onError: { print("s4 - [Error] ", $0) })
                .disposed(by: disposeBag)

            subject.onNext("5")
        }

        examples.append(firstExample)
        examples.append(secondExample)
        examples.append(thirdExample)
    }

    private mutating func learningRelays() {

        let firstExample = Example("PublishRelay") {

            let relay = PublishRelay<String>()
            let disposeBag = DisposeBag()

            relay.accept("Knock knock, anyone home?")

            relay
                .subscribe(onNext: { print($0) })
                .disposed(by: disposeBag)

            relay.accept("1")
        }

        let secondExample = Example("BehaviorRelay") {

            let relay = BehaviorRelay(value: "Initial value")
            let disposeBag = DisposeBag()

            relay.accept("New initial value")

            relay
                .subscribe { print("s1 - ", ($0.element ?? $0.error) ?? $0) }
                .disposed(by: disposeBag)

            relay.accept("1")

            relay
                .subscribe { print("s2 - ", ($0.element ?? $0.error) ?? $0) }
                .disposed(by: disposeBag)

            relay.accept("2")
            print("BehaviorRelay.value = ", relay.value)
        }

        examples.append(firstExample)
        examples.append(secondExample)
    }
}
