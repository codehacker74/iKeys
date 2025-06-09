//
//  PasswordSettingsCoordinator.swift
//  VaultPass - Password Manager
//
//  Created by Andrew Masters on 8/12/23.
//


class PasswordSettingsCoordinator: PasswordSettingsDelegate {
    let passwordManager: PasswordManager
    
    init(passwordManager: PasswordManager) {
        self.passwordManager = passwordManager
    }
    
    func setupPasswordSettings(displayable: PasswordSettingsDisplayable) {
        let lowerCaseSwitch = passwordManager.useLowerCaseLetters
        let upperCaseSwitch = passwordManager.useUpperCaseLetters
        let numbersSwtich = passwordManager.useNumbers
        let specialCharsSwitch = passwordManager.useSpecialChars
        let passwordLength = passwordManager.passwordLength
        let passwordStrength =  passwordManager.passwordStrengthColor()
        displayable.setOutlets(lowerCaseSwitch: lowerCaseSwitch, upperCaseSwitch: upperCaseSwitch, numbersSwitch: numbersSwtich, specialCharsSwitch: specialCharsSwitch, passwordLength: passwordLength)
        displayable.changePasswordStrengthColor(passwordStrength)
    }
    
    func lowerCaseLettersSwitchChanged(displayable: PasswordSettingsDisplayable) {
        self.passwordManager.toggleStringType(of: .lowerCase)
        self.passwordSettingsChanged(displayable: displayable)
    }
    
    func upperCaseLettersSwitchChanged(displayable: PasswordSettingsDisplayable) {
        self.passwordManager.toggleStringType(of: .upperCase)
        self.passwordSettingsChanged(displayable: displayable)
    }
    
    func numbersSwitchChanged(displayable: PasswordSettingsDisplayable) {
        self.passwordManager.toggleStringType(of: .numbers)
        self.passwordSettingsChanged(displayable: displayable)
    }
    
    func specialCharSwitchChanged(displayable: PasswordSettingsDisplayable) {
        self.passwordManager.toggleStringType(of: .specialChar)
        self.passwordSettingsChanged(displayable: displayable)
    }
    
    func passwordLengthChanged(length: Int, displayable: PasswordSettingsDisplayable) {
        self.passwordManager.changePasswordLength(length)
        self.passwordSettingsChanged(displayable: displayable)
    }
    
    func passwordSettingsChanged(displayable: PasswordSettingsDisplayable) {
        let passwordStrengthColor = self.passwordManager.passwordStrengthColor()
        displayable.changePasswordStrengthColor(passwordStrengthColor)
    }
}
