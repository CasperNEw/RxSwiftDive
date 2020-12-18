//
//  GitFeedViewController.swift
//  RxSwiftDive
//
//  Created by Дмитрий Константинов on 17.12.2020.
//  Copyright © 2020 Дмитрий Константинов. All rights reserved.
//

import RxSwift
import RxCocoa

class GitFeedViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!

    // MARK: - Properties
    private let repo = "ReactiveX/RxSwift"
    private let events = BehaviorRelay<[Event]>(value: [])
    private let bag = DisposeBag()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = repo
        navigationItem.largeTitleDisplayMode = .never
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        setupTableView()
        refresh()
    }

    // MARK: - Module functions
    private func setupTableView() {

        tableView.tableFooterView = UIView()
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        tableView.register(GitTableViewCell.self)
        setupRefreshControl()

        events
            .bind(to: tableView.rx.items) { tableView, row, event in

                let indexPath = IndexPath(row: row, section: 0)
                let cell: GitTableViewCell = tableView.dequeueReusableCell(for: indexPath)

                cell.configure(title: event.actor.name,
                               detail: event.detail,
                               url: event.actor.avatar)
                return cell
            }
            .disposed(by: bag)
    }

    private func setupRefreshControl() {

        let refreshControl = UIRefreshControl()
        tableView.refreshControl = refreshControl

        refreshControl.tintColor = .darkGray
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
    }

    // MARK: - Actions
    @objc func refresh() {

        DispatchQueue.global(qos: .default).async { [weak self] in
            guard let self = self else { return }
            self.fetchEvents(repo: self.repo)
        }
    }

    // MARK: - Fetch & Process
    func fetchEvents(repo: String) {

        let response = Observable.from([repo])
            .map(urlRequestFromString)
            .flatMap { URLSession.shared.rx.response(request: $0) }
            .share(replay: 1)

        response
            .filter(ignoreResponseErrors)
            .compactMap(parseJson)
            .subscribe(onNext: (processEvents))
            .disposed(by: bag)
    }

    // MARK: - Helper Blocks
    let urlRequestFromString: (String) -> (URLRequest) = { repo in
        let url = URL(string: "https://api.github.com/repos/\(repo)/events")!
        return URLRequest(url: url)
    }

    let ignoreResponseErrors: (HTTPURLResponse, Data) -> Bool = { response, _ in
        return 200..<300 ~= response.statusCode
    }

    let parseJson: (HTTPURLResponse, Data) -> ([Event]?) = { _, data in
        return try? JSONDecoder().decode([Event].self, from: data)
    }

    lazy var processEvents: ([Event]) -> Void = { [weak self] newEvents in

        var updatedEvents = newEvents
        if let events = self?.events.value {
            updatedEvents += events
        }

        if updatedEvents.count > 50 {
            updatedEvents = Array(updatedEvents.prefix(upTo: 50))
        }

        self?.events.accept(updatedEvents)

        DispatchQueue.main.async {
            self?.tableView.reloadData()
            self?.tableView.refreshControl?.endRefreshing()
        }

        //        let eventsArray = updatedEvents.map { $0.dictionary } as NSArray
        //        eventsArray.write(to: eventsFileURL, atomically: true)
    }
}
