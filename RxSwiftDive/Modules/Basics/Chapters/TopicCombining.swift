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
        learningTriggers()
        learningSwitches()
        learningReduce()
        takeTheChallenges()
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

        let firstExample = Example("combineLatest") {

            let left = PublishSubject<String>()
            let right = PublishSubject<String>()

            let observable = Observable.combineLatest(left, right) { "(\($0) \($1)" }
            _ = observable.subscribe(onNext: { print($0) },
                                     onDisposed: { print("disposed") })

            print("> Sending a value to Left")
            left.onNext("Hello,")

            print("> Sending a value to Right")
            right.onNext("world")

            print("> Sending another value to Right")
            right.onNext("RxSwift")

            print("> Sending another value to Left")
            left.onNext("Have a good day,")

            left.onCompleted()
            right.onCompleted()
        }

        let secondExample = Example("combine user choice and value") {

            let choice: Observable<DateFormatter.Style> = Observable.of(.short, .long)
            let dates = Observable.of(Date())
            let observable = Observable
                .combineLatest(choice, dates) { format, when -> String in
                let formatter = DateFormatter()
                formatter.dateStyle = format
                return formatter.string(from: when) }

            _ = observable.subscribe(onNext: { print($0) })
        }

        let thirdExample = Example("zip") {

            enum Weather {
                case cloudy
                case sunny
            }
            let left: Observable<Weather> = Observable.of(.sunny, .cloudy, .cloudy, .sunny)
            let right = Observable.of("Lisabon", "Copenhagen", "London", "Madrid", "Vienna")

            let observable = Observable.zip(left, right) { weather, city in
                "Ir's \(weather) in \(city)"
            }

            _ = observable.subscribe(onNext: { print($0) })
        }

        examples.append(firstExample)
        examples.append(secondExample)
        examples.append(thirdExample)
    }

    mutating private func learningTriggers() {

        let firstExample = Example("withLatesFrom") {

            let button = PublishSubject<Void>()
            let textField = PublishSubject<String>()

            let observable = button.withLatestFrom(textField)

            _ = observable.subscribe(onNext: { print($0) })

            textField.onNext("Par")
            button.onNext(())
            textField.onNext("Pari")
            textField.onNext("Paris")
            button.onNext(())
            button.onNext(())
        }

        let secondExample = Example("sample") {

            let button = PublishSubject<Void>()
            let textField = PublishSubject<String>()

            let observable = textField.sample(button)

            _ = observable.subscribe(onNext: { print($0) })

            textField.onNext("Par")
            button.onNext(())
            textField.onNext("Pari")
            textField.onNext("Paris")
            button.onNext(())
            button.onNext(())
        }

        examples.append(firstExample)
        examples.append(secondExample)
    }

    mutating private func learningSwitches() {

        let firstExample = Example("amb") {

            let left = PublishSubject<String>()
            let right = PublishSubject<String>()

            let observable = left.amb(right)
            _ = observable.subscribe(onNext: { print($0) })

            left.onNext("Lisbon")
            right.onNext("Copenhagen")
            left.onNext("London")
            left.onNext("Madrid")
            right.onNext("Vienna")

            left.onCompleted()
            right.onCompleted()
        }

        let secondExample = Example("switchLatest") {

            let one = PublishSubject<String>()
            let two = PublishSubject<String>()
            let three = PublishSubject<String>()

            let source = PublishSubject<Observable<String>>()

            let observable = source.switchLatest()
            let disposable = observable.subscribe(onNext: { print($0) })

            source.onNext(one)
            one.onNext("Some text from sequence one")
            two.onNext("Some text from sequence two")
            source.onNext(two)
            two.onNext("More text from sequence two")
            one.onNext("and also from sequence one")
            source.onNext(three)
            two.onNext("Why don't you see me?")
            one.onNext("I'm alone, help me")
            three.onNext("Hey it's three. I win.")
            source.onNext(one)
            one.onNext("Nope. It's me, one!")

            disposable.dispose()
        }

        examples.append(firstExample)
        examples.append(secondExample)
    }

    mutating private func learningReduce() {

        let firstExample = Example("reduce") {

            let source = Observable.of(1, 3, 5, 7, 9)

            let observable = source.reduce(0, accumulator: +)
            _ = observable.subscribe(onNext: { print($0) })

            _ = source
                .reduce(0) { summary, newValue in
                    summary + newValue }
                .subscribe(onNext: { print($0) })
        }

        let secondExample = Example("scan") {

            let source = Observable.of(1, 3, 5, 7, 9)

            let observable = source.scan(0, accumulator: +)
            _ = observable.subscribe(onNext: { print($0) })
        }

        examples.append(firstExample)
        examples.append(secondExample)
    }

    mutating private func takeTheChallenges() {

        let challenge = Example("Challenge") {

            let source = Observable.of(1, 3, 5, 7, 9)

            let observable = source.scan(0, accumulator: +)
            _ = Observable.zip(source, observable) { "[scan] current - \($0), total - \($1)" }
                .subscribe(onNext: { print($0) })

            _ = source.reduce(0, accumulator: { summary, newValue in
                print("[reduce] current - \(newValue), total - \(summary + newValue)")
                return summary + newValue
            })
            .subscribe(onNext: { _ in })
        }

        examples.append(challenge)
    }
}
