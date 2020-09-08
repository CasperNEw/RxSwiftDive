//
//  TopicObservables.swift
//  RxSwiftDive
//
//  Created by Дмитрий Константинов on 08.09.2020.
//  Copyright © 2020 Дмитрий Константинов. All rights reserved.
//

import Foundation
import RxSwift

struct TopicObservables {

    // MARK: - typealias
    typealias Example = (String, () -> Void)

    // MARK: - Properties
    private var examples: [Example] = []
    var examplesWrapper: [Example] { return examples }

    // MARK: - Public functions
    public mutating func learning() {
        learningBase()
        learningCreate()
    }

    // MARK: - Module functions
    mutating private func learningBase() {

        let firstExample = Example("just, of, from") {

            let one = 1
            let two = 2
            let three = 3

            _ = Observable<Int>.just(one)
            _ = Observable.of(one, two, three)
            _ = Observable.of([one, two, three])
            _ = Observable.from([one, two, three])
        }

        let secondExample = Example("Subscribe") {

            let one = 1
            let two = 2
            let three = 3

            let observable = Observable.of(one, two, three)

            observable
                .subscribe(onNext: { print($0) })
                .dispose()
        }

        let thirdExample = Example("Empty") {

            let observable = Observable<Void>.empty()

            observable
                .subscribe(
                    onNext: { print($0) },
                    onCompleted: { print("Completed") })
                .dispose()
        }

        let fourthExample = Example("Never") {

            let disposeBag = DisposeBag()
            let observable = Observable<Void>.never()

            observable
                .debug("observable")
                .do(
                    onNext: { _ in print("do onNext") },
                    afterNext: { _ in print("do afterNext") },
                    onError: { _ in print("do onError") },
                    afterError: { _ in print("do afterError") },
                    onCompleted: { print("do onCompleted") },
                    afterCompleted: { print("do afterCompleted") },
                    onSubscribe: { print("do onSubscribe") },
                    onSubscribed: { print("do onSubscribed") },
                    onDispose: { print("do onDispose") })
                .subscribe(
                    onNext: { _ in print("subscribe onNext") },
                    onError: { _ in print("subscribe onError") },
                    onCompleted: { print("subscribe onCompleted") },
                    onDisposed: { print("subscribe onDisposed") })
                .disposed(by: disposeBag)
        }

        let fifthExample = Example("Range") {

            let observable = Observable<Int>.range(start: 1, count: 10)

            observable.subscribe(
                onNext: { num in
                    let dNum = Double(num)
                    let fibonacci = Int(
                        ((pow(1.61803, dNum) - pow(0.61803, dNum)) /
                            2.23606).rounded() )
                    print(fibonacci)
            }).dispose()
        }

        let sixthExample = Example("Dispose") {

            let observable = Observable.of("A", "B", "C")

            let subscription = observable.subscribe { event in
                print(event)
            }
            subscription.dispose()
        }

        let seventhExample = Example("DisposeBag") {

            let disposeBag = DisposeBag()

            Observable.of("A", "B", "C")
                .subscribe { print($0) }
                .disposed(by: disposeBag)
        }

        examples.append(firstExample)
        examples.append(secondExample)
        examples.append(thirdExample)
        examples.append(fourthExample)
        examples.append(fifthExample)
        examples.append(sixthExample)
        examples.append(seventhExample)
    }

    mutating private func learningCreate() {

        let firstExample = Example("Create") {

            enum MyError: Error {
                case anError
            }
            let disposeBag = DisposeBag()

            Observable<String>.create { observer in

                observer.onNext("1")
                //        observer.onError(MyError.anError)
                //        observer.onCompleted()
                observer.onNext("?")
                return Disposables.create()

            }
            .subscribe(
                onNext: { print($0) },
                onError: { print($0) },
                onCompleted: { print("Completed") },
                onDisposed: { print("Disposed") })
            .disposed(by: disposeBag)
        }

        let secondExample = Example("Deferred") {

            let disposeBag = DisposeBag()
            var flip = false

            let factory: Observable<Int> = Observable.deferred {
                flip.toggle()

                return flip ? Observable.of(1, 2, 3) : Observable.of(4, 5, 6)
            }

            for _ in 0...3 {
                factory
                    .subscribe(onNext: { print($0, terminator: " ") })
                    .disposed(by: disposeBag)
                print()
            }
        }

        let thirdExample = Example("Single") {

            let disposeBag = DisposeBag()

            enum FileReadError: Error {
                case fileNotFound, unreadable, encodingFailed
            }

            func loadText(from name: String) -> Single<String> {

                return Single.create { single in

                    let disposable = Disposables.create()

                    guard let path = Bundle.main.path(forResource: name, ofType: "txt") else {
                        single(.error(FileReadError.fileNotFound))
                        return disposable
                    }

                    guard let data = FileManager.default.contents(atPath: path) else {
                        single(.error(FileReadError.unreadable))
                        return disposable
                    }

                    guard let contents = String(data: data, encoding: .utf8) else {
                        single(.error(FileReadError.encodingFailed))
                        return disposable
                    }

                    single(.success(contents))
                    return disposable
                }
            }

            loadText(from: "Copyright")
                .subscribe {

                    switch $0 {
                    case .success(let string):
                        print(string)
                    case .error(let error):
                        print(error)
                    }
            }
            .disposed(by: disposeBag)
        }

        examples.append(firstExample)
        examples.append(secondExample)
        examples.append(thirdExample)
    }
}
