//
//  FriendShareInputViewController.swift
//  anshin
//
//  友達共有情報入力画面：用途・場所・日時の設定
//

import UIKit

class FriendShareInputViewController: UIViewController {

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
        label.text = "友達カード共有"
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textAlignment = .center
        label.textColor = UIColor.label
        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "共有する詳細情報を入力してください"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        label.textColor = UIColor.secondaryLabel
        label.numberOfLines = 0
        return label
    }()

    private lazy var selectedFriendsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.systemBlue
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private lazy var purposeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "用途"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()

    private lazy var purposeTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "例：飲み会、会議、イベント"
        textField.borderStyle = .roundedRect
        textField.font = UIFont.systemFont(ofSize: 16)
        return textField
    }()

    private lazy var locationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "場所"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()

    private lazy var locationTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "例：渋谷駅前、会社会議室"
        textField.borderStyle = .roundedRect
        textField.font = UIFont.systemFont(ofSize: 16)
        return textField
    }()

    private lazy var dateTimeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "日時"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()

    private lazy var dateTimePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.datePickerMode = .dateAndTime
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.minimumDate = Date()
        return datePicker
    }()

    private lazy var shareButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("パートナーに共有", for: .normal)
        button.backgroundColor = UIColor.systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.addTarget(self, action: #selector(shareButtonTapped), for: .touchUpInside)
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
    private var selectedFriends: [Friend] = []
    private var partner: Partner?
    var onShareCompleted: (() -> Void)?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    // MARK: - Configuration
    func configure(with friends: [Friend], partner: Partner) {
        self.selectedFriends = friends
        self.partner = partner
        updateSelectedFriendsLabel()
    }

    // MARK: - Setup
    private func setupUI() {
        title = "共有情報入力"
        view.backgroundColor = UIColor.systemBackground

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(selectedFriendsLabel)
        contentView.addSubview(purposeLabel)
        contentView.addSubview(purposeTextField)
        contentView.addSubview(locationLabel)
        contentView.addSubview(locationTextField)
        contentView.addSubview(dateTimeLabel)
        contentView.addSubview(dateTimePicker)
        contentView.addSubview(shareButton)
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

            // Title label
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            // Subtitle label
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            // Selected friends label
            selectedFriendsLabel.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 16),
            selectedFriendsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            selectedFriendsLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            // Purpose label
            purposeLabel.topAnchor.constraint(equalTo: selectedFriendsLabel.bottomAnchor, constant: 24),
            purposeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            purposeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            // Purpose text field
            purposeTextField.topAnchor.constraint(equalTo: purposeLabel.bottomAnchor, constant: 8),
            purposeTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            purposeTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            purposeTextField.heightAnchor.constraint(equalToConstant: 50),

            // Location label
            locationLabel.topAnchor.constraint(equalTo: purposeTextField.bottomAnchor, constant: 20),
            locationLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            locationLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            // Location text field
            locationTextField.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 8),
            locationTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            locationTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            locationTextField.heightAnchor.constraint(equalToConstant: 50),

            // DateTime label
            dateTimeLabel.topAnchor.constraint(equalTo: locationTextField.bottomAnchor, constant: 20),
            dateTimeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            dateTimeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            // DateTime picker
            dateTimePicker.topAnchor.constraint(equalTo: dateTimeLabel.bottomAnchor, constant: 8),
            dateTimePicker.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            dateTimePicker.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            // Share button
            shareButton.topAnchor.constraint(equalTo: dateTimePicker.bottomAnchor, constant: 30),
            shareButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            shareButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            shareButton.heightAnchor.constraint(equalToConstant: 56),

            // Cancel button
            cancelButton.topAnchor.constraint(equalTo: shareButton.bottomAnchor, constant: 12),
            cancelButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            cancelButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            cancelButton.heightAnchor.constraint(equalToConstant: 50),
            cancelButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30)
        ])
    }

    private func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }

    private func updateSelectedFriendsLabel() {
        let friendNames = selectedFriends.map { $0.name }.joined(separator: ", ")
        selectedFriendsLabel.text = "共有する友達: \(friendNames) (\(selectedFriends.count)人)"
    }

    // MARK: - Actions
    @objc private func shareButtonTapped() {
        guard let purpose = purposeTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !purpose.isEmpty else {
            showAlert(title: "入力エラー", message: "用途を入力してください")
            return
        }

        guard let location = locationTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !location.isEmpty else {
            showAlert(title: "入力エラー", message: "場所を入力してください")
            return
        }

        guard let partner = partner else {
            showAlert(title: "エラー", message: "パートナー情報が見つかりません")
            return
        }

        let selectedDateTime = dateTimePicker.date

        let success = userManager.shareFriends(
            toUserId: partner.userId,
            friends: selectedFriends,
            purpose: purpose,
            location: location,
            dateTime: selectedDateTime
        )

        if success {
            showAlert(title: "共有完了", message: "\(partner.userName)さんに友達カードを共有しました") { [weak self] in
                self?.onShareCompleted?()
                self?.navigationController?.popToRootViewController(animated: true)
            }
        } else {
            showAlert(title: "エラー", message: "友達カードの共有に失敗しました")
        }
    }

    @objc private func cancelButtonTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    // MARK: - Helper Methods
    private func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completion?()
        })
        present(alert, animated: true)
    }
}