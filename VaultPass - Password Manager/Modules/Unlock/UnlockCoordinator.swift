//
//  UnlockCoordinator.swift
//  VaultPass - Password Manager
//
//  Created by Andrew Masters on 6/6/23.
//

import LocalAuthentication
import UIKit

class UnlockCoordinator: UnlockDelegate {
    
    var factory: UnlockFactory
    var navigation: UINavigationController?
    let userData = UserData()
        
    init(factory: UnlockFactory, navigation: UINavigationController?) {
        self.factory = factory
        self.navigation = navigation
    }
    
    func unlockViewDidAppear() {
        if self.userData.getAutoUnlock() {
            self.unlockWithAppleAuth()
        }
    }
    
    func unlockWithAppleAuth() {
        BiometricUnlock.unlockWithAppleAuth(completion: { result, error in
            if result && error == nil {
                self.pushAccountCredentialsController()
            }
        })
    }
    
    private func pushAccountCredentialsController() {
        let factory = AccountCredentialsFactory()
        let manager = (UIApplication.shared.delegate as! AppDelegate).credentialManager
        let passwordManager = PasswordManager()
        if self.userData.getNotFirstUnlock() == false {
            passwordManager.setPasswordSettingsToDefault()
            self.userData.setNotFirstUnlock(true)
            self.userData.setAutoUnlock(true)
        }
        let accountCredentialsViewController = factory.makeMediatingController(accountManager: manager)
        self.navigation?.view.window?.rootViewController = accountCredentialsViewController
        self.navigation?.view.window?.makeKeyAndVisible()
    }
    
    func termsAndConditionsButtonAction() {
        let factory = TermsAndConditionsFactory()
        let controller = factory.makeMediatingController()
        self.navigation?.present(controller, animated: true)
    }
}
