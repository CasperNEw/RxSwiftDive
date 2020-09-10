//
//  MainViewController.swift
//  RxSwiftDive
//
//  Created by Дмитрий Константинов on 10.09.2020.
//  Copyright © 2020 Дмитрий Константинов. All rights reserved.
//

import UIKit

enum Chapter: String {
    case two = "Chapter II"
    case three = "Chapter III"
    case four = "Combinestagram"
    case five = "Chapter V"
}

class MainViewController: UIViewController {

    // MARK: - Properties
    lazy private var tableView = UITableView()
    private var source: [Chapter] = []

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
        source.append(.two)
        source.append(.three)
        source.append(.four)
        source.append(.five)
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
        cell.textLabel?.text = source[indexPath.row].rawValue
        cell.selectionStyle = .none
        return cell
    }

    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        print("didSelectRowAt - ", indexPath.row)

        let viewController = { () -> UIViewController in
            switch self.source[indexPath.row] {
            case .two:
                return BasicsViewController(chapter: .two)
            case .three:
                return BasicsViewController(chapter: .three)
            case .four:
                return CombineViewController()
            case .five:
                return BasicsViewController(chapter: .five)
            }
        }()

        navigationController?
            .pushViewController(viewController, animated: true)
    }
}
