//
//  CredentialConfigureMediatingControllerTests.swift
//  VaultPass - Password ManagerTests
//
//  Created by Andrew Masters on 6/26/23.
//

import XCTest
@testable import VaultPass___Password_Manager

final class CredentialConfigureMediatingControllerTests: XCTestCase {

    override func setUpWithError() throws {
    }

    override func tearDownWithError() throws {
    }

    func testIBOutletsNotNil() {
        // given
        let controller = CredentialConfigureMediatingController(delegate: nil)
        // when
        controller.loadViewIfNeeded()
        // then
        XCTAssertNotNil(controller.titleField)
        XCTAssertNotNil(controller.usernameField)
        XCTAssertNotNil(controller.passwordField)
        XCTAssertNotNil(controller.errorLabel)
        XCTAssertNotNil(controller.saveButton)
        XCTAssertNotNil(controller.deleteBtn)
        XCTAssertNotNil(controller.showPasswordBtn)
        XCTAssertNotNil(controller.copyPasswordBtn)
    }
    
    func testCredentialConfigureIsInCreateMode() {
        // given
        let factory = CredentialConfigureFactory()
        let controller = factory.makeMediatingController(manager: AccountCredentialsManager(), index: nil, navigation: UINavigationController(rootViewController: UIViewController())) as! CredentialConfigureMediatingController
        // when
        controller.loadViewIfNeeded()
        // then
        XCTAssertTrue(controller.deleteBtn.isHidden)
    }
    
    func testCredentialConfigureIsInEditMode() {
        // given
        let factory = CredentialConfigureFactory()
        let controller = factory.makeMediatingController(manager: AccountCredentialsManager(), index: nil, navigation: UINavigationController(rootViewController: UIViewController())) as! CredentialConfigureMediatingController
        // when
        controller.loadViewIfNeeded()
        // then
        XCTAssertTrue(controller.deleteBtn.isHidden)
        XCTAssertTrue(controller.titleField.text!.isEmpty)
        XCTAssertTrue(controller.usernameField.text!.isEmpty)
        XCTAssertTrue(controller.passwordField.text!.isEmpty)
    }
    
    func testEmptyCredentialCannotBeAdded() {
        // given
        let factory = CredentialConfigureFactory()
        let controller = factory.makeMediatingController(manager: AccountCredentialsManager(), index: nil, navigation: UINavigationController(rootViewController: UIViewController())) as! CredentialConfigureMediatingController
        // when
        controller.loadViewIfNeeded()
        controller.saveButton.sendActions(for: .touchUpInside)
        // then
        XCTAssertFalse(controller.errorLabel.isHidden)
    }
    
    func testOnlyTitleCredentialCannotBeAdded() {
        // given
        let factory = CredentialConfigureFactory()
        let controller = factory.makeMediatingController(manager: AccountCredentialsManager(), index: nil, navigation: UINavigationController(rootViewController: UIViewController())) as! CredentialConfigureMediatingController
        // when
        controller.loadViewIfNeeded()
        controller.titleField.text = "Title"
        controller.saveButton.sendActions(for: .touchUpInside)
        // then
        XCTAssertFalse(controller.errorLabel.isHidden)
    }
    
    func testCredentialWasAdded() {
        // given
        let manager = AccountCredentialsManager()
        let currCredNum = manager.fetchCredentials().count
        let factory = CredentialConfigureFactory()
        let controller = factory.makeMediatingController(manager: AccountCredentialsManager(), index: nil, navigation: UINavigationController(rootViewController: UIViewController())) as! CredentialConfigureMediatingController
        // when
        controller.loadViewIfNeeded()
        controller.titleField.text = "Title"
        controller.usernameField.text = "username"
        controller.passwordField.text = "password"
        controller.saveButton.sendActions(for: .touchUpInside)
        let newCredNum = manager.fetchCredentials().count
        // then
        XCTAssertEqual(currCredNum + 1, newCredNum)
    }
    
    func testPasswordGeneratorWorks() {
        // given
        let factory = CredentialConfigureFactory()
        let controller = factory.makeMediatingController(manager: AccountCredentialsManager(), index: nil, navigation: UINavigationController(rootViewController: UIViewController())) as! CredentialConfigureMediatingController
        // when
        controller.loadViewIfNeeded()
        controller.generatePasswordBtn.sendActions(for: .touchUpInside)
        // then
        XCTAssertFalse(controller.passwordField.text!.isEmpty)
    }
    
    func testPasswordIsHidden() {
        // given
        let controller = CredentialConfigureMediatingController(delegate: nil)
        let string = "password"
        // when
        controller.loadViewIfNeeded()
        controller.passwordField.text = string
        // then
        XCTAssertTrue(controller.passwordField.isSecureTextEntry)
    }
    
    func testPasswordIsShowing() {
        // given
        let controller = CredentialConfigureMediatingController(delegate: nil)
        let string = "password"
        // when
        controller.loadViewIfNeeded()
        controller.passwordField.text = string
        controller.showPasswordBtn.sendActions(for: .touchUpInside)
        // then
        XCTAssertFalse(controller.passwordField.isSecureTextEntry)
    }
    
    func testCopyPasswordToClipboard() {
        // given
        let controller = CredentialConfigureMediatingController(delegate: nil)
        let string = "password"
        // when
        controller.loadViewIfNeeded()
        controller.passwordField.text = string
        controller.copyPasswordBtn.sendActions(for: .touchUpInside)
        // then
        XCTAssertEqual(UIPasteboard.general.string, string)
        XCTAssertNotNil(controller.copyToClipboardConfirmationView)
    }
}
