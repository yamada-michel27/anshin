//
//  LoginViewController.swift
//  anshin
//
//  ID・パスワード認証とアカウント管理画面
//

import UIKit

class LoginViewController: UIViewController {

    // MARK: - UI Elements
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var logoLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "ANSHIN"
        label.font = UIFont.boldSystemFont(ofSize: 48)
        label.textAlignment = .center
        label.textColor = UIColor.systemBlue
        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "パートナーと友達関係を安心共有"
        label.font = UIFont.systemFont(ofSize: 18)
        label.textAlignment = .center
        label.textColor = UIColor.secondaryLabel
        return label
    }()

    // アカウント一覧
    private lazy var accountsTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = UIColor.clear
        tableView.register(AccountTableViewCell.self, forCellReuseIdentifier: "AccountCell")
        return tableView
    }()

    private lazy var createAccountButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("+ 新しいアカウントを作成", for: .normal)
        button.backgroundColor = UIColor.systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.addTarget(self, action: #selector(createAccountButtonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var passwordResetButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("パスワードを忘れた場合", for: .normal)
        button.backgroundColor = UIColor.systemGray5
        button.setTitleColor(.systemBlue, for: .normal)
        button.layer.cornerRadius = 12
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.addTarget(self, action: #selector(passwordResetButtonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var emptyStateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "アカウントがありません\n新しいアカウントを作成してください"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = UIColor.secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()

    // MARK: - Properties
    private let userManager = UserManager.shared
    private var accounts: [User] = []
    var onLoginSuccess: (() -> Void)?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadAccounts()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadAccounts()
    }

    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = UIColor.systemBackground

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(logoLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(accountsTableView)
        contentView.addSubview(emptyStateLabel)
        contentView.addSubview(createAccountButton)
        contentView.addSubview(passwordResetButton)

        setupConstraints()
    }

    private func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            // ScrollView constraints
            scrollView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),

            // ContentView constraints
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            // Logo constraints
            logoLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 60),
            logoLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            logoLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            // Subtitle constraints
            subtitleLabel.topAnchor.constraint(equalTo: logoLabel.bottomAnchor, constant: 16),
            subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            // Accounts table view constraints
            accountsTableView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 40),
            accountsTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            accountsTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            accountsTableView.heightAnchor.constraint(equalToConstant: 300),

            // Empty state label constraints
            emptyStateLabel.centerYAnchor.constraint(equalTo: accountsTableView.centerYAnchor),
            emptyStateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40),
            emptyStateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40),

            // Create account button constraints
            createAccountButton.topAnchor.constraint(equalTo: accountsTableView.bottomAnchor, constant: 30),
            createAccountButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            createAccountButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            createAccountButton.heightAnchor.constraint(equalToConstant: 56),

            // Password reset button constraints
            passwordResetButton.topAnchor.constraint(equalTo: createAccountButton.bottomAnchor, constant: 12),
            passwordResetButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            passwordResetButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            passwordResetButton.heightAnchor.constraint(equalToConstant: 50),
            passwordResetButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
        ])
    }

    private func loadAccounts() {
        accounts = userManager.getAllUsers()
        updateUI()
    }

    private func updateUI() {
        accountsTableView.reloadData()
        emptyStateLabel.isHidden = !accounts.isEmpty
        accountsTableView.isHidden = accounts.isEmpty
    }

    // MARK: - Actions
    @objc private func createAccountButtonTapped() {
        let createAccountVC = CreateAccountViewController()
        createAccountVC.onAccountCreated = { [weak self] in
            self?.loadAccounts()
        }

        let navController = UINavigationController(rootViewController: createAccountVC)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true)
    }

    @objc private func passwordResetButtonTapped() {
        let passwordResetVC = PasswordResetViewController()

        let navController = UINavigationController(rootViewController: passwordResetVC)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true)
    }

    private func loginWithAccount(_ account: User) {
        // パスワード確認
        showPasswordPrompt(for: account)
    }

    private func showPasswordPrompt(for account: User) {
        let alert = UIAlertController(
            title: "パスワード入力",
            message: "\(account.displayName) でログインします",
            preferredStyle: .alert
        )

        alert.addTextField { textField in
            textField.placeholder = "パスワードを入力"
            textField.isSecureTextEntry = true
        }

        alert.addAction(UIAlertAction(title: "ログイン", style: .default) { [weak self] _ in
            guard let password = alert.textFields?.first?.text,
                  !password.isEmpty else {
                self?.showAlert(title: "エラー", message: "パスワードを入力してください")
                return
            }

            // 簡易パスワード確認（実際のアプリではより安全な方法を使用）
            if self?.userManager.loginUser(userId: account.id, password: password) == true {
                self?.onLoginSuccess?()
            } else {
                self?.showAlert(title: "ログインエラー", message: "パスワードが正しくありません")
            }
        })

        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel))
        present(alert, animated: true)
    }

    private func showAccountMenu(for account: User) {
        let alert = UIAlertController(title: account.displayName, message: "ID: \(account.id)", preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "ログイン", style: .default) { [weak self] _ in
            self?.loginWithAccount(account)
        })

        alert.addAction(UIAlertAction(title: "IDをコピー", style: .default) { _ in
            UIPasteboard.general.string = account.id
            // コピー完了のフィードバック
            let copyAlert = UIAlertController(title: "コピー完了", message: "ユーザーID「\(account.id)」をコピーしました", preferredStyle: .alert)
            copyAlert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(copyAlert, animated: true)
        })

        alert.addAction(UIAlertAction(title: "アカウント削除", style: .destructive) { [weak self] _ in
            self?.confirmDeleteAccount(account)
        })

        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel))

        if let popover = alert.popoverPresentationController {
            // iPadサポート
            popover.sourceView = view
            popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
        }

        present(alert, animated: true)
    }

    private func confirmDeleteAccount(_ account: User) {
        let alert = UIAlertController(
            title: "アカウント削除",
            message: "「\(account.displayName)」を削除しますか？\n\nこの操作は取り消せません。",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "削除", style: .destructive) { [weak self] _ in
            self?.userManager.deleteUser(userId: account.id)
            self?.loadAccounts()
        })

        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel))
        present(alert, animated: true)
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension LoginViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return accounts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AccountCell", for: indexPath) as? AccountTableViewCell else {
            return UITableViewCell()
        }

        let account = accounts[indexPath.row]
        cell.configure(with: account)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let account = accounts[indexPath.row]
        showAccountMenu(for: account)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return accounts.isEmpty ? nil : "アカウント一覧"
    }
}

// MARK: - AccountTableViewCell
class AccountTableViewCell: UITableViewCell {

    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.systemBackground
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowOpacity = 0.1
        view.layer.shadowRadius = 4
        return view
    }()

    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = UIColor.label
        return label
    }()

    private lazy var idLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.secondaryLabel
        return label
    }()

    private lazy var arrowImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "chevron.right")
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = UIColor.systemGray3
        return imageView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = UIColor.clear
        selectionStyle = .none

        contentView.addSubview(containerView)
        containerView.addSubview(nameLabel)
        containerView.addSubview(idLabel)
        containerView.addSubview(arrowImageView)

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),

            nameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            nameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: arrowImageView.leadingAnchor, constant: -12),

            idLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            idLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            idLabel.trailingAnchor.constraint(equalTo: arrowImageView.leadingAnchor, constant: -12),
            idLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),

            arrowImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            arrowImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            arrowImageView.widthAnchor.constraint(equalToConstant: 16),
            arrowImageView.heightAnchor.constraint(equalToConstant: 16)
        ])
    }

    func configure(with user: User) {
        nameLabel.text = user.displayName
        idLabel.text = "ID: \(user.id)"
    }
}