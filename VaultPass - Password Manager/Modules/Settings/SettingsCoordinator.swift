//
//  SettingsCoordinator.swift
//  VaultPass - Password Manager
//
//  Created by Andrew Masters on 6/14/23.
//

import UIKit

class SettingsCoordinator: PasswordSettingsCoordinator, SettingsDelegate {
    
    private let accountManager: AccountCredentialsManager
    private let navigation: UINavigationController
    private let userData: UserData = UserData()
    
    init(credentialsManager: AccountCredentialsManager, navigation: UINavigationController) {
        self.accountManager = credentialsManager
        self.navigation = navigation
        super.init(passwordManager: PasswordManager())
    }
    
    func settingsControllerViewDidLoad(_ displayable: SettingsDisplayable) {
        displayable.setSettingSwitches(userData: self.userData)
    }
    
    func toggleAutoUnlock() {
        let value = self.userData.getAutoUnlock()
        self.userData.setAutoUnlock(value.toggle())
    }
    
    func toggleAlwaysShowCredentials() {
        let value = self.userData.getAlwaysShowCredentials()
        self.userData.setAlwaysShowCredentials(value.toggle())
    }
    
    func toggleAutoUpdateIdentifiers() {
        let value = self.userData.getAutoUpdateIdentifiers()
        self.userData.setAutoUpdateIdnetifiers(value.toggle())
    }
    
    func termsAndConditionsTapped() {
        let factory = TermsAndConditionsFactory()
        let controller = factory.makeMediatingController()
        self.navigation.present(controller, animated: true)
    }

    func lockButtonPressed() {
        CustomAlert.destructive(self.navigation, title: "Lock your credentials?", message: "Are you sure you want to relock your data?", deleteBtn: "Lock", deleteAction: { _ in
            self.replaceViewWithUnlockScreen()
        })
    }
    
    func deleteAllData() {
        CustomAlert.destructive(self.navigation, title: "Are you sure you want to delete everything?", message: "This action is irreversible and will be permanent", deleteBtn: "Delete", deleteAction: { _ in
            self.accountManager.deleteAllData()
            self.passwordManager.deletePasswordData()
            self.userData.deleteData()
            KeychainService.standard.deleteKey()
            self.replaceViewWithUnlockScreen()
        })
    }
    
    private func replaceViewWithUnlockScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let unlockViewController = storyboard.instantiateViewController(identifier: "UnlockNavigation")
        self.navigation.view.window?.rootViewController = unlockViewController
        self.navigation.view.window?.makeKeyAndVisible()
    }
}
