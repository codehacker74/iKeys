//
//  SettingsCoordinator.swift
//  VaultPass - Password Manager
//
//  Created by Andrew Masters on 6/14/23.
//

import UIKit

class SettingsCoordinator: PasswordSettingsCoordinator, SettingsDelegate {
    
    private let navigation: UINavigationController
    private let unlockData: UnlockData = UnlockData()
    
    init(credentialsManager: AccountCredentialsManager, navigation: UINavigationController) {
        self.navigation = navigation
        super.init(credentialsManager: credentialsManager)
    }
    
    func settingsControllerViewDidLoad(_ displayable: SettingsDisplayable) {
        displayable.setAutoUnlockSwitch(self.unlockData.getAutoUnlock())
    }
    
    func toggleAutoUnlock() {
        let value = self.unlockData.getAutoUnlock()
        self.unlockData.setAutoUnlock(value.toggle())
    }
    
    func termsAndConditionsTapped() {
        let factory = TermsAndConditionsFactory()
        let controller = factory.makeMediatingController()
        self.navigation.present(controller, animated: true)
    }

    func lockButtonPressed() {
        CustomAlert.destructive(self.navigation, title: "Lock your credentials?", message: "Are you sure you want to relock your data?", deleteBtn: "Lock", deleteAction: { _ in
            self.unlockData.setAutoUnlock(false)
            self.replaceViewWithUnlockScreen()
        })
    }
    
    func deleteAllData() {
        CustomAlert.destructive(self.navigation, title: "Are you sure you want to delete everything?", message: "This action is irreversible and will be permanent", deleteBtn: "Delete", deleteAction: { _ in
            self.credentialsManager.deleteAllData()
            self.unlockData.deleteData()
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
