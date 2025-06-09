//
//  PasswordManagerTests.swift
//  VaultPass - Password ManagerTests
//
//  Created by Andrew Masters on 5/26/25.
//

import XCTest
@testable import VaultPass

final class PasswordManagerTests: XCTestCase {

    override func setUpWithError() throws {
    }

    override func tearDownWithError() throws {
    }
    
    func testPasswordStrengthIsNone() {
        // given
        let manager = PasswordManager()
        manager.setPasswordSettingsToDefault()
        // when
        manager.toggleStringType(of: .lowerCase)
        manager.toggleStringType(of: .upperCase)
        manager.toggleStringType(of: .numbers)
        manager.toggleStringType(of: .specialChar)
        let passwordStrength = manager.passwordStrength()
        // then
        XCTAssertEqual(.none, passwordStrength)
        XCTAssertEqual(.black, manager.passwordStrengthColor(for: passwordStrength))
    }
    
    func testPasswordStrengthIsBad() {
        // given
        let manager = PasswordManager()
        manager.setPasswordSettingsToDefault()
        // when
        manager.toggleStringType(of: .lowerCase)
        manager.toggleStringType(of: .upperCase)
        manager.toggleStringType(of: .specialChar)
        manager.changePasswordLength(8)
        let passwordStrength = manager.passwordStrength()
        // then
        XCTAssertEqual(.bad, passwordStrength)
        XCTAssertEqual(.red, manager.passwordStrengthColor(for: passwordStrength))
    }
    
    func testPasswordStrengthIsOkay() {
        // given
        let manager = PasswordManager()
        manager.setPasswordSettingsToDefault()
        // when
        manager.toggleStringType(of: .lowerCase)
        manager.changePasswordLength(10)
        let passwordStrength = manager.passwordStrength()
        // then
        XCTAssertEqual(.okay, passwordStrength)
        XCTAssertEqual(.orange, manager.passwordStrengthColor(for: passwordStrength))
    }
    
    func testPasswordStrengthIsGood() {
        // given
        let manager = PasswordManager()
        manager.setPasswordSettingsToDefault()
        // when
        manager.toggleStringType(of: .upperCase)
        let passwordStrength = manager.passwordStrength()
        // then
        XCTAssertEqual(.good, passwordStrength)
        XCTAssertEqual(.yellow, manager.passwordStrengthColor(for: passwordStrength))
    }
    
    func testPasswordStrengthIsBest() {
        // given
        let manager = PasswordManager()
        manager.setPasswordSettingsToDefault()
        // when
        manager.toggleStringType(of: .specialChar)
        manager.changePasswordLength(18)
        let passwordStrength = manager.passwordStrength()
        // then
        XCTAssertEqual(.best, passwordStrength)
        XCTAssertEqual(.green, manager.passwordStrengthColor(for: passwordStrength))
    }
}
