//
//  SharedFriendsViewController.swift
//  anshin
//
//  共有された友達一覧表示画面
//

import UIKit

class SharedFriendsViewController: UIViewController {

    // MARK: - UI Elements
    private lazy var headerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
        view.layer.cornerRadius = 12
        return view
    }()

    private lazy var shareInfoLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = UIColor.systemBlue
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private lazy var shareDetailsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()

    // MARK: - Properties
    private var sharedFriends: [Friend] = []
    private var shareInfo: ShareNotification?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateHeaderInfo()
    }

    // MARK: - Configuration
    func configure(with friends: [Friend], shareInfo: ShareNotification) {
        self.sharedFriends = friends
        self.shareInfo = shareInfo
    }

    // MARK: - Setup
    private func setupUI() {
        title = "共有された友達"
        view.backgroundColor = UIColor.systemBackground

        view.addSubview(headerView)
        headerView.addSubview(shareInfoLabel)
        headerView.addSubview(shareDetailsLabel)
        view.addSubview(tableView)

        setupConstraints()
    }

    private func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            // Header view constraints
            headerView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 16),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            // Share info label constraints
            shareInfoLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 16),
            shareInfoLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            shareInfoLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),

            // Share details label constraints
            shareDetailsLabel.topAnchor.constraint(equalTo: shareInfoLabel.bottomAnchor, constant: 8),
            shareDetailsLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            shareDetailsLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            shareDetailsLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -16),

            // Table view constraints
            tableView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor)
        ])
    }

    private func updateHeaderInfo() {
        guard let shareInfo = shareInfo else { return }

        shareInfoLabel.text = "\(shareInfo.fromUserName)さんからの共有"

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        dateFormatter.locale = Locale(identifier: "ja_JP")

        shareDetailsLabel.text = """
        用途: \(shareInfo.purpose)
        場所: \(shareInfo.location)
        日時: \(dateFormatter.string(from: shareInfo.dateTime))
        友達数: \(shareInfo.friendCount)人
        """
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension SharedFriendsViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sharedFriends.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "FriendCell")
        let friend = sharedFriends[indexPath.row]

        // 名前に性別絵文字を追加
        cell.textLabel?.text = "\(friend.gender.emoji) \(friend.name)"

        // 関係性と年齢を表示
        var detailText = friend.relationship.displayName
        if let age = friend.age {
            detailText += " (\(age)歳)"
        }

        if let details = friend.relationshipDetails, !details.isEmpty {
            detailText += " - \(details)"
        }

        cell.detailTextLabel?.text = detailText
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let friend = sharedFriends[indexPath.row]
        showFriendDetails(friend: friend)
    }

    private func showFriendDetails(friend: Friend) {
        var message = "関係性: \(friend.relationship.displayName)\n"
        message += "\(friend.relationship.description)\n\n"

        message += "性別: \(friend.gender.emoji) \(friend.gender.displayName)\n"
        message += "年齢: \(friend.displayAge)\n\n"

        if let details = friend.relationshipDetails, !details.isEmpty {
            message += "詳細: \(details)\n\n"
        }

        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "ja_JP")

        message += "登録日: \(formatter.string(from: friend.createdAt))\n"
        message += "最終更新: \(formatter.string(from: friend.lastUpdated))"

        let alert = UIAlertController(title: friend.name, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "閉じる", style: .cancel))

        present(alert, animated: true)
    }
}