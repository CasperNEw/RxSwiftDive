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
    private let navTitle = "ReactiveX/RxSwift"
    private lazy var eventsFileUrl = cachedFileUrl("events.json")
    private lazy var modifiedFileUrl = cachedFileUrl("modified.txt")

    private let lastModified = BehaviorRelay<String?>(value: nil)
    private let events = BehaviorRelay<[Event]>(value: [])
    private let bag = DisposeBag()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = navTitle
        navigationItem.largeTitleDisplayMode = .never
        fetchFromPlist()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        setupTableView()

        if let lastModifiedString = try? String(contentsOf: modifiedFileUrl, encoding: .utf8) {
            lastModified.accept(lastModifiedString)
        }

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
            self?.fetchEvents()
        }
    }

    // MARK: - Fetch & Process
    private func fetchEvents() {

        let topRepos = "https://api.github.com/search/repositories?q=language:swift&per_page=5"

        let response = Observable.from([topRepos])
            .map(createTopRequest)
            .flatMap { URLSession.shared.rx.json(request: $0) }
            .flatMap(parseTopJson)
            .map(createRepoRequest)
            .flatMap { URLSession.shared.rx.response(request: $0) }
            .share(replay: 1)

        response
            .filter(ignoreResponseErrors)
            .compactMap(parseRepoJson)
            .subscribe(onNext: processEvents)
            .disposed(by: bag)

        response
            .filter(ignoreHeaderErrors)
            .flatMap(parseHeader)
            .subscribe(onNext: processHeader)
            .disposed(by: bag)
    }

    private func cachedFileUrl(_ fileName: String) -> URL {
        FileManager.default
            .urls(for: .cachesDirectory, in: .allDomainsMask)
            .first!
            .appendingPathComponent(fileName)
    }

    private func fetchFromPlist() {
        if let eventsData = try? Data(contentsOf: eventsFileUrl),
           let persistedEvents = try? JSONDecoder().decode([Event].self, from: eventsData) {
            events.accept(persistedEvents)
        }
    }

    // MARK: - Helper Blocks
    lazy var createTopRequest: (String) -> (URLRequest) = { topUrls in
        let url = URL(string: topUrls)!
        return URLRequest(url: url)
    }

    lazy var createRepoRequest: (String) -> (URLRequest) = { [weak self] repo in
        let url = URL(string: "https://api.github.com/repos/\(repo)/events?per_page=5")!
        var request = URLRequest(url: url)
        if let modifiedHeader = self?.lastModified.value {
            request.addValue(modifiedHeader, forHTTPHeaderField: "Last-Modified")
        }
        return request
    }

    let ignoreResponseErrors: (HTTPURLResponse, Data) -> Bool = { response, _ in
        return 200..<300 ~= response.statusCode
    }

    let ignoreHeaderErrors: (HTTPURLResponse, Data) -> Bool = { response, _ in
        return 200..<400 ~= response.statusCode
    }

    let parseTopJson: (Any) -> (Observable<String>) = { response in
        guard let response = response as? [String: Any],
              let items = response["items"] as? [[String: Any]]
        else { return Observable.empty() }

        return Observable.from(items.compactMap { $0["full_name"] as? String })
    }

    let parseRepoJson: (HTTPURLResponse, Data) -> ([Event]?) = { _, data in
        return try? JSONDecoder().decode([Event].self, from: data)
    }

    let parseHeader: (HTTPURLResponse, Data) -> Observable<String> = { response, _ in
        guard let value = response.allHeaderFields["Last-Modified"] as? String else {
            return Observable.empty()
        }
        return Observable.just(value)
    }

    lazy var processEvents: ([Event]) -> Void = { [weak self] newEvents in

        var updatedEvents = newEvents
        if let events = self?.events.value {
            updatedEvents += events
        }

        /// stay unique
        let eventSet = Set(updatedEvents)
        updatedEvents = Array(eventSet)

        if updatedEvents.count > 50 {
            updatedEvents = Array(updatedEvents.prefix(upTo: 50))
        }

        self?.events.accept(updatedEvents)

        DispatchQueue.main.async {
            self?.tableView.reloadData()
            self?.tableView.refreshControl?.endRefreshing()
        }

        if let eventData = try? JSONEncoder().encode(updatedEvents) {
            guard let url = self?.eventsFileUrl else { return }
            try? eventData.write(to: url, options: .atomicWrite)
        }
    }

    lazy var processHeader: (String) -> Void = { [weak self] modifiedHeader in
        guard let self = self else { return }

        self.lastModified.accept(modifiedHeader)
        try? modifiedHeader.write(to: self.modifiedFileUrl, atomically: true, encoding: .utf8)
    }
}
