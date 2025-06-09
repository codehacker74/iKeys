//
//  AccountCredentialsMediatingControllerTests.swift
//  VaultPass - Password ManagerTests
//
//  Created by Andrew Masters on 6/22/23.
//

import XCTest
@testable import VaultPass

final class AccountCredentialsMediatingControllerTests: XCTestCase {

    private var string: String!
    
    override func setUp() {
        self.string = "s"
    }

    override func tearDown() {
        self.string = nil
    }

    func testIBOutletsNonNil() {
        // given
        let factory = AccountCredentialsFactory()
        let nav = factory.makeMediatingController(accountManager: AccountCredentialsManager()) as! UINavigationController
        let sut = nav.viewControllers.first as! AccountCredentialsMediatingController
        // when
        sut.loadViewIfNeeded()
        // then
        XCTAssertNotNil(sut.tableview)
        XCTAssertNotNil(sut.searchBar)
        XCTAssertNotNil(sut.navigationItem.rightBarButtonItem)
        XCTAssertNotNil(sut.navigationItem.leftBarButtonItem)
    }
    
    func testUpdateCredentialsFillsTableView() {
        // given
        var credentials: [AccountCredential] = []
        for _ in 0..<10 {
            credentials.append(AccountCredential(title: self.string, username: self.string, password: self.string, identifiers: [self.string]))
        }
        let factory = AccountCredentialsFactory()
        let nav = factory.makeMediatingController(accountManager: AccountCredentialsManager()) as! UINavigationController
        let sut = nav.viewControllers.first as! AccountCredentialsMediatingController
        // when
        sut.loadViewIfNeeded()
        sut.updateAccountCredentials(credentials)
        // then
        XCTAssertEqual(sut.tableview.numberOfRows(inSection: 0), credentials.count)
    }
    
    func testSearchFiltersCredentials() {
        // given
        let factory = AccountCredentialsFactory()
        let nav = factory.makeMediatingController(accountManager: AccountCredentialsManager()) as! UINavigationController
        let sut = nav.viewControllers.first as! AccountCredentialsMediatingController
        let cred1 = AccountCredential(title: self.string, username: self.string, password: self.string, identifiers: [self.string])
        let cred2 = AccountCredential(title: self.string, username: self.string, password: self.string, identifiers: [self.string])
        // when
        sut.loadViewIfNeeded()
        sut.updateAccountCredentials([cred1, cred2])
        sut.searchBar.searchTextField.text = "t"
        sut.tableview.reloadData()
        // then
        XCTAssertEqual(sut.tableview.numberOfRows(inSection: 0), 0)
    }
    
    func testUsernameCopyToClipboard() {
        // given
        let factory = AccountCredentialsFactory()
        let nav = factory.makeMediatingController(accountManager: AccountCredentialsManager()) as! UINavigationController
        let sut = nav.viewControllers.first as! AccountCredentialsMediatingController
        let cred = AccountCredential(title: self.string, username: self.string, password: self.string, identifiers: [self.string])
        // when
        sut.cellUsernameButtonTapped(credential: cred)
        // then
        XCTAssertEqual(UIPasteboard.general.string, self.string)
        for view in sut.view.subviews {
            if view is CopyToClipboardConfirmationView {
                XCTAssertNotNil(view)
            }
        }
    }
    
    func testPasswordCopyToClipboard() {
        // given
        let factory = AccountCredentialsFactory()
        let nav = factory.makeMediatingController(accountManager: AccountCredentialsManager()) as! UINavigationController
        let sut = nav.viewControllers.first as! AccountCredentialsMediatingController
        let cred = AccountCredential(title: self.string, username: self.string, password: self.string, identifiers: [self.string])
        // when
        sut.cellPasswordButtonTapped(credential: cred)
        // then
        XCTAssertEqual(UIPasteboard.general.string, self.string)
        for view in sut.view.subviews {
            if view is CopyToClipboardConfirmationView {
                XCTAssertNotNil(view)
            }
        }
    }
    
    func testEditCredentialPerformanceWithForLoopFinder() {
        // given
        let factory = AccountCredentialsFactory()
        let nav = factory.makeMediatingController(accountManager: AccountCredentialsManager()) as! UINavigationController
        let sut = nav.viewControllers.first as! AccountCredentialsMediatingController
        var credentials: [AccountCredential] = []
        for index in 0..<10000 {
            credentials.append(AccountCredential(title: self.string, username: self.string, password: self.string, identifiers: [self.string + String(index)]))
        }
        // when
        sut.loadViewIfNeeded()
        sut.updateAccountCredentials(credentials)
        // then
        measure {
            sut.cellEditButtonTapped(credential: credentials.last!, index: nil)
        }
    }
    
    func testCloudPullRefreshesAndShowsSuccessMessage() {
        // given
        let factory = AccountCredentialsFactory()
        let nav = factory.makeMediatingController(accountManager: AccountCredentialsManager()) as! UINavigationController
        let sut = nav.viewControllers.first as! AccountCredentialsMediatingController
        // when
        sut.loadViewIfNeeded()
        let button = sut.navigationItem.rightBarButtonItems!.last
        UIApplication.shared.sendAction(button!.action!, to: button?.target, from: self, for: nil)
        // then
        for view in sut.view.subviews {
            if let confirmationView = view as? CopyToClipboardConfirmationView {
                XCTAssertEqual(confirmationView.messageLabel.text, "Credentials up to date")
            }
        }
    }
}
