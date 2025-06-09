//
//  CredentialConfigureCoordinator.swift
//  VaultPass - Password Manager
//
//  Created by Andrew Masters on 6/12/23.
//

import UIKit

class CredentialConfigureCoordinator: PasswordSettingsCoordinator, CredentialConfigureDelegate {
    
    let factory: CredentialConfigureFactory
    let credentialProviderDelegate: CredentialProviderDelegate?
    private let accountManager: AccountCredentialsManager
    
    private var currentCredential: AccountCredential?
    private var credentials: [AccountCredential] = []
    private let index: Int?
    private let navigation: UINavigationController
    
    init(factory: CredentialConfigureFactory, manager: AccountCredentialsManager, index: Int?, navigation: UINavigationController, credentialProviderDelegate: CredentialProviderDelegate? = nil) {
        self.factory = factory
        self.index = index
        self.navigation = navigation
        self.credentialProviderDelegate = credentialProviderDelegate
        self.accountManager = manager
        super.init(passwordManager: PasswordManager())
    }
    
    func credentialConfigureViewDidLoad(displayable: CredentialConfigureDisplayable) {
        self.credentials = self.accountManager.fetchCredentials()
        if let index {
            let credential = self.credentials[index]
            displayable.fillFields(with: credential)
        } else {
            displayable.createCredential()
        }
    }
    
    func credentialConfigureViewWillDisappear() {
        self.credentialProviderDelegate?.updateCredentials()
    }
    
    func generatePassword() -> String {
        return self.passwordManager.generatePassword()
    }
    
    func passwordTextFieldDidChange(_ displayable: CredentialConfigureDisplayable, text: String) {
        var passwordStrengthColor: UIColor = .red
        if !text.isEmpty {
            passwordStrengthColor = self.passwordManager.getPasswordStrengthColor(for: text)
        }
        displayable.changePasswordTextFieldBackground(with: passwordStrengthColor)
    }
    
    func deleteButtonPressed(vc: CredentialConfigureMediatingController?) {
        CustomAlert.destructive(self.navigation, title: "Are you sure?", message: "Deleting this credential will be permanent!", deleteBtn: "Delete", deleteAction: {_ in 
            if let index = self.index {
                self.credentials.remove(at: index)
                self.storeCredentialsAndPop(vc)
            }
        })
    }
    
    func saveCredential(_ credential: AccountCredential, vc: CredentialConfigureMediatingController?) {
        if let index = self.index {
            self.credentials[index] = credential
        } else {
            self.credentials.append(credential)
        }
        self.storeCredentialsAndPop(vc)
    }
    
    private func storeCredentialsAndPop(_ vc: CredentialConfigureMediatingController?){
        if self.accountManager.storeCredentials(self.credentials) {
            if !self.navigation.viewControllers.isEmpty {
                self.navigation.popViewController(animated: true)
            } else {
                vc?.dismiss(animated: true)
            }
        } else {
            CustomAlert.ok(self.navigation, title: "Oops!", message: "We can't save your credential at this time.")
        }
    }
    
    func isFromAutofill() -> Bool {
        return self.credentialProviderDelegate != nil
    }
}
