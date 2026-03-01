//
//  PartnerRequestsViewController.swift
//  anshin
//
//  パートナーリクエスト通知一覧画面
//

import UIKit

class PartnerRequestsViewController: UIViewController {

    // MARK: - UI Elements
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = UIColor.systemGroupedBackground
        // Using default UITableViewCell (subtitle style will be set in cellForRowAt)
        return tableView
    }()

    private lazy var emptyStateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "パートナーリクエストはありません"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = UIColor.secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()

    // MARK: - Properties
    private let userManager = UserManager.shared
    private var partnerRequests: [PartnerRequest] = []

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadPartnerRequests()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadPartnerRequests()
    }

    // MARK: - Setup
    private func setupUI() {
        title = "パートナーリクエスト"
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
    private func loadPartnerRequests() {
        partnerRequests = userManager.getIncomingPartnerRequests()
        tableView.reloadData()
        updateEmptyState()
    }

    private func updateEmptyState() {
        emptyStateLabel.isHidden = !partnerRequests.isEmpty
        tableView.isHidden = partnerRequests.isEmpty
    }

    private func handlePartnerRequest(_ request: PartnerRequest) {
        let alert = UIAlertController(
            title: "パートナーリクエスト",
            message: "\(request.fromUserName)さんからのパートナー連携リクエストです",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "承認", style: .default) { [weak self] _ in
            if self?.userManager.respondToPartnerRequest(requestId: request.id, accepted: true) == true {
                self?.showAlert(title: "承認完了", message: "\(request.fromUserName)さんとパートナー連携しました") {
                    self?.loadPartnerRequests()
                }
            } else {
                self?.showAlert(title: "エラー", message: "パートナーリクエストの承認に失敗しました")
            }
        })

        alert.addAction(UIAlertAction(title: "拒否", style: .destructive) { [weak self] _ in
            if self?.userManager.respondToPartnerRequest(requestId: request.id, accepted: false) == true {
                self?.showAlert(title: "拒否完了", message: "\(request.fromUserName)さんからのパートナーリクエストを拒否しました") {
                    self?.loadPartnerRequests()
                }
            } else {
                self?.showAlert(title: "エラー", message: "パートナーリクエストの拒否に失敗しました")
            }
        })

        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel))
        present(alert, animated: true)
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
extension PartnerRequestsViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return partnerRequests.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PartnerRequestCell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "PartnerRequestCell")
        let request = partnerRequests[indexPath.row]
        cell.textLabel?.text = request.fromUserName
        cell.detailTextLabel?.text = "パートナーリクエスト"
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let request = partnerRequests[indexPath.row]
        handlePartnerRequest(request)
    }
}