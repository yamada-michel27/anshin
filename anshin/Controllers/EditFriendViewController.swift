//
//  EditFriendViewController.swift
//  anshin
//
//  友達情報編集画面のViewController
//

import UIKit

class EditFriendViewController: UIViewController {

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
        label.text = "友達情報を編集"
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textAlignment = .center
        label.textColor = UIColor.label
        return label
    }()

    private lazy var nameTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "友達の名前を入力してください"
        textField.borderStyle = .roundedRect
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        return textField
    }()

    private lazy var relationshipLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "関係性"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = UIColor.label
        return label
    }()

    private lazy var relationshipPicker: UIPickerView = {
        let picker = UIPickerView()
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.dataSource = self
        picker.delegate = self
        return picker
    }()

    private lazy var genderLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "性別"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = UIColor.label
        return label
    }()

    private lazy var genderSegmentedControl: UISegmentedControl = {
        let items = Gender.allCases.map { "\($0.emoji) \($0.displayName)" }
        let segmentedControl = UISegmentedControl(items: items)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        return segmentedControl
    }()

    private lazy var ageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "年齢（任意）"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = UIColor.label
        return label
    }()

    private lazy var ageTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "年齢を入力（例：25）"
        textField.borderStyle = .roundedRect
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.keyboardType = .numberPad
        return textField
    }()

    private lazy var detailsTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "詳細情報（任意）"
        textField.borderStyle = .roundedRect
        textField.font = UIFont.systemFont(ofSize: 16)
        return textField
    }()

    private lazy var saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("変更を保存", for: .normal)
        button.backgroundColor = UIColor.systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("友達を削除", for: .normal)
        button.backgroundColor = UIColor.systemRed
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("キャンセル", for: .normal)
        button.backgroundColor = UIColor.systemGray4
        button.setTitleColor(.label, for: .normal)
        button.layer.cornerRadius = 8
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        return button
    }()

    // MARK: - Properties
    var friendManager: FriendManager!
    var friendToEdit: Friend!
    var friendIndex: Int!
    var onFriendUpdated: (() -> Void)?
    var onFriendDeleted: (() -> Void)?

    private let relationshipTypes = RelationshipType.allCases
    private var selectedRelationship: RelationshipType = .friend

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFriendManager()
        setupUI()
        populateFields()
        updateSaveButtonState()
    }

    private func setupFriendManager() {
        let userManager = UserManager.shared
        if let currentUser = userManager.currentUser {
            friendManager?.setCurrentUser(currentUser.id)
        }
    }

    // MARK: - Setup
    private func setupUI() {
        title = "友達を編集"
        view.backgroundColor = UIColor.systemBackground

        // Add subviews
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(titleLabel)
        contentView.addSubview(nameTextField)
        contentView.addSubview(relationshipLabel)
        contentView.addSubview(relationshipPicker)
        contentView.addSubview(genderLabel)
        contentView.addSubview(genderSegmentedControl)
        contentView.addSubview(ageLabel)
        contentView.addSubview(ageTextField)
        contentView.addSubview(detailsTextField)
        contentView.addSubview(saveButton)
        contentView.addSubview(deleteButton)
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

            // Title label constraints
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            // Name text field constraints
            nameTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            nameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            nameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            nameTextField.heightAnchor.constraint(equalToConstant: 44),

            // Relationship label constraints
            relationshipLabel.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 20),
            relationshipLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            relationshipLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            // Relationship picker constraints
            relationshipPicker.topAnchor.constraint(equalTo: relationshipLabel.bottomAnchor, constant: 10),
            relationshipPicker.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            relationshipPicker.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            relationshipPicker.heightAnchor.constraint(equalToConstant: 120),

            // Details text field constraints
            detailsTextField.topAnchor.constraint(equalTo: relationshipPicker.bottomAnchor, constant: 20),
            detailsTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            detailsTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            detailsTextField.heightAnchor.constraint(equalToConstant: 44),

            // Save button constraints
            saveButton.topAnchor.constraint(equalTo: detailsTextField.bottomAnchor, constant: 30),
            saveButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            saveButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            saveButton.heightAnchor.constraint(equalToConstant: 50),

            // Delete button constraints
            deleteButton.topAnchor.constraint(equalTo: saveButton.bottomAnchor, constant: 12),
            deleteButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            deleteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            deleteButton.heightAnchor.constraint(equalToConstant: 50),

            // Cancel button constraints
            cancelButton.topAnchor.constraint(equalTo: deleteButton.bottomAnchor, constant: 12),
            cancelButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            cancelButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            cancelButton.heightAnchor.constraint(equalToConstant: 50),
            cancelButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }

    private func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }

    private func populateFields() {
        guard let friend = friendToEdit else { return }

        nameTextField.text = friend.name
        detailsTextField.text = friend.relationshipDetails
        selectedRelationship = friend.relationship

        // PickerViewで正しい関係性を選択
        if let index = relationshipTypes.firstIndex(of: friend.relationship) {
            relationshipPicker.selectRow(index, inComponent: 0, animated: false)
        }

        // 性別を設定
        if let genderIndex = Gender.allCases.firstIndex(of: friend.gender) {
            genderSegmentedControl.selectedSegmentIndex = genderIndex
        }

        // 年齢を設定
        if let age = friend.age {
            ageTextField.text = String(age)
        }
    }

    @objc private func textFieldDidChange() {
        updateSaveButtonState()
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    private func updateSaveButtonState() {
        let trimmedText = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let hasName = !trimmedText.isEmpty
        saveButton.isEnabled = hasName
        saveButton.alpha = hasName ? 1.0 : 0.5
    }

    // MARK: - Actions
    @objc private func saveButtonTapped(_ sender: UIButton) {
        guard let name = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !name.isEmpty else {
            showAlert(title: "エラー", message: "友達の名前を入力してください")
            return
        }

        let details = detailsTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let detailsToSave = !details.isEmpty ? details : nil

        // 性別を取得
        let selectedGender = Gender.allCases[genderSegmentedControl.selectedSegmentIndex]

        // 年齢を取得
        let ageText = ageTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let age = !ageText.isEmpty ? Int(ageText) : nil

        // 年齢の入力チェック
        if let ageText = ageTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
           !ageText.isEmpty,
           age == nil {
            showAlert(title: "エラー", message: "年齢は数字で入力してください")
            return
        }

        // 友達情報を更新
        friendManager.updateFriend(at: friendIndex, name: name, relationship: selectedRelationship, details: detailsToSave, gender: selectedGender, age: age)

        // Success feedback
        let successAlert = UIAlertController(title: "更新完了", message: "\(name)さんの情報を更新しました", preferredStyle: .alert)
        successAlert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            self.onFriendUpdated?()
            self.navigationController?.popViewController(animated: true)
        })
        present(successAlert, animated: true)
    }

    @objc private func deleteButtonTapped(_ sender: UIButton) {
        guard let friend = friendToEdit else { return }

        let alert = UIAlertController(
            title: "削除確認",
            message: "\(friend.name)さんを削除しますか？\n\nこの操作は取り消せません。",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "削除", style: .destructive) { [weak self] _ in
            guard let self = self else { return }

            self.friendManager.removeFriend(at: self.friendIndex)

            let successAlert = UIAlertController(title: "削除完了", message: "\(friend.name)さんを削除しました", preferredStyle: .alert)
            successAlert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                self.onFriendDeleted?()
                self.navigationController?.popViewController(animated: true)
            })
            self.present(successAlert, animated: true)
        })

        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel))
        present(alert, animated: true)
    }

    @objc private func cancelButtonTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }

    // MARK: - Helper Methods
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UIPickerViewDataSource & UIPickerViewDelegate
extension EditFriendViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return relationshipTypes.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return relationshipTypes[row].displayName
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedRelationship = relationshipTypes[row]
    }
}