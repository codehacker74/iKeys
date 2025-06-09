//
//  PasswordManager.swift
//  VaultPass - Password Manager
//
//  Created by Andrew Masters on 5/26/25.
//

import UIKit
import CoreData
import AuthenticationServices

enum PasswordStringType {
    case lowerCase
    case upperCase
    case numbers
    case specialChar
}

enum PasswordStrength {
    case none
    case bad
    case okay
    case good
    case best
}

struct PasswordManager {
    private let lowerCaseKey = "lower_case_key"
    private let upperCaseKey = "upper_case_key"
    private let numbersKey = "numbers_key"
    private let specialCharKey = "special_char_key"
    private let passwordLengthKey = "password_length_key"
    private let userDefaults = UserDefaults(suiteName: "group.vaultpass.masters")
    
    private let lowerCaseLetters: String = "abcdefghijklmnopqrstuvwxyz"
    private let upperCaseLetters: String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    private let allNumbers: String = "1234567890"
    private let allSpecialChars: String = "!@#$*"
    
    var useLowerCaseLetters: Bool {
        return (self.userDefaults?.bool(forKey: self.lowerCaseKey) ?? true)
    }
    var useUpperCaseLetters: Bool {
        return (self.userDefaults?.bool(forKey: self.upperCaseKey) ?? true)
    }
    var useNumbers: Bool {
        return (self.userDefaults?.bool(forKey: self.numbersKey) ?? true)
    }
    var useSpecialChars: Bool {
        return (self.userDefaults?.bool(forKey: self.specialCharKey) ?? true)
    }
    var passwordLength: Int {
        return (self.userDefaults?.integer(forKey: self.passwordLengthKey) ?? 12)
    }
    
    private func lowerCase() -> String {
        return self.useLowerCaseLetters ? self.lowerCaseLetters : ""
    }
    
    private func upperCase() -> String {
        return self.useUpperCaseLetters ? self.upperCaseLetters : ""
    }

    private func numbers() -> String {
        return self.useNumbers ? self.allNumbers : ""
    }
    
    private func specialChars() -> String {
        return self.useSpecialChars ? self.allSpecialChars : ""
    }
    
    func setPasswordSettingsToDefault() {
        self.userDefaults?.set(true, forKey: self.specialCharKey)
        self.userDefaults?.set(true, forKey: self.numbersKey)
        self.userDefaults?.set(true, forKey: self.upperCaseKey)
        self.userDefaults?.set(true, forKey: self.lowerCaseKey)
        self.userDefaults?.set(12, forKey: self.passwordLengthKey)
    }
    
    func toggleStringType(of type: PasswordStringType) {
        switch type {
        case .lowerCase:
            changePasswordStringType(for: self.useLowerCaseLetters, withKey: self.lowerCaseKey)
        case .upperCase:
            changePasswordStringType(for: self.useUpperCaseLetters, withKey: self.upperCaseKey)
        case .numbers:
            changePasswordStringType(for: self.useNumbers, withKey: self.numbersKey)
        case .specialChar:
            changePasswordStringType(for: self.useSpecialChars, withKey: self.specialCharKey)
        }
    }
    
    func changePasswordLength(_ length: Int){
        self.userDefaults?.set(length, forKey: self.passwordLengthKey)
    }
    
    private func changePasswordStringType(for currentValue: Bool, withKey key: String) {
        let newValue = currentValue
        self.userDefaults?.set(newValue.toggle(), forKey: key)
    }
    
    func generatePassword() -> String {
        let length = passwordLength
        let passwordCharacters = lowerCase() + upperCase() + numbers() + specialChars()
        let newPassword = String((0..<length).compactMap{ _ in passwordCharacters.randomElement() })
        return newPassword
    }
    
    private func numberOfPasswordStringTypesEnabled() -> Int {
        var stringTypesEnabled: Int = 0
        if self.useLowerCaseLetters {
            stringTypesEnabled = stringTypesEnabled + 1
        }
        if self.useUpperCaseLetters {
            stringTypesEnabled = stringTypesEnabled + 1
        }
        if self.useNumbers {
            stringTypesEnabled = stringTypesEnabled + 1
        }
        if self.useSpecialChars {
            stringTypesEnabled = stringTypesEnabled + 1
        }
        return stringTypesEnabled
    }
    
    func passwordStrength(stringTypes: Int = 0, passwordLength: Int = 0) -> PasswordStrength {
        let stringTypesEnabled = stringTypes == 0 ? self.numberOfPasswordStringTypesEnabled() : stringTypes
        let passwordLength = passwordLength == 0 ? self.passwordLength : passwordLength
        var type: PasswordStrength = .none
        if passwordLength <= 10 {
            if stringTypesEnabled == 0 {
                type = .none
            } else if stringTypesEnabled < 3 {
                type = .bad
            } else if stringTypesEnabled >= 3 {
                type = .okay
            }
        } else if passwordLength > 10, passwordLength < 15 {
            if stringTypesEnabled == 0 {
                type = .none
            } else if stringTypesEnabled == 1 {
                type = .bad
            } else if stringTypesEnabled == 2 {
                type = .okay
            } else if stringTypesEnabled > 2 {
                type = .good
            }
        } else {
            if stringTypesEnabled == 0 {
                type = .none
            } else if stringTypesEnabled == 1 {
                type = .bad
            } else if stringTypesEnabled == 2 {
                type = .good
            } else if stringTypesEnabled >= 3 {
                type = .best
            }
        }
        return type
    }
    
    func passwordStrengthColor(for passwordStrength: PasswordStrength) -> UIColor {
        switch passwordStrength {
        case .none:
            return .black
        case .bad:
            return .red
        case .okay:
            return .orange
        case .good:
            return .yellow
        case .best:
            return .green
        }
    }
    
    func passwordStrengthColor() -> UIColor {
        let passwordStrength = self.passwordStrength()
        switch passwordStrength {
        case .none:
            return .black
        case .bad:
            return .red
        case .okay:
            return .orange
        case .good:
            return .yellow
        case .best:
            return .green
        }
    }
    
    func getPasswordStrengthColor(for text: String) -> UIColor {
        var stringTypes = 0
        var noLowerCaseChars: Bool = true
        var noUpperCaseChars: Bool = true
        var noSpecialChars: Bool = true
        var noNumbers: Bool = true
        for character in text {
            if noLowerCaseChars && self.lowerCaseLetters.contains(character) {
                noLowerCaseChars = false
                stringTypes += 1
                continue
            }
            if noUpperCaseChars && self.upperCaseLetters.contains(character) {
                noUpperCaseChars = false
                stringTypes += 1
                continue
            }
            if noSpecialChars && self.allSpecialChars.contains(character) {
                noSpecialChars = false
                stringTypes += 1
                continue
            }
            if noNumbers && self.allNumbers.contains(character) {
                noNumbers = false
                stringTypes += 1
                continue
            }
        }
        let passwordStrength = self.passwordStrength(stringTypes: stringTypes, passwordLength: text.count)
        return self.passwordStrengthColor(for: passwordStrength)
    }
    
    func deletePasswordData() {
        self.userDefaults?.removeObject(forKey: self.specialCharKey)
        self.userDefaults?.removeObject(forKey: self.numbersKey)
        self.userDefaults?.removeObject(forKey: self.upperCaseKey)
        self.userDefaults?.removeObject(forKey: self.lowerCaseKey)
        self.userDefaults?.removeObject(forKey: self.passwordLengthKey)
    }
}


