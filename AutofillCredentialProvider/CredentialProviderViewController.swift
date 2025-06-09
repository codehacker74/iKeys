//
//  CredentialProviderViewController.swift
//  AutofillCredentialProvider
//
//  Created by Andrew Masters on 6/25/23.
//

import AuthenticationServices
import UIKit

class CredentialProviderViewController: ASCredentialProviderViewController {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var searchBar: UISearchBar!
    
    private let manager = AccountCredentialsManager()
    private let autofillSettings = AutofillDataSettings()
    private var credentials: [AccountCredential] = []
    private var filtered: [AccountCredential] = []
    private var serviceIdentifier: ASCredentialServiceIdentifier? = nil
    private let cellIdentifier: String = "default"
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.isHidden = true
        BiometricUnlock.unlockWithAppleAuth(completion: { result,error in
            if error != nil || result == false {
                self.extensionContext.cancelRequest(withError: NSError(domain: ASExtensionErrorDomain, code: ASExtensionError.failed.rawValue))
            }
            self.tableView.isHidden = false
        })
    }
    
    /*
     Prepare your UI to list available credentials for the user to choose from. The items in
     'serviceIdentifiers' describe the service the user is logging in to, so your extension can
     prioritize the most relevant credentials in the list.
    */
    override func prepareCredentialList(for serviceIdentifiers: [ASCredentialServiceIdentifier]) {
        self.serviceIdentifier = serviceIdentifiers.first
        self.loadCredentialsList()
    }
    
    @IBAction func cancel(_ sender: AnyObject?) {
        self.extensionContext.cancelRequest(withError: NSError(domain: ASExtensionErrorDomain, code: ASExtensionError.userCanceled.rawValue))
    }
    
    @IBAction func add(_ sender: AnyObject?) {
        self.emptySearchIfNecessary()
        let factory = CredentialConfigureFactory()
        let coordinator = factory.makeCoordinator(manager: manager, index: nil, navigation: UINavigationController(), credentialProviderDelegate: self)
        let controller = factory.makeMediatingController(coordinator: coordinator)
        self.present(controller, animated: true)
    }
    
    private func emptySearchIfNecessary() {
        if self.searchIsActive() {
            self.searchBar.searchTextField.text = ""
            self.searchBar.endEditing(true)
        }
    }

    private func loadCredentialsList() {
        var accountCredentials = self.manager.fetchCredentials()
        if let serviceIdentifier = self.serviceIdentifier?.identifier {
            accountCredentials.sort(by: {
                if $0.findMatchFor(serviceIdentifier) {
                    return true
                }
                if $1.findMatchFor(serviceIdentifier) {
                    return false
                }
                return true
            })
        }
        self.credentials = accountCredentials
        self.tableView.reloadData()
    }
}

extension CredentialProviderViewController: CredentialProviderDelegate {
    func updateCredentials() {
        self.loadCredentialsList()
    }
}

extension CredentialProviderViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.searchIsActive() {
            return self.filtered.count
        }
        return self.credentials.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier, for: indexPath)
        var credential: AccountCredential
        if self.searchIsActive() {
            credential = self.filtered[indexPath.row]
        } else {
            credential = self.credentials[indexPath.row]
        }
        cell.textLabel!.text = credential.title
        cell.detailTextLabel!.text = credential.identifiers.first
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var credential: AccountCredential
        if self.searchIsActive() {
            credential = self.filtered[indexPath.row]
        } else {
            credential = self.credentials[indexPath.row]
        }
        let passwordCredential = credential.passwordCredential()
        self.displayIdentifierMatchIfNecessary(credential, index: indexPath.row, completion: {
            self.extensionContext.completeRequest(withSelectedCredential: passwordCredential)
        })
    }
    
    private func displayIdentifierMatchIfNecessary(_ credential: AccountCredential, index: Int, completion: @escaping () -> ()) {
        guard let identifier = serviceIdentifier?.identifier else {
            completion()
            return
        }
        if credential.findMatchFor(identifier) == false {
            if self.autofillSettings.getAutoUpdateIdentifiers() == false {
                let title = "Always remember credential use?"
                let message = "We will automatically update identifiers for easier access in the future."
                CustomAlert.decision(self, title: title, message: message, yesAction: {_ in
                    self.locateAndAddIdentifier(to: credential, index: index, identifier: identifier)
                    self.autofillSettings.setAutoUpdateIdentifiers(true)
                    completion()
                }, cancelAction: {_ in completion() })
            } else {
                self.locateAndAddIdentifier(to: credential, index: index, identifier: identifier)
                completion()
            }
        } else {
            completion()
        }
    }
    
    private func locateAndAddIdentifier(to credential: AccountCredential, index: Int, identifier: String) {
        var index = index
        if searchIsActive() {
            for i in 0..<self.credentials.count {
                if credential == self.credentials[i] {
                    index = i
                }
            }
        }
        self.credentials[index].addIdentifier(identifier)
        let _ = self.manager.storeCredentials(self.credentials)
    }
}


extension CredentialProviderViewController: UISearchBarDelegate {
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
        self.tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.endEditing(true)
    }
    
    func searchIsActive() -> Bool {
        if let searchText = self.searchBar.text, searchText.isEmpty == false {
            return true
        }
        return false
    }
}
