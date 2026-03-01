//
//  ViewController.swift
//  anshin
//
//  メイン画面：友達一覧と機能へのアクセス
//

import UIKit

class ViewController: UIViewController {

    // MARK: - UI Elements
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()

    private lazy var addFriendButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("友達を追加", for: .normal)
        button.backgroundColor = UIColor.systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(addFriendButtonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var shareButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("予定共有", for: .normal)
        button.backgroundColor = UIColor.systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(shareButtonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var partnerConnectionButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("🔗 パートナー連携", for: .normal)
        button.backgroundColor = UIColor.systemOrange
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(partnerConnectionButtonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var emptyStateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "まだ友達が登録されていません\n「友達を追加」ボタンから\n最初の友達を登録してみましょう！"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .systemGray2
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()

    // MARK: - Properties
    private let friendManager = FriendManager()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFriendManagerForCurrentUser()
        setupUI()
        setupNavigationBar()
        updateUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupFriendManagerForCurrentUser()
        updateUI()
        setupNavigationBar() // 通知バッジを更新
    }

    // MARK: - Setup
    private func setupFriendManagerForCurrentUser() {
        let userManager = UserManager.shared
        if let currentUser = userManager.currentUser {
            friendManager.setCurrentUser(currentUser.id)
        }
    }

    // MARK: - UI Setup
    private func setupUI() {
        title = "ANSHIN"
        view.backgroundColor = UIColor.systemBackground

        // Add subviews
        view.addSubview(tableView)
        view.addSubview(addFriendButton)
        view.addSubview(shareButton)
        view.addSubview(partnerConnectionButton)
        view.addSubview(emptyStateLabel)

        setupConstraints()
    }

    private func setupNavigationBar() {
        // 左側：ユーザー情報
        let userManager = UserManager.shared
        if let currentUser = userManager.currentUser {
            navigationItem.leftBarButtonItem = UIBarButtonItem(
                title: currentUser.displayName,
                style: .plain,
                target: self,
                action: #selector(userInfoButtonTapped)
            )
        }

        // 右側：共有通知とログアウト
        let shareNotificationsButton = UIBarButtonItem(
            title: getNotificationButtonTitle(),
            style: .plain,
            target: self,
            action: #selector(shareNotificationsButtonTapped)
        )

        let logoutButton = UIBarButtonItem(
            title: "ログアウト",
            style: .plain,
            target: self,
            action: #selector(logoutButtonTapped)
        )

        navigationItem.rightBarButtonItems = [logoutButton, shareNotificationsButton]
    }

    private func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            // TableView constraints
            tableView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: addFriendButton.topAnchor, constant: -16),

            // Add friend button constraints
            addFriendButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addFriendButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addFriendButton.bottomAnchor.constraint(equalTo: shareButton.topAnchor, constant: -12),
            addFriendButton.heightAnchor.constraint(equalToConstant: 50),

            // Share button constraints
            shareButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            shareButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            shareButton.bottomAnchor.constraint(equalTo: partnerConnectionButton.topAnchor, constant: -12),
            shareButton.heightAnchor.constraint(equalToConstant: 50),

            // Partner connection button constraints
            partnerConnectionButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            partnerConnectionButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            partnerConnectionButton.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -20),
            partnerConnectionButton.heightAnchor.constraint(equalToConstant: 50),

