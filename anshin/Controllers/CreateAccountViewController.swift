//
//  CreateAccountViewController.swift
//  anshin
//
//  新規アカウント作成画面
//

import UIKit

class CreateAccountViewController: UIViewController {

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

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "新しいアカウントを作成"
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textAlignment = .center
        label.textColor = UIColor.label
        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "表示名とパスワードを設定してください"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        label.textColor = UIColor.secondaryLabel
        label.numberOfLines = 0
        return label
    }()

    private lazy var displayNameTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "表示名（例：田中太郎）"
        textField.borderStyle = .roundedRect
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        return textField
    }()

    private lazy var emailTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "メールアドレス（パスワード忘れ時に使用）"
        textField.borderStyle = .roundedRect
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.keyboardType = .emailAddress
        textField.autocapitalizationType = .none
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        return textField
    }()

    private lazy var passwordTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "パスワード（4文字以上）"
        textField.borderStyle = .roundedRect
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.isSecureTextEntry = true
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        return textField
    }()

    private lazy var confirmPasswordTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "パスワード確認"
        textField.borderStyle = .roundedRect
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.isSecureTextEntry = true
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        return textField
    }()

    private lazy var userIdPreviewContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.systemBlue.cgColor
        return view
    }()

    private lazy var userIdLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "あなたのユーザーID（自動生成）："
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.secondaryLabel
        return label
    }()

    private lazy var userIdValueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = UIColor.systemBlue
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private lazy var copyIdButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("IDをコピー", for: .normal)
        button.backgroundColor = UIColor.systemGray5
        button.setTitleColor(.systemBlue, for: .normal)
        button.layer.cornerRadius = 8
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.addTarget(self, action: #selector(copyIdButtonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var createButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("アカウントを作成", for: .normal)
        button.backgroundColor = UIColor.systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        button.isEnabled = false
        button.alpha = 0.5
        return button
    }()

    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("キャンセル", for: .normal)
        button.backgroundColor = UIColor.systemGray4
        button.setTitleColor(.label, for: .normal)
        button.layer.cornerRadius = 12
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        return button
    }()

    // MARK: - Properties
    private let userManager = UserManager.shared
    private var generatedUserId: String = ""
    var onAccountCreated: (() -> Void)?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        generateUserId()
    }

    // MARK: - Setup
    private func setupUI() {
        title = "アカウント作成"
        view.backgroundColor = UIColor.systemBackground

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(displayNameTextField)
        contentView.addSubview(emailTextField)
        contentView.addSubview(passwordTextField)
        contentView.addSubview(confirmPasswordTextField)
        contentView.addSubview(userIdPreviewContainer)
        userIdPreviewContainer.addSubview(userIdLabel)
        userIdPreviewContainer.addSubview(userIdValueLabel)
        userIdPreviewContainer.addSubview(copyIdButton)
        contentView.addSubview(createButton)
        contentView.addSubview(cancelButton)

        setupConstraints()
        setupGestures()
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

            // Title constraints
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 30),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            // Subtitle constraints
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            // Display name text field constraints
            displayNameTextField.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 40),
            displayNameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            displayNameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            displayNameTextField.heightAnchor.constraint(equalToConstant: 50),

            // Email text field constraints
            emailTextField.topAnchor.constraint(equalTo: displayNameTextField.bottomAnchor, constant: 16),
            emailTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            emailTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            emailTextField.heightAnchor.constraint(equalToConstant: 50),

            // Password text field constraints
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 16),
            passwordTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            passwordTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            passwordTextField.heightAnchor.constraint(equalToConstant: 50),

            // Confirm password text field constraints
            confirmPasswordTextField.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 16),
            confirmPasswordTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            confirmPasswordTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            confirmPasswordTextField.heightAnchor.constraint(equalToConstant: 50),

            // User ID preview container constraints
            userIdPreviewContainer.topAnchor.constraint(equalTo: confirmPasswordTextField.bottomAnchor, constant: 30),
            userIdPreviewContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            userIdPreviewContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            // User ID label constraints
            userIdLabel.topAnchor.constraint(equalTo: userIdPreviewContainer.topAnchor, constant: 16),
            userIdLabel.leadingAnchor.constraint(equalTo: userIdPreviewContainer.leadingAnchor, constant: 16),
            userIdLabel.trailingAnchor.constraint(equalTo: userIdPreviewContainer.trailingAnchor, constant: -16),

            // User ID value label constraints
            userIdValueLabel.topAnchor.constraint(equalTo: userIdLabel.bottomAnchor, constant: 8),
            userIdValueLabel.leadingAnchor.constraint(equalTo: userIdPreviewContainer.leadingAnchor, constant: 16),
            userIdValueLabel.trailingAnchor.constraint(equalTo: userIdPreviewContainer.trailingAnchor, constant: -16),

            // Copy ID button constraints
            copyIdButton.topAnchor.constraint(equalTo: userIdValueLabel.bottomAnchor, constant: 12),
            copyIdButton.centerXAnchor.constraint(equalTo: userIdPreviewContainer.centerXAnchor),
            copyIdButton.widthAnchor.constraint(equalToConstant: 120),
            copyIdButton.heightAnchor.constraint(equalToConstant: 36),
            copyIdButton.bottomAnchor.constraint(equalTo: userIdPreviewContainer.bottomAnchor, constant: -16),

            // Create button constraints
            createButton.topAnchor.constraint(equalTo: userIdPreviewContainer.bottomAnchor, constant: 40),
            createButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            createButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            createButton.heightAnchor.constraint(equalToConstant: 56),

            // Cancel button constraints
            cancelButton.topAnchor.constraint(equalTo: createButton.bottomAnchor, constant: 12),
            cancelButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            cancelButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            cancelButton.heightAnchor.constraint(equalToConstant: 50),
            cancelButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
        ])
    }

    private func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }

    private func generateUserId() {
        generatedUserId = UUID().uuidString.prefix(8).uppercased() + String(Int.random(in: 1000...9999))
        userIdValueLabel.text = generatedUserId
    }

    // MARK: - Actions
    @objc private func textFieldDidChange() {
        updateCreateButtonState()
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc private func copyIdButtonTapped() {
        UIPasteboard.general.string = generatedUserId

        let alert = UIAlertController(title: "コピー完了", message: "ユーザーID「\(generatedUserId)」をクリップボードにコピーしました", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    @objc private func createButtonTapped() {
        guard let displayName = displayNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !displayName.isEmpty,
              let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              let password = passwordTextField.text,
              let confirmPassword = confirmPasswordTextField.text else {
            showAlert(title: "エラー", message: "すべての項目を入力してください")
            return
        }

        // メールアドレスの簡単なバリデーション
        if !email.isEmpty && !isValidEmail(email) {
            showAlert(title: "エラー", message: "有効なメールアドレスを入力してください")
            return
        }

        guard password.count >= 4 else {
            showAlert(title: "エラー", message: "パスワードは4文字以上で入力してください")
            return
        }

        guard password == confirmPassword else {
            showAlert(title: "エラー", message: "パスワードが一致しません")
            return
        }

        // アカウント作成
        if userManager.createUserWithPassword(displayName: displayName, userId: generatedUserId, email: email, password: password) {
            let emailInfo = email.isEmpty ? "" : "\nメールアドレス: \(email)"
            showAlert(title: "作成完了", message: "アカウント「\(displayName)」を作成しました\n\nユーザーID: \(generatedUserId)\(emailInfo)") { [weak self] in
                self?.onAccountCreated?()
                self?.dismiss(animated: true)
            }
        } else {
            showAlert(title: "エラー", message: "アカウントの作成に失敗しました\n既にユーザーIDまたはメールアドレスが使用されている可能性があります")
        }
    }

    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
    }

    // MARK: - Helper Methods
    private func updateCreateButtonState() {
        let displayName = displayNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let password = passwordTextField.text ?? ""
        let confirmPassword = confirmPasswordTextField.text ?? ""

        let isValid = !displayName.isEmpty &&
                      password.count >= 4 &&
                      password == confirmPassword

        createButton.isEnabled = isValid
        createButton.alpha = isValid ? 1.0 : 0.5
    }

    private func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completion?()
        })
        present(alert, animated: true)
    }

    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
}