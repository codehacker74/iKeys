//
//  AccountCredentialsMediatingController.swift
//  VaultPass - Password Manager
//
//  Created by Andrew Masters on 4/2/23.
//

import UIKit

protocol AccountCredentialsDelegate {
    func accountCredentialsViewDidLoad(_ displayable: AccountCredentialsDisplayable)
    func accountCredentialsViewDidAppear(_ displayable: AccountCredentialsDisplayable)
    func accountCredentialsAddButtonPressed()
    func accountCredentialsSettingsButtonPressed()
    func accountCredentialsGetCredentials(_ displayable: AccountCredentialsDisplayable)
    func accountCredentialsSaveCredentials(_ credentials: [AccountCredential])
    func accountCredentialsEditCredential(_ displayable: AccountCredentialsDisplayable, index: Int)
    func accountCredentialsShouldShowCredential() -> Bool
}

protocol AccountCredentialsDisplayable {
    func updateAccountCredentials(_ credentials: [AccountCredential])
    func displayError()
}

class AccountCredentialsMediatingController: UIViewController {
    
    @IBOutlet private(set) var tableview: UITableView!
    @IBOutlet private(set) var searchBar: UISearchBar!
    @IBOutlet var padConstraints: [NSLayoutConstraint]! {
        didSet {
            PadConstraints.setLeadingTrailingConstraints(self.padConstraints)
        }
    }

    var delegate: AccountCredentialsDelegate?

    private var credentials: [AccountCredential] = []
    private var filtered: [AccountCredential] = []
    
    private let refreshControl = UIRefreshControl()
    private let cellIdentifier = "AccountCredentialCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchBarMacSupport()
        self.registerTableView()
        self.configureNavigationBar()
        self.delegate?.accountCredentialsViewDidLoad(self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.delegate?.accountCredentialsViewDidAppear(self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.delegate?.accountCredentialsShouldShowCredential() == false {
            self.hideCells()
        }
    }
    
    private func searchBarMacSupport() {
        #if targetEnvironment(macCatalyst)
        searchBar.searchTextField.backgroundColor = .secondarySystemBackground
        #endif
    }
    
    private func registerTableView() {
        self.tableview.dataSource = self
        self.tableview.delegate = self
        self.tableview.register(UINib(nibName: cellIdentifier, bundle: nil), forCellReuseIdentifier: cellIdentifier)
        self.tableview.keyboardDismissMode = .onDrag
        self.refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        self.tableview.addSubview(refreshControl)
    }

    private func configureNavigationBar() {
        self.navigationController?.navigationBar.tintColor = .label
        self.navigationController?.navigationBar.topItem?.backButtonTitle = ""
        #if !targetEnvironment(macCatalyst)
            self.navigationItem.title = "iKeys"
        #endif
        self.navigationItem.setLeftBarButton(makeSettingsButton(), animated: false)
        self.navigationItem.setRightBarButtonItems([makeAddButton(), makeRefreshButton()], animated: false)
    }
    
    private func makeAddButton() -> UIBarButtonItem {
        let button = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(addButtonPressed))
        button.tintColor = .label
        return button
    }
    
    private func makeSettingsButton() -> UIBarButtonItem {
        let button = UIBarButtonItem(image: UIImage(systemName: "gear"), style: .plain, target: self, action: #selector(settingsButtonPressed))
        button.tintColor = .label
        return button
    }
    
    private func makeRefreshButton() -> UIBarButtonItem {
        let button = UIBarButtonItem(image: UIImage(systemName: "icloud.and.arrow.down"), style: .plain, target: self, action: #selector(refresh(_:)))
        button.tintColor = .label
        return button
    }
    
    @objc func refresh(_ sender: AnyObject) {
        self.refreshControl.beginRefreshing()
        self.delegate?.accountCredentialsGetCredentials(self)
        self.refreshControl.endRefreshing()
        self.showCopyToClipboardView(message: "Credentials up to date")
    }
    
    @objc func addButtonPressed() {
        self.emptySearchIfNecessary()
        self.delegate?.accountCredentialsAddButtonPressed()
    }
    
    @objc func settingsButtonPressed() {
        self.delegate?.accountCredentialsSettingsButtonPressed()
    }
    
    private func emptySearchIfNecessary() {
        if self.searchIsActive() {
            self.searchBar.searchTextField.text = ""
            self.searchBar.endEditing(true)
        }
    }
    
    private func searchIsActive() -> Bool {
        if let searchText = self.searchBar.text, searchText.isEmpty == false {
            return true
        }
        return false
    }
    
    private func hideCells() {
        for index in 0..<credentials.count {
            let indexPath = IndexPath(row: index, section: 0)
            guard let cell = self.tableview.cellForRow(at: indexPath) as? AccountCredentialCell else {
                continue
            }
            if cell.credentialIsShowing() {
                cell.hideCredentials()
            }
        }
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
            cell.configureCell(delegate: self, credential: credential, showCredential: self.delegate?.accountCredentialsShouldShowCredential())
        } else {
            let credential = self.credentials[indexPath.row]
            cell.configureCell(delegate: self, credential: credential, index: indexPath.row, showCredential: self.delegate?.accountCredentialsShouldShowCredential())
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? AccountCredentialCell, let credential = cell.credential else {
            return
        }
        self.cellEditButtonTapped(credential: credential, index: cell.index)
    }
    
    func cellEditButtonTapped(credential: AccountCredential, index: Int?) {
        guard let index else {
            for index in 0..<self.credentials.count {
                if self.credentials[index] == credential {
                    self.delegate?.accountCredentialsEditCredential(self, index: index)
                    return
                }
            }
            CustomAlert.ok(self, title: "Oops!", message: "Sorry we could not find that credential to edit.")
            return
        }
        self.delegate?.accountCredentialsEditCredential(self, index: index)
    }
}

extension AccountCredentialsMediatingController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        let keyboardToolBar = KeyboardToolBar(view: self.view, textFieldTag: 1, showDirectionalArrows: false)
        self.searchBar.inputAccessoryView = keyboardToolBar
    }
    
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

extension AccountCredentialsMediatingController: AccountCredentialsDisplayable {
    func updateAccountCredentials(_ credentials: [AccountCredential]) {
        self.credentials = credentials
        self.tableview.reloadData()
    }
    
    func displayError() {
        CustomAlert.ok(self, title: "Oops!", message: "We can't perform that action at this time.")
    }
}

extension AccountCredentialsMediatingController: AccountCredentialCellDelegate {
    func cellUsernameButtonTapped(credential: AccountCredential) {
        UIPasteboard.copyToClipboard(credential.decryptedUsername)
        self.showCopyToClipboardView(message: "Username copied to clipboard")
    }
    
    func cellPasswordButtonTapped(credential: AccountCredential) {
        UIPasteboard.copyToClipboard(credential.decryptedPassword)
        self.showCopyToClipboardView(message: "Password copied to clipboard")
    }
}

extension AccountCredentialsMediatingController: CopyToClipboardViewDelegate {
    func showCopyToClipboardView(message: String?) {
        self.showCopyToClipboardView(view: self.view, message: message)
    }
}

extension AccountCredentialsMediatingController {
    override var keyCommands: [UIKeyCommand]? {
        let refreshCommand = UIKeyCommand(title: "Refresh credentials", action: #selector(self.refresh(_:)), input: "r", modifierFlags: .command)
        return (super.keyCommands ?? []) + [refreshCommand]
    }
}
