//
//  FriendCardView.swift
//  anshin
//
//  友達情報をカード型で表示するUIコンポーネント
//

import UIKit

class FriendCardView: UIView {

    // MARK: - UI Elements
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
        label.numberOfLines = 1
        return label
    }()

    private lazy var relationshipLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.systemBlue
        label.numberOfLines = 1
        return label
    }()

    private lazy var detailsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.secondaryLabel
        label.numberOfLines = 2
        return label
    }()

    private lazy var relationshipIconView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
        view.layer.cornerRadius = 6
        return view
    }()

    private lazy var checkmarkView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "checkmark.circle.fill")
        imageView.tintColor = UIColor.systemGreen
        imageView.isHidden = true
        return imageView
    }()

    // MARK: - Properties
    private var friend: Friend?
    var isSelected: Bool = false {
        didSet {
            updateSelectionState()
        }
    }

    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    // MARK: - Setup
    private func setupUI() {
        backgroundColor = UIColor.clear

        addSubview(containerView)
        containerView.addSubview(nameLabel)
        containerView.addSubview(relationshipLabel)
        containerView.addSubview(detailsLabel)
        containerView.addSubview(relationshipIconView)
        containerView.addSubview(checkmarkView)

        setupConstraints()

        // タップジェスチャーを追加
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cardTapped))
        addGestureRecognizer(tapGesture)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Container view constraints
            containerView.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4),

            // Relationship icon constraints
            relationshipIconView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            relationshipIconView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            relationshipIconView.widthAnchor.constraint(equalToConstant: 12),
            relationshipIconView.heightAnchor.constraint(equalToConstant: 12),

            // Checkmark constraints
            checkmarkView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            checkmarkView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            checkmarkView.widthAnchor.constraint(equalToConstant: 24),
            checkmarkView.heightAnchor.constraint(equalToConstant: 24),

            // Name label constraints
            nameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            nameLabel.leadingAnchor.constraint(equalTo: relationshipIconView.trailingAnchor, constant: 8),
            nameLabel.trailingAnchor.constraint(equalTo: checkmarkView.leadingAnchor, constant: -8),

            // Relationship label constraints
            relationshipLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            relationshipLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            relationshipLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),

            // Details label constraints
            detailsLabel.topAnchor.constraint(equalTo: relationshipLabel.bottomAnchor, constant: 4),
            detailsLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            detailsLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            detailsLabel.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -12)
        ])
    }

    // MARK: - Configuration
    func configure(with friend: Friend) {
        self.friend = friend

        // 名前に性別絵文字を追加
        nameLabel.text = "\(friend.gender.emoji) \(friend.name)"

        // 関係性に年齢を追加
        var relationshipText = friend.relationship.displayName
        if let age = friend.age {
            relationshipText += " (\(age)歳)"
        }
        relationshipLabel.text = relationshipText

        if let details = friend.relationshipDetails, !details.isEmpty {
            detailsLabel.text = details
            detailsLabel.isHidden = false
        } else {
            detailsLabel.text = friend.relationship.description
            detailsLabel.isHidden = false
        }

        // 関係性に応じて色を変更
        let relationshipColor = colorForRelationship(friend.relationship)
        relationshipIconView.backgroundColor = relationshipColor.withAlphaComponent(0.1)
        relationshipLabel.textColor = relationshipColor
    }

    private func colorForRelationship(_ relationship: RelationshipType) -> UIColor {
        switch relationship {
        case .friend:
            return .systemBlue
        case .family:
            return .systemRed
        case .colleague:
            return .systemCyan
        case .classmate:
            return .systemGreen
        case .clubmate:
            return .systemOrange
        case .partTimeJob:
            return .systemMint
        case .neighbor:
            return .systemPurple
        case .familyFriend:
            return .systemPink
        case .exColleague:
            return .systemGray
        case .hobbyFriend:
            return .systemTeal
        case .onlineFriend:
            return .systemIndigo
        case .childhoodFriend:
            return .systemBrown
        case .other:
            return .systemYellow
        }
    }

    private func updateSelectionState() {
        UIView.animate(withDuration: 0.2) {
            if self.isSelected {
                self.containerView.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
                self.containerView.layer.borderWidth = 2
                self.containerView.layer.borderColor = UIColor.systemBlue.cgColor
                self.checkmarkView.isHidden = false
            } else {
                self.containerView.backgroundColor = UIColor.systemBackground
                self.containerView.layer.borderWidth = 0
                self.checkmarkView.isHidden = true
            }
        }
    }

    @objc private func cardTapped() {
        isSelected.toggle()
    }

    // MARK: - Public Methods
    func setSelected(_ selected: Bool, animated: Bool = true) {
        if animated {
            isSelected = selected
        } else {
            UIView.performWithoutAnimation {
                isSelected = selected
            }
        }
    }
}