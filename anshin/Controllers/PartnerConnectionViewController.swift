//
//  PartnerConnectionViewController.swift
//  anshin
//
//  パートナー連携画面：ユーザーID検索とパートナー接続
//

import UIKit

class PartnerConnectionViewController: UIViewController {

    // MARK: - UI Elements
    private lazy var searchTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "ユーザーIDで検索..."
        textField.borderStyle = .roundedRect
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.addTarget(self, action: #selector(searchTextChanged), for: .editingChanged)
        return textField
    }()

    private lazy var searchResultsTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(PartnerUserSearchTableViewCell.self, forCellReuseIdentifier: "UserSearchCell")
        tableView.isHidden = true
        tableView.backgroundColor = UIColor.systemBackground
        tableView.isUserInteractionEnabled = true
        tableView.allowsSelection = true
        // デバッグ用の枠線
        tableView.layer.borderWidth = 1
        tableView.layer.borderColor = UIColor.systemBlue.cgColor
        return tableView
    }()

    private lazy var currentPartnersLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "現在のパートナー"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = UIColor.label
        return label
    }()

    private lazy var partnersTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(PartnerTableViewCell.self, forCellReuseIdentifier: "PartnerCell")
        return tableView
    }()

    private lazy var emptyStateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "パートナーが見つかりません\nユーザーIDで検索してパートナーを追加しましょう"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .systemGray2
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()

    // MARK: - Properties
    private let userManager = UserManager.shared
    private var searchResults: [User] = []
    private var currentPartners: [Partner] = []

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadCurrentPartners()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadCurrentPartners()
    }

    // MARK: - Setup
    private func setupUI() {
        title = "パートナー連携"
        view.backgroundColor = UIColor.systemBackground

        view.addSubview(searchTextField)
        view.addSubview(currentPartnersLabel)
        view.addSubview(partnersTableView)
        view.addSubview(emptyStateLabel)
        // 検索結果テーブルを最後に追加してz-indexを上げる
        view.addSubview(searchResultsTableView)

        setupConstraints()
        setupGestures()
    }

    private func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            // Search text field
            searchTextField.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 16),
            searchTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            searchTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            searchTextField.heightAnchor.constraint(equalToConstant: 44),

            // Search results table view
            searchResultsTableView.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: 12),
            searchResultsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchResultsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            searchResultsTableView.heightAnchor.constraint(equalToConstant: 200),

            // Current partners label
            currentPartnersLabel.topAnchor.constraint(equalTo: searchResultsTableView.bottomAnchor, constant: 20),
            currentPartnersLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            currentPartnersLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            // Partners table view
            partnersTableView.topAnchor.constraint(equalTo: currentPartnersLabel.bottomAnchor, constant: 12),
            partnersTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            partnersTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            partnersTableView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),

            // Empty state label
            emptyStateLabel.centerXAnchor.constraint(equalTo: partnersTableView.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: partnersTableView.centerYAnchor),
            emptyStateLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
            emptyStateLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20)
        ])
    }

    private func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    // MARK: - Actions
    @objc private func searchTextChanged() {
        guard let searchText = searchTextField.text, !searchText.isEmpty else {
            searchResults = []
            searchResultsTableView.reloadData()
            searchResultsTableView.isHidden = true
            print("DEBUG: 検索テキストが空 - 検索結果テーブルを非表示")
            return
        }

        // 作成されたユーザーを検索（自分以外）
        searchResults = userManager.searchUsers(byId: searchText)
        searchResultsTableView.reloadData()
        searchResultsTableView.isHidden = searchResults.isEmpty

        print("DEBUG: 検索実行 - テキスト: '\(searchText)', 結果数: \(searchResults.count)")
        print("DEBUG: 検索結果テーブル表示状態: \(!searchResultsTableView.isHidden)")
        print("DEBUG: 検索結果テーブルユーザーインタラクション: \(searchResultsTableView.isUserInteractionEnabled)")

        for (index, user) in searchResults.enumerated() {
            print("DEBUG: 検索結果[\(index)]: \(user.displayName) (ID: \(user.id))")
        }
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    // MARK: - Helper Methods
    private func loadCurrentPartners() {
        currentPartners = userManager.getConnectedPartners()
        partnersTableView.reloadData()
        updateEmptyState()
    }

    private func updateEmptyState() {
        emptyStateLabel.isHidden = !currentPartners.isEmpty
        partnersTableView.isHidden = currentPartners.isEmpty
    }

    private func sendPartnerRequest(to user: User) {
        print("DEBUG: sendPartnerRequest開始 - toUser: \(user.displayName) (ID: \(user.id))")
        let hasPendingRequest = userManager.hasPendingPartnerRequest(userId: user.id)

        let success = userManager.sendPartnerRequest(toUserId: user.id)
        print("DEBUG: sendPartnerRequest結果: \(success)")

        if success {
            let message = hasPendingRequest ?
                "\(user.displayName)さんにパートナーリクエストを再送信しました" :
                "\(user.displayName)さんにパートナーリクエストを送信しました"
            showAlert(title: "パートナーリクエスト送信", message: message) { [weak self] in
                // 検索結果をリフレッシュ
                self?.searchTextChanged()
            }
        } else {
            showAlert(title: "エラー", message: "パートナーリクエストの送信に失敗しました")
        }
    }

    private func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completion?()
        })
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension PartnerConnectionViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == searchResultsTableView {
            return searchResults.count
        } else {
            return currentPartners.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == searchResultsTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "UserSearchCell", for: indexPath) as! PartnerUserSearchTableViewCell
            let user = searchResults[indexPath.row]

            let partnerStatus: PartnerCellStatus
            if let status = userManager.getPartnerStatus(userId: user.id) {
                switch status {
                case .connected:
                    partnerStatus = .connected
                case .disconnected:
                    partnerStatus = .disconnected
                }
            } else {
                partnerStatus = .notPartner
            }

            cell.configure(with: user, partnerStatus: partnerStatus)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PartnerCell", for: indexPath) as! PartnerTableViewCell
            let partner = currentPartners[indexPath.row]
            cell.configure(with: partner)
            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        print("DEBUG: テーブルビューがタップされました - indexPath: \(indexPath)")
        print("DEBUG: searchResultsTableView: \(tableView == searchResultsTableView)")
        print("DEBUG: searchResults count: \(searchResults.count)")

        if tableView == searchResultsTableView {
            guard indexPath.row < searchResults.count else {
                print("DEBUG: インデックスが範囲外です")
                return
            }

            let user = searchResults[indexPath.row]
            print("DEBUG: 選択されたユーザー: \(user.displayName)")

            // パートナー状態をチェック
            let partnerStatus = userManager.getPartnerStatus(userId: user.id)

            if partnerStatus == .connected {
                showAlert(title: "既に連携済み", message: "\(user.displayName)さんとは既にパートナー連携済みです")
                return
            }

            let alertTitle = "パートナーリクエスト"
            let alertMessage: String
            let hasPendingRequest = userManager.hasPendingPartnerRequest(userId: user.id)

            if partnerStatus == .disconnected {
                if hasPendingRequest {
                    alertMessage = "\(user.displayName)さんとは過去にパートナー連携していました。\n既存のリクエストを置き換えて再送信しますか？"
                } else {
                    alertMessage = "\(user.displayName)さんとは過去にパートナー連携していました。\n再度パートナーリクエストを送信しますか？"
                }
            } else {
                if hasPendingRequest {
                    alertMessage = "\(user.displayName)さんに送信済みのリクエストがあります。\nリクエストを再送信しますか？"
                } else {
                    alertMessage = "\(user.displayName)さんにパートナーリクエストを送信しますか？"
                }
            }

            let alert = UIAlertController(
                title: alertTitle,
                message: alertMessage,
                preferredStyle: .alert
            )

            let buttonTitle = hasPendingRequest ? "再送信" : "送信"
            alert.addAction(UIAlertAction(title: buttonTitle, style: .default) { [weak self] _ in
                print("DEBUG: パートナーリクエスト\(buttonTitle)を開始")
                self?.sendPartnerRequest(to: user)
            })
            alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel))

            present(alert, animated: true)
        } else {
            print("DEBUG: パートナーテーブルビューがタップされました")
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if tableView == searchResultsTableView && !searchResults.isEmpty {
            return "検索結果"
        }
        return nil
    }
}

