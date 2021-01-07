//
//  EventViewController.swift
//  RxSwiftDive
//
//  Created by Дмитрий Константинов on 06.01.2021.
//  Copyright © 2021 Дмитрий Константинов. All rights reserved.
//

import RxSwift
import RxCocoa

class EventViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var daysLabel: UILabel!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var tableView: UITableView!

    // MARK: - Properties
    let events = BehaviorRelay<[EOEvent]>(value: [])
    let days = BehaviorRelay<Int>(value: 360)
    let filteredEvents = BehaviorRelay<[EOEvent]>(value: [])
    let disposeBag = DisposeBag()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        filteredEvents.asObservable()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in self?.tableView.reloadData() })
            .disposed(by: disposeBag)

        Observable
            .combineLatest(days, events) { days, events -> [EOEvent] in
                let maxInterval = TimeInterval(days * 24 * 3600)
                return events.filter { event in
                    if let date = event.date {
                        return abs(date.timeIntervalSinceNow) < maxInterval
                    }
                    return true
                }
            }
            .bind(to: filteredEvents)
            .disposed(by: disposeBag)

        slider.rx.controlEvent(.valueChanged)
            .subscribe(onNext: { [unowned self] _ in
                self.days.accept(Int(slider.value))
            })
            .disposed(by: disposeBag)

        days.asObservable()
            .subscribe(onNext: { [weak self] days in
                self?.daysLabel.text = "Last \(days) days"
            })
            .disposed(by: disposeBag)

        slider.value = 360
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.register(EventTableViewCell.self)
    }
}

// MARK: - TableView
extension EventViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        filteredEvents.value.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell: EventTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        cell.configure(with: filteredEvents.value[indexPath.row])
        return cell
    }
}
