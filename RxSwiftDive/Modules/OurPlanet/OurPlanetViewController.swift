//
//  OurPlanetViewController.swift
//  RxSwiftDive
//
//  Created by Дмитрий Константинов on 06.01.2021.
//  Copyright © 2021 Дмитрий Константинов. All rights reserved.
//

import RxSwift
import RxCocoa

class OurPlanetViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!

    // MARK: - Properties
    let activityView = UIActivityIndicatorView()
    let download = DownloadView()

    let categories = BehaviorRelay<[EOCategory]>(value: [])
    let disposeBag = DisposeBag()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupComponents()
        startDownload()
    }

    // MARK: - Module functions
    private func setupComponents() {

        title = "Our Planet"
        categories
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in self?.tableView.reloadData() })
            .disposed(by: disposeBag)

        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityView)
        activityView.startAnimating()
        view.addSubview(download)
        view.layoutIfNeeded()

        tableView.delegate = self
        tableView.dataSource = self

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

        tableView.backgroundColor = .clear
        tableView.backgroundView = UIImageView(image: #imageLiteral(resourceName: "background"))
        tableView.tableFooterView = UIView()
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
    }

    private func startDownload() {

        download.progress.progress = 0.0
        download.label.text = "Download: 0%"

        let eoCategories = EONET.categories

        let downloadedEvents = eoCategories
            .flatMap { categories in
                Observable.from(categories.map { category in
                    EONET.events(forLast: 360, category: category)
                })
            }
            .merge(maxConcurrent: 2)

        let updatedCategories = eoCategories.flatMap { categories in
            downloadedEvents.scan((0, categories)) { tuple, events in
                (tuple.0 + 1, tuple.1.map { category in
                    let eventsForCategory = EONET.filteredEvents(events: events, forCategory: category)
                    if !eventsForCategory.isEmpty {
                        var cat = category
                        cat.events += eventsForCategory
                        return cat
                    }
                    return category
                })
            }
            .observeOn(MainScheduler.instance)
            .do(onCompleted: { [weak self] in
                self?.activityView.stopAnimating()
                self?.download.isHidden = true
            })
            .do(onNext: { [weak self] tuple in
                let progress = Float(tuple.0) / Float(tuple.1.count)
                self?.download.progress.progress = progress
                let percent = Int(progress * 100.0)
                self?.download.label.text = "Download: \(percent)%"
            })
        }

        eoCategories
            .concat(updatedCategories.map { $0.1 })
            .bind(to: categories)
            .disposed(by: disposeBag)
    }
}

// MARK: - TableView
extension OurPlanetViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {

        return categories.value.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.configure(with: categories.value[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {

        let category = categories.value[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)

        guard !category.events.isEmpty else { return }

        let eventsController = EventViewController()
        eventsController.title = category.name
        eventsController.events.accept(category.events)
        navigationController?.pushViewController(eventsController, animated: true)
    }
}

// MARK: - UITableViewCell
fileprivate extension UITableViewCell {

    func configure(with category: EOCategory) {

        textLabel?.text = "\(category.name) (\(category.events.count))"
        detailTextLabel?.text = category.description

        if category.events.count > 0 {
            accessoryView = UIImageView(image: UIImage(systemName: "chevron.right"))
            accessoryView?.tintColor = .black
        }

        backgroundColor = .clear
        contentView.backgroundColor = .clear
        textLabel?.textColor = .black
        detailTextLabel?.textColor = .black
    }
}