// MARK: - Custom Table View Cells

enum PartnerCellStatus {
    case connected
    case disconnected
    case notPartner
}

class PartnerUserSearchTableViewCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        self.isUserInteractionEnabled = true
        self.selectionStyle = .default
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with user: User, partnerStatus: PartnerCellStatus) {
        textLabel?.text = user.displayName

        switch partnerStatus {
        case .connected:
            detailTextLabel?.text = "ID: \(user.id) (連携中)"
            accessoryType = .checkmark
            selectionStyle = .none
            textLabel?.textColor = .systemGray
            isUserInteractionEnabled = false

        case .disconnected:
            detailTextLabel?.text = "ID: \(user.id) (過去に連携)"
            accessoryType = .disclosureIndicator
            selectionStyle = .default
            textLabel?.textColor = .systemOrange
            isUserInteractionEnabled = true

        case .notPartner:
            detailTextLabel?.text = "ID: \(user.id)"
            accessoryType = .disclosureIndicator
            selectionStyle = .default
            textLabel?.textColor = .label
            isUserInteractionEnabled = true
        }
    }
}

class PartnerTableViewCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with partner: Partner) {
        textLabel?.text = "\(partner.status.emoji) \(partner.userName)"
        detailTextLabel?.text = "ID: \(partner.userId) | \(partner.status.displayName)"
        accessoryType = .disclosureIndicator
    }
}