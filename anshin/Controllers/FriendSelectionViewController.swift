//
//  FriendSelectionViewController.swift
//  anshin
//
//  友達をカード形式で複数選択する画面
//

import UIKit

class FriendSelectionViewController: UIViewController {

    // MARK: - UI Elements
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
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
        label.text = "共有する友達を選択"
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textAlignment = .center
        label.textColor = UIColor.label
        return label
    }()

    private lazy var instructionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "カードをタップして複数選択できます"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .center
        label.textColor = UIColor.secondaryLabel
        label.numberOfLines = 0
        return label
    }()

    private lazy var cardsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .fill
        return stackView
    }()

    private lazy var shareButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("選択した友達を共有", for: .normal)
        button.backgroundColor = UIColor.systemGreen
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

    private lazy var selectedCountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "0人選択中"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .center
        label.textColor = UIColor.systemBlue
        return label
    }()

    private lazy var emptyStateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "共有する友達がいません\n先に友達を登録してください"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        label.textColor = UIColor.systemGray2
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()

    // MARK: - Properties
    var friendManager: FriendManager!
    private var friendCardViews: [FriendCardView] = []
    private var selectedFriends: [Friend] = []
    var onFriendsSelected: (([Friend]) -> Void)?

    // MARK: - Configuration
    func configure(with friendManager: FriendManager) {
        self.friendManager = friendManager
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFriendManager()
        setupUI()
        createFriendCards()
        updateUI()
    }

    private func setupFriendManager() {
        let userManager = UserManager.shared
        if let currentUser = userManager.currentUser {
            friendManager?.setCurrentUser(currentUser.id)
        }
    }

    // MARK: - Setup
    private func setupUI() {
        title = "友達を選択"
        view.backgroundColor = UIColor.systemBackground

        // Add subviews
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(titleLabel)
        contentView.addSubview(instructionLabel)
        contentView.addSubview(cardsStackView)
        contentView.addSubview(selectedCountLabel)
        contentView.addSubview(emptyStateLabel)

        view.addSubview(shareButton)
        view.addSubview(cancelButton)

        setupConstraints()
        updateShareButton()
    }

    private func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            // ScrollView constraints
            scrollView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: shareButton.topAnchor, constant: -16),

            // ContentView constraints
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            // Title label constraints
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            // Instruction label constraints
            instructionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            instructionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            instructionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            // Cards stack view constraints
            cardsStackView.topAnchor.constraint(equalTo: instructionLabel.bottomAnchor, constant: 24),
            cardsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            cardsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),

            // Selected count label constraints
            selectedCountLabel.topAnchor.constraint(equalTo: cardsStackView.bottomAnchor, constant: 16),
            selectedCountLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            selectedCountLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            selectedCountLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),

            // Empty state label constraints
            emptyStateLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            emptyStateLabel.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: 20),
            emptyStateLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -20),

            // Share button constraints
            shareButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            shareButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            shareButton.bottomAnchor.constraint(equalTo: cancelButton.topAnchor, constant: -12),
            shareButton.heightAnchor.constraint(equalToConstant: 56),

            // Cancel button constraints
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cancelButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            cancelButton.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -20),
            cancelButton.heightAnchor.constraint(equalToConstant: 56)
        ])
    }

    private func createFriendCards() {
        friendCardViews.removeAll()
        cardsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        for friend in friendManager.friends {
            let cardView = FriendCardView()
            cardView.configure(with: friend)

            // カードタップの処理
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cardTapped(_:)))
            cardView.addGestureRecognizer(tapGesture)
            cardView.tag = friendManager.friends.firstIndex { $0.id == friend.id } ?? 0

            cardView.heightAnchor.constraint(equalToConstant: 100).isActive = true

            friendCardViews.append(cardView)
            cardsStackView.addArrangedSubview(cardView)
        }
    }

    private func updateUI() {
        let hasFriends = !friendManager.friends.isEmpty

        cardsStackView.isHidden = !hasFriends
        selectedCountLabel.isHidden = !hasFriends
        instructionLabel.isHidden = !hasFriends
        emptyStateLabel.isHidden = hasFriends
        shareButton.isEnabled = hasFriends
    }

    private func updateShareButton() {
        let selectedCount = selectedFriends.count
        selectedCountLabel.text = "\(selectedCount)人選択中"

        shareButton.isEnabled = selectedCount > 0
        shareButton.alpha = selectedCount > 0 ? 1.0 : 0.5

        if selectedCount > 0 {
            shareButton.setTitle("選択した\(selectedCount)人を共有", for: .normal)
        } else {
            shareButton.setTitle("友達を選択してください", for: .normal)
        }
    }

    // MARK: - Actions
    @objc private func cardTapped(_ gesture: UITapGestureRecognizer) {
        guard let cardView = gesture.view as? FriendCardView,
              let friendIndex = friendCardViews.firstIndex(of: cardView),
              friendIndex < friendManager.friends.count else { return }

        let friend = friendManager.friends[friendIndex]

        if cardView.isSelected {
            // 選択解除
            cardView.isSelected = false
            selectedFriends.removeAll { $0.id == friend.id }
        } else {
            // 選択
            cardView.isSelected = true
            selectedFriends.append(friend)
        }

        updateShareButton()
    }

    @objc private func shareButtonTapped() {
        guard !selectedFriends.isEmpty else { return }

        onFriendsSelected?(selectedFriends)
        // 画面遷移はコールバック側で処理するため、ここでは戻らない
    }

    @objc private func cancelButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}