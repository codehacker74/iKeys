//
//  PasswordSettingsViewTests.swift
//  VaultPass - Password ManagerTests
//
//  Created by Andrew Masters on 8/13/23.
//

import XCTest
@testable import VaultPass

final class PasswordSettingsViewTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testIBOutletsAreNotNil() {
        // given
        let view: PasswordSettingsView = PasswordSettingsView.initFromNib()
        // when
        view.setup(delegate: nil)
        // then
        XCTAssertNotNil(view.lowerCaseSwitch)
        XCTAssertNotNil(view.upperCaseSwitch)
        XCTAssertNotNil(view.numbersSwitch)
        XCTAssertNotNil(view.specialCharsSwitch)
        XCTAssertNotNil(view.passwordLengthLabel)
        XCTAssertNotNil(view.passwordLengthSlider)
        XCTAssertNotNil(view.passwordStrengthColor)
    }
    
    func testPasswordSettingsSetFromManager() {
        // given
        let manager = PasswordManager()
        let delegate = PasswordSettingsCoordinator(passwordManager: manager)
        let view: PasswordSettingsView = PasswordSettingsView.initFromNib()
        // when
        view.setup(delegate: delegate)
        // then
        XCTAssertEqual(view.lowerCaseSwitch.isOn, manager.useLowerCaseLetters)
        XCTAssertEqual(view.upperCaseSwitch.isOn, manager.useUpperCaseLetters)
        XCTAssertEqual(view.numbersSwitch.isOn, manager.useNumbers)
        XCTAssertEqual(view.specialCharsSwitch.isOn, manager.useSpecialChars)
        XCTAssertEqual(view.passwordLengthLabel.text, String(manager.passwordLength))
        XCTAssertEqual(Int(view.passwordLengthSlider.value), manager.passwordLength)
    }
    
    func testLowerCaseSwitchIsReflectedInManager() {
        // given
        let manager = PasswordManager()
        let currentLowerCase = manager.useLowerCaseLetters
        let delegate = PasswordSettingsCoordinator(passwordManager: manager)
        let view: PasswordSettingsView = PasswordSettingsView.initFromNib()
        // when
        view.setup(delegate: delegate)
        view.lowerCaseSwitch.sendActions(for: .touchUpInside)
        // then
        XCTAssertNotEqual(currentLowerCase, manager.useLowerCaseLetters)
    }
    
    func testUpperCaseSwitchIsReflectedInManager() {
        // given
        let manager = PasswordManager()
        let currentUpperCase = manager.useUpperCaseLetters
        let delegate = PasswordSettingsCoordinator(passwordManager: manager)
        let view: PasswordSettingsView = PasswordSettingsView.initFromNib()
        // when
        view.setup(delegate: delegate)
        view.upperCaseSwitch.sendActions(for: .touchUpInside)
        // then
        XCTAssertNotEqual(currentUpperCase, manager.useUpperCaseLetters)
    }
    
    func testNumbersSwitchIsReflectedInManager() {
        // given
        let manager = PasswordManager()
        let currentNumbers = manager.useNumbers
        let delegate = PasswordSettingsCoordinator(passwordManager: manager)
        let view: PasswordSettingsView = PasswordSettingsView.initFromNib()
        // when
        view.setup(delegate: delegate)
        view.numbersSwitch.sendActions(for: .touchUpInside)
        // then
        XCTAssertNotEqual(currentNumbers, manager.useNumbers)
    }
    
    func testSpecialCaseSwitchIsReflectedInManager() {
        // given
        let manager = PasswordManager()
        let currentSpecialChars = manager.useSpecialChars
        let delegate = PasswordSettingsCoordinator(passwordManager: manager)
        let view: PasswordSettingsView = PasswordSettingsView.initFromNib()
        // when
        view.setup(delegate: delegate)
        view.specialCharsSwitch.sendActions(for: .touchUpInside)
        // then
        XCTAssertNotEqual(currentSpecialChars, manager.useSpecialChars)
    }
    
    func testPasswordLengthSliderChangeDoesChangeLengthInManager() {
        // given
        let manager = PasswordManager()
        manager.setPasswordSettingsToDefault()
        let currentLength = manager.passwordLength
        let delegate = PasswordSettingsCoordinator(passwordManager: manager)
        let view: PasswordSettingsView = PasswordSettingsView.initFromNib()
        // when
        view.setup(delegate: delegate)
        view.passwordLengthSlider.setValue(16, animated: false)
        view.passwordLengthSlider.sendActions(for: .valueChanged)
        // then
        XCTAssertNotEqual(currentLength, manager.passwordLength)
    }
    
    func testPasswordLengthSliderChangesLabel() {
        // given
        let manager = PasswordManager()
        manager.setPasswordSettingsToDefault()
        let delegate = PasswordSettingsCoordinator(passwordManager: manager)
        let view: PasswordSettingsView = PasswordSettingsView.initFromNib()
        // when
        view.setup(delegate: delegate)
        view.passwordLengthSlider.setValue(16, animated: false)
        view.passwordLengthSlider.sendActions(for: .valueChanged)
        // then
        XCTAssertEqual(Int(view.passwordLengthSlider.value), Int(view.passwordLengthLabel.text!))
    }
    
    func testPasswordStengthColorChanges() {
        // given
        let manager = PasswordManager()
        manager.setPasswordSettingsToDefault()
        let currentColor = manager.passwordStrengthColor()
        let delegate = PasswordSettingsCoordinator(passwordManager: manager)
        let view: PasswordSettingsView = PasswordSettingsView.initFromNib()
        // when
        view.setup(delegate: delegate)
        view.lowerCaseSwitch.sendActions(for: .touchUpInside)
        view.upperCaseSwitch.sendActions(for: .touchUpInside)
        view.numbersSwitch.sendActions(for: .touchUpInside)
        view.passwordLengthSlider.setValue(8, animated: false)
        view.passwordLengthSlider.sendActions(for: .valueChanged)
        // then
        XCTAssertNotEqual(currentColor, manager.passwordStrengthColor())
        XCTAssertEqual(view.passwordStrengthColor.backgroundColor!, manager.passwordStrengthColor())
    }

}
