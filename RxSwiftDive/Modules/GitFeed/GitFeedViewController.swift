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
        navigationItem.title = "GitFeed"
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        setupTableView()
        refresh()
    }

    // MARK: - Module functions
    private func setupTableView() {

        tableView.register(GitTableViewCell.self)
        setupRefreshControl()

        events
            .bind(to: tableView.rx.items) { tableView, row, event in

                let indexPath = IndexPath(row: row, section: 0)
                let cell: GitTableViewCell = tableView.dequeueReusableCell(for: indexPath)

                cell.configure(title: event.actor.name,
                               detail: event.detail,
                               avatar: event.actor.avatar)
                return cell
            }
            .disposed(by: bag)
    }

    private func setupRefreshControl() {

        let refreshControl = UIRefreshControl()
        tableView.refreshControl = refreshControl

        refreshControl.backgroundColor = UIColor(white: 0.98, alpha: 1.0)
        refreshControl.tintColor = UIColor.darkGray
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
    func fetchEvents(repo: String) { }
    func processEvents(_ newEvents: [Event]) { }
}
