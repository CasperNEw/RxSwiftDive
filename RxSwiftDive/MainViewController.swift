//
//  MainViewController.swift
//  RxSwiftDive
//
//  Created by Дмитрий Константинов on 08.09.2020.
//  Copyright © 2020 Дмитрий Константинов. All rights reserved.
//

import UIKit
import SnapKit

class MainViewController: UIViewController {

    // MARK: - Properties
    lazy var tableView = UITableView()

    var topicObservables = TopicObservables()
    var sourceData: [(label: String, action: () -> Void)] = []

    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
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
        topicObservables.learning()
        sourceData = topicObservables.examplesWrapper
    }
}

// MARK: - TableView
extension MainViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {

        return sourceData.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = UITableViewCell()
        cell.textLabel?.text = sourceData[indexPath.row].label
        cell.selectionStyle = .none
        return cell
    }

    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {

        let example = sourceData[indexPath.row]

        print("\n--- Example of:", example.label, "---")
        example.action()
    }
}
