//
//  MainViewController.swift
//  RxSwiftDive
//
//  Created by Дмитрий Константинов on 10.09.2020.
//  Copyright © 2020 Дмитрий Константинов. All rights reserved.
//

import UIKit

protocol Titles: UIViewController {
    var selfTitle: String { get }
}

class MainViewController: UIViewController {

    // MARK: - Properties
    lazy private var tableView = UITableView()
    private var source: [Titles] = []

    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        navigationItem.title = "RxSwift"
        setupSourceData()
        setupTableView()
    }

    // MARK: - Module functions
    private func setupSourceData() {
        source.append(BasicsViewController())
        source.append(CombineViewController())
    }

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
}

// MARK: - TableView
extension MainViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        source.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = UITableViewCell()
        cell.textLabel?.text = source[indexPath.row].selfTitle
        cell.selectionStyle = .none
        return cell
    }

    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {

        navigationController?
            .pushViewController(source[indexPath.row],
                                animated: true)
    }
}
