//
//  AccountCredentialsManagerTests.swift
//  VaultPass - Password ManagerTests
//
//  Created by Andrew Masters on 6/9/23.
//

import XCTest
@testable import VaultPass

final class AccountCredentialsManagerTests: XCTestCase {

    override func setUpWithError() throws {
    }

    override func tearDownWithError() throws {
    }
    
    func testSaveAccountCredentialsIsSuccessful() {
        // given
        let manager = AccountCredentialsManager()
        let testAccounts = [
            AccountCredential(title: "amazon", username: "username", password: "password", identifiers: ["id1"]),
            AccountCredential(title: "amazon1", username: "username1", password: "password1", identifiers: ["id2"]),
            AccountCredential(title: "amazon2", username: "username2", password: "username2", identifiers: ["id3"])
        ]
        // when
        let result = manager.storeCredentials(testAccounts)
        // then
        XCTAssertTrue(result)
    }
    
    func testFetchAccountCredentialsIsSuccessful() {
        // given
        let manager = AccountCredentialsManager()
        let testAccounts = [
            AccountCredential(title: "amazon", username: "username", password: "password", identifiers: ["id1"]),
            AccountCredential(title: "amazon1", username: "username1", password: "password1", identifiers: ["id2"]),
            AccountCredential(title: "amazon2", username: "username2", password: "username2", identifiers: ["id3"])
        ]
        // when
        let _ = manager.storeCredentials(testAccounts)
        let credentials = manager.fetchCredentials()
        // then
        XCTAssertEqual(credentials, testAccounts)
    }
    
//    func testPerformanceOfStoringCredentials() {
//        // given
//        var credentials: [AccountCredential] = []
//        let manager = AccountCredentialsManager()
//        manager.deleteAllData()
//        let numOfCreds = 10000
//        // when
//        for _ in 0..<numOfCreds {
//            credentials.append(AccountCredential(title: manager.generatePassword(), identifier: manager.generatePassword(), username: manager.generatePassword(), password: manager.generatePassword()))
//        }
//        // then
//        measure {
//            let _ = manager.storeCredentials(credentials)
//            let _ = manager.fetchCredentials()
//        }
//    }
}
