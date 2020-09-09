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

    // MARK: - Properties
    var title: String { return String(describing: TopicSubjects.self) }
    var examplesWrapper: [Example] { return examples }

    private var examples: [Example] = []

    // MARK: - Public functions
    public mutating func learning() {
        learningSubjects()
        learningRelays()
        takeTheChallenges()
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

    mutating private func takeTheChallenges() {

        var score = 0
//        defer { score = 0 }

        let firstChallenge = Example("Challenge #1") {

            let disposeBag = DisposeBag()
            let dealtHand = PublishSubject<[(String, Int)]>()

            func deal(_ cardCount: UInt) {
                var deck = cards
                var cardsRemaining = deck.count
                var hand = [(String, Int)]()

                for _ in 0..<cardCount {
                    let randomIndex = Int.random(in: 0..<cardsRemaining)
                    hand.append(deck[randomIndex])
                    deck.remove(at: randomIndex)
                    cardsRemaining -= 1
                }

                // Add code to update dealtHand here
                let total = hand.reduce(into: 0) { $0 += $1.1 }
                total > 21 ? dealtHand.onError(HandError.busted(points: total)) : dealtHand.onNext(hand)
            }

            // Add subscription to dealtHand here
            dealtHand.subscribe(
                onNext: {
                    score += 1
                    print(cardString(for: $0), points(for: $0))
                    if score == 5 { print("Incredible! Congratulations! =)") }
            },
                onError: { print("Game Over, ", $0) },
                onCompleted: { print("Comleted") },
                onDisposed: { print("Disposed") })
                .disposed(by: disposeBag)

            deal(3)
            deal(3)
            deal(3)
            deal(3)
            deal(3)

            score = 0
        }

        let secondChallenge = Example("Challenge #2") {

            // Create userSession BehaviorRelay of type UserSession with initial value of .loggedOut
            let disposeBag = DisposeBag()
            let relay = BehaviorRelay<UserSession>(value: .loggedOut)

            // Subscribe to receive next events from userSession
            relay.subscribe(
                onNext: { print("subscribe - ", $0) },
                onError: { print("subscribe - ", $0) })
                .disposed(by: disposeBag)

            func logInWith(username: String,
                           password: String,
                           completion: (Error?) -> Void) {

                guard username == "johnny@appleseed.com",
                    password == "appleseed" else {
                        completion(LoginError.invalidCredentials)
                        return
                }

                // Update userSession
                relay.accept(.loggedIn)
                completion(nil)
            }

            func logOut() {
                // Update userSession
                relay.accept(.loggedOut)
            }

            func performActionRequiringLoggedInUser(_ action: () -> Void) {

                // Ensure that userSession is loggedIn and then execute action()
                guard relay.value == .loggedIn else {
                    print("access denied")
                    return
                }
                print("access is allowed")
                action()
            }

            for index in 1...2 {
                let password = index % 2 == 0 ? "appleseed" : "password"

                logInWith(username: "johnny@appleseed.com",
                          password: password) { error in

                            guard error == nil else {
                                print(error!)
                                return
                            }

                            print("User logged in.")
                }

                performActionRequiringLoggedInUser {
                    print("Successfully did something only a logged in user can do.")
                }
            }
        }

        examples.append(firstChallenge)
        examples.append(secondChallenge)
    }
}
