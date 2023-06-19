//
//  AccountCredentialsMediatingController.swift
//  VaultPass - Password Manager
//
//  Created by Andrew Masters on 4/2/23.
//

import UIKit

protocol AccountCredentialsDelegate {
    func accountCredentialsViewDidLoad(_ controller: UIViewController)
    func accountCredentialsViewDidAppear(_ displayable: AccountCredentialsDisplayable)
    func accountCredentialsAddButtonPressed()
    func accountCredentialsSettingsButtonPressed()
    func accountCredentialsSaveCredentials(_ credentials: [AccountCredential])
    func accountCredentialsEditCredential(index: Int)
}

protocol AccountCredentialsDisplayable {
    func updateAccountCredentials(_ credentials: [AccountCredential])
    func displayError()
}

class AccountCredentialsMediatingController: UIViewController, AccountCredentialsDisplayable {
    
    @IBOutlet private(set) var tableview: UITableView!
    @IBOutlet private(set) var searchBar: UISearchBar!
    
    var delegate: AccountCredentialsDelegate?
    
    private var credentials: [AccountCredential] = []
    private var filtered: [AccountCredential] = []
    
    private let cellIdentifier = "AccountCredentialCell"
    private var copyToClipboardConfirmationView: CopyToClipboardConfirmationView?
    private let clipboard = UIPasteboard.general
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate?.accountCredentialsViewDidLoad(self)
        self.registerTableView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.delegate?.accountCredentialsViewDidAppear(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.configureNavigationBar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.dismissClipboardView()
    }
    
    private func registerTableView() {
        self.tableview.dataSource = self
        self.tableview.delegate = self
        self.tableview.register(UINib(nibName: cellIdentifier, bundle: nil), forCellReuseIdentifier: cellIdentifier)
        self.tableview.keyboardDismissMode = .onDrag
    }

    private func configureNavigationBar() {
        self.navigationItem.title = "My Credentials"
        self.navigationItem.setLeftBarButton(makeSettingsButton(), animated: false)
        self.navigationItem.setRightBarButton(makeAddButton(), animated: false)
    }
    
    func updateAccountCredentials(_ credentials: [AccountCredential]) {
        self.credentials = credentials
        self.tableview.reloadData()
    }
    
    func displayError() {
        // TODO: create and display an error pop up.
    }
    
    private func makeAddButton() -> UIBarButtonItem {
        let button = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(addButtonPressed))
        button.tintColor = .systemBlue
        return button
    }
    
    private func makeSettingsButton() -> UIBarButtonItem {
        let button = UIBarButtonItem(image: UIImage(systemName: "gear"), style: .plain, target: self, action: #selector(settingsButtonPressed))
        button.tintColor = .systemBlue
        return button
    }
    
    @objc func addButtonPressed() {
        self.delegate?.accountCredentialsAddButtonPressed()
    }
    
    @objc func settingsButtonPressed() {
        self.delegate?.accountCredentialsSettingsButtonPressed()
    }
    
    private func searchIsActive() -> Bool {
        if let searchText = self.searchBar.text, searchText.isEmpty == false {
            return true
        }
        return false
    }
}

extension AccountCredentialsMediatingController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.searchIsActive() {
            return filtered.count
        }
        return credentials.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? AccountCredentialCell else {
            return UITableViewCell()
        }
        if self.searchIsActive() {
            let credential = self.filtered[indexPath.row]
            cell.configureCell(delegate: self, credential: credential, index: nil)
        } else {
            let credential = self.credentials[indexPath.row]
            cell.configureCell(delegate: self, credential: credential, index: indexPath.row)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? AccountCredentialCell else {
            return
        }
        cell.reveal()
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? AccountCredentialCell else {
            return
        }
        cell.hideCredentials()
    }
}

extension AccountCredentialsMediatingController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty == false {
            self.filtered = self.credentials.filter({
                $0.title.lowercased().contains(searchText.lowercased())
            })
        } else {
            self.filtered = []
        }
        self.tableview.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.endEditing(true)
    }
}

extension AccountCredentialsMediatingController: AccountCredentialCellDelegate {
    func cellUsernameButtonTapped(credential: AccountCredential) {
        self.clipboard.string = credential.decryptedUsername
        self.showCopyToClipboardView()
    }
    
    func cellPasswordButtonTapped(credential: AccountCredential) {
        self.clipboard.string = credential.decryptedPassword
        self.showCopyToClipboardView()
    }
    
    func cellEditButtonTapped(index: Int) {
        self.delegate?.accountCredentialsEditCredential(index: index)
    }
}

extension AccountCredentialsMediatingController: CopyToClipboardView, CopyToClipboardDelegate {
    func showCopyToClipboardView() {
        if let _ = self.copyToClipboardConfirmationView {
            self.dismissClipboardView()
        }
        self.copyToClipboardConfirmationView = self.showCopyToClipboardView(view: self.view, delegate: self)
    }
    
    func dismissClipboardView() {
        guard let _ = self.copyToClipboardConfirmationView else { return }
        self.copyToClipboardConfirmationView?.removeFromSuperview()
    }
}
