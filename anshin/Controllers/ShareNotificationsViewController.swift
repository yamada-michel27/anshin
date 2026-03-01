//
//  ShareNotificationsViewController.swift
//  anshin
//
//  友達共有通知一覧画面
//

import UIKit

class ShareNotificationsViewController: UIViewController {

    // MARK: - UI Elements
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = UIColor.systemGroupedBackground
        tableView.register(ShareNotificationTableViewCell.self, forCellReuseIdentifier: "ShareNotificationCell")
        return tableView
    }()

    private lazy var emptyStateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "友達共有の通知はありません"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = UIColor.secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()

    // MARK: - Properties
    private let userManager = UserManager.shared
    private var notifications: [ShareNotification] = []

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadNotifications()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadNotifications()
    }

    // MARK: - Setup
    private func setupUI() {
        title = "共有通知"
        view.backgroundColor = UIColor.systemGroupedBackground

        view.addSubview(tableView)
        view.addSubview(emptyStateLabel)

        setupConstraints()
    }

    private func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            // Table view constraints
            tableView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),

            // Empty state label constraints
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            emptyStateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }

    // MARK: - Helper Methods
    private func loadNotifications() {
        notifications = userManager.getShareNotifications().filter { notification in
            guard let currentUserId = userManager.currentUser?.id else { return false }
            return notification.toUserId == currentUserId
        }.sorted { $0.createdAt > $1.createdAt }

        tableView.reloadData()
        updateEmptyState()
    }

    private func updateEmptyState() {
        emptyStateLabel.isHidden = !notifications.isEmpty
        tableView.isHidden = notifications.isEmpty
    }

    private func viewSharedFriends(for notification: ShareNotification) {
        // 通知を既読にする
        userManager.markNotificationAsRead(notificationId: notification.id)

        let friends = userManager.getSharedFriendsFromShare(shareId: notification.shareId)
        if !friends.isEmpty {
            let sharedFriendsVC = SharedFriendsViewController()
            sharedFriendsVC.configure(with: friends, shareInfo: notification)
            navigationController?.pushViewController(sharedFriendsVC, animated: true)
        } else {
            showAlert(title: "エラー", message: "共有された友達データが見つかりません")
        }

        // テーブルをリロードして既読状態を反映
        DispatchQueue.main.async { [weak self] in
            self?.loadNotifications()
        }
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension ShareNotificationsViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ShareNotificationCell", for: indexPath) as! ShareNotificationTableViewCell
        let notification = notifications[indexPath.row]
        cell.configure(with: notification)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let notification = notifications[indexPath.row]
        viewSharedFriends(for: notification)
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return notifications.isEmpty ? nil : "共有された友達カード"
    }
}

// MARK: - Custom Table View Cell
class ShareNotificationTableViewCell: UITableViewCell {

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with notification: ShareNotification) {
        let readStatus = notification.isRead ? "" : "🔴 "
        textLabel?.text = "\(readStatus)\(notification.fromUserName)さんから友達カード"

        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ja_JP")

        detailTextLabel?.text = "\(notification.friendCount)人の友達・\(notification.purpose)・\(notification.location)\n\(formatter.string(from: notification.dateTime))"
        detailTextLabel?.numberOfLines = 2

        accessoryType = .disclosureIndicator

        // 未読の場合は背景色を変更
        backgroundColor = notification.isRead ? UIColor.systemBackground : UIColor.systemBlue.withAlphaComponent(0.05)
    }
}