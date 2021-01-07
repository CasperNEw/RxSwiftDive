//
//  BasicsViewController.swift
//  RxSwiftDive
//
//  Created by Дмитрий Константинов on 08.09.2020.
//  Copyright © 2020 Дмитрий Константинов. All rights reserved.
//

import UIKit
import SnapKit

class BasicsViewController: UIViewController {

    // MARK: - Properties
    lazy private var tableView = UITableView()
    private var topics: [Topic] = []

    private let state: Chapter

    // MARK: - Initialization
    init(chapter: Chapter) {
        state = chapter
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        title = state.rawValue

        setupTableView()
        learning()
    }

    // MARK: - Module functions
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self

        tableView.tableFooterView = UIView()
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        view.addSubview(tableView)
        tableView.snp.makeConstraints { maker in
            maker.leading.trailing.equalTo(view)
            maker.top.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }

    private func learning() {

        switch state {
        case .two:
            topics.append(TopicObservables())
        case .three:
            topics.append(TopicSubjects())
        case .four, .eight, .ten:
            break
        case .five:
            topics.append(TopicFiltering())
        case .seven:
            topics.append(TopicTransforming())
        case .nine:
            topics.append(TopicCombining())
        }

        if topics.isEmpty { return }
        for index in 0..<topics.count {
            topics[index].learning()
        }
    }
}

// MARK: - TableView
extension BasicsViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        topics[section].title.titleCase()
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        topics.count
    }

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {

        return topics[section].examplesWrapper.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = UITableViewCell()
        cell.textLabel?.text = topics[indexPath.section].examplesWrapper[indexPath.row].0
        cell.selectionStyle = .none
        return cell
    }

    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        print("didSelectRowAt - ", indexPath.row)

        let example = topics[indexPath.section].examplesWrapper[indexPath.row]

        print("\n--- Example of:", example.title, "---")
        example.action()
    }
}