            // Empty state label constraints
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
            emptyStateLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20)
        ])
    }

    private func updateUI() {
        tableView.reloadData()
        let hasFriends = !friendManager.friends.isEmpty

        tableView.isHidden = !hasFriends
        emptyStateLabel.isHidden = hasFriends

        // 共有ボタンは友達がいる時のみ有効、パートナー連携ボタンは常に有効
        shareButton.isEnabled = hasFriends
        shareButton.alpha = hasFriends ? 1.0 : 0.5
        partnerConnectionButton.isEnabled = true
        partnerConnectionButton.alpha = 1.0
    }

    // MARK: - Actions
    @objc private func addFriendButtonTapped(_ sender: UIButton) {
        let addFriendVC = AddFriendViewController()
        addFriendVC.friendManager = friendManager
        addFriendVC.onFriendAdded = { [weak self] in
            self?.updateUI()
        }
        navigationController?.pushViewController(addFriendVC, animated: true)
    }

    @objc private func shareButtonTapped(_ sender: UIButton) {
        // パートナー連携チェック
        let userManager = UserManager.shared
        guard let connectedPartner = userManager.getPartnerForSharing() else {
            showAlert(title: "パートナー未連携",
                     message: "友達カードを共有するには、まずパートナー連携を行ってください。\n\n🔗 パートナー連携ボタンから連携相手を設定できます。") { [weak self] in
                // パートナー連携画面に遷移
                self?.partnerConnectionButtonTapped(sender)
            }
            return
        }

        // 友達選択画面に遷移（パートナーへの自動送信用）
        let selectionVC = FriendSelectionViewController()
        selectionVC.friendManager = friendManager
        selectionVC.onFriendsSelected = { [weak self] selectedFriends in
            guard let self = self else { return }

            // 選択された友達をパートナーに自動送信
            self.sendFriendsToPartner(selectedFriends, partner: connectedPartner, from: selectionVC)
        }
        navigationController?.pushViewController(selectionVC, animated: true)
    }

    @objc private func partnerConnectionButtonTapped(_ sender: UIButton) {
        let partnerConnectionVC = PartnerConnectionViewController()
        navigationController?.pushViewController(partnerConnectionVC, animated: true)
    }

    @objc private func userInfoButtonTapped() {
        let userManager = UserManager.shared
        guard let currentUser = userManager.currentUser else { return }

        var message = "表示名: \(currentUser.displayName)\nユーザーID: \(currentUser.id)"
        if !currentUser.email.isEmpty {
            message += "\nメールアドレス: \(currentUser.email)"
        } else {
            message += "\nメールアドレス: 未登録"
        }

        let alert = UIAlertController(
            title: "ユーザー情報",
            message: message,
            preferredStyle: .actionSheet
        )

        alert.addAction(UIAlertAction(title: "IDをコピー", style: .default) { _ in
            UIPasteboard.general.string = currentUser.id

            let copyAlert = UIAlertController(
                title: "コピー完了",
                message: "ユーザーID「\(currentUser.id)」をコピーしました",
                preferredStyle: .alert
            )
            copyAlert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(copyAlert, animated: true)
        })

        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel))

        // iPadサポート
        if let popover = alert.popoverPresentationController {
            popover.barButtonItem = navigationItem.leftBarButtonItem
        }

        present(alert, animated: true)
    }

    @objc private func logoutButtonTapped() {
        let userManager = UserManager.shared
        guard let currentUser = userManager.currentUser else { return }

        let alert = UIAlertController(
            title: "ログアウト確認",
            message: "「\(currentUser.displayName)」からログアウトしますか？",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "ログアウト", style: .destructive) { [weak self] _ in
            userManager.logout()

            // ログイン画面に戻る
            if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                sceneDelegate.showLoginViewController()
            }
        })

        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel))
        present(alert, animated: true)
    }

    @objc private func shareNotificationsButtonTapped() {
        let userManager = UserManager.shared
        let shareNotificationsCount = userManager.getUnreadNotificationsForCurrentUser().count
        let partnerRequestsCount = userManager.getIncomingPartnerRequests().count

        if shareNotificationsCount > 0 && partnerRequestsCount > 0 {
            // 両方ある場合はアクションシートで選択
            let alert = UIAlertController(title: "通知の種類を選択", message: nil, preferredStyle: .actionSheet)

            alert.addAction(UIAlertAction(title: "友達共有通知 (\(shareNotificationsCount)件)", style: .default) { [weak self] _ in
                let shareNotificationsVC = ShareNotificationsViewController()
                self?.navigationController?.pushViewController(shareNotificationsVC, animated: true)
            })

            alert.addAction(UIAlertAction(title: "パートナーリクエスト (\(partnerRequestsCount)件)", style: .default) { [weak self] _ in
                let partnerRequestsVC = PartnerRequestsViewController()
                self?.navigationController?.pushViewController(partnerRequestsVC, animated: true)
            })

            alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel))

            // iPadサポート
            if let popover = alert.popoverPresentationController {
                popover.barButtonItem = navigationItem.rightBarButtonItems?.first
            }

            present(alert, animated: true)

        } else if partnerRequestsCount > 0 {
            // パートナーリクエストのみ
            let partnerRequestsVC = PartnerRequestsViewController()
            navigationController?.pushViewController(partnerRequestsVC, animated: true)

        } else {
            // 友達共有通知のみ、または両方なし
            let shareNotificationsVC = ShareNotificationsViewController()
            navigationController?.pushViewController(shareNotificationsVC, animated: true)
        }
    }

    private func sendFriendsToPartner(_ selectedFriends: [Friend], partner: Partner, from sourceVC: UIViewController) {
        // 新しい共有情報入力画面に遷移
        let shareInputVC = FriendShareInputViewController()
        shareInputVC.configure(with: selectedFriends, partner: partner)
        shareInputVC.onShareCompleted = { [weak self] in
            // 共有完了後の処理
            print("友達カード共有が完了しました")
        }
        sourceVC.navigationController?.pushViewController(shareInputVC, animated: true)
    }

    private func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completion?()
        })
        present(alert, animated: true)
    }

    private func getNotificationButtonTitle() -> String {
        let userManager = UserManager.shared
        let shareNotificationsCount = userManager.getUnreadNotificationsForCurrentUser().count
        let partnerRequestsCount = userManager.getIncomingPartnerRequests().count
        let totalUnreadCount = shareNotificationsCount + partnerRequestsCount

        if totalUnreadCount > 0 {
            return "🔴\(totalUnreadCount)"
        } else {
            return "🔔"
        }
    }
}

// MARK: - UITableViewDataSource
extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendManager.friends.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "FriendCell")
        let friend = friendManager.friends[indexPath.row]

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
}

// MARK: - UITableViewDelegate
extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let friend = friendManager.friends[indexPath.row]
        showFriendDetails(friend: friend, at: indexPath.row)
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let friend = friendManager.friends[indexPath.row]

            let alert = UIAlertController(title: "削除確認", message: "\(friend.name)さんを削除しますか？", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "削除", style: .destructive) { [weak self] _ in
                self?.friendManager.removeFriend(at: indexPath.row)
                self?.updateUI()
            })
            alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel))

            present(alert, animated: true)
        }
    }

    private func showFriendDetails(friend: Friend, at index: Int) {
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
        alert.addAction(UIAlertAction(title: "編集", style: .default) { [weak self] _ in
            self?.showEditFriendScreen(friend: friend, at: index)
        })
        alert.addAction(UIAlertAction(title: "閉じる", style: .cancel))

        present(alert, animated: true)
    }

    private func showEditFriendScreen(friend: Friend, at index: Int) {
        let editVC = EditFriendViewController()
        editVC.friendManager = friendManager
        editVC.friendToEdit = friend
        editVC.friendIndex = index
        editVC.onFriendUpdated = { [weak self] in
            self?.updateUI()
        }
        editVC.onFriendDeleted = { [weak self] in
            self?.updateUI()
        }
        navigationController?.pushViewController(editVC, animated: true)
    }
}
