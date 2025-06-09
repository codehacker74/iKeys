//
//  AccountCredentialsManager.swift
//  VaultPass - Password Manager
//
//  Created by Andrew Masters on 6/7/23.
//

import UIKit
import CoreData
import AuthenticationServices

struct AccountCredentialsManager {
    private let context: NSManagedObjectContext
    private let converter: Converter = Converter()
    private let modelName = "Model"
    
    init(iCloudEnabled: Bool = false) {
        self.context = PersistentContainer(iCloud: iCloudEnabled).viewContext
    }
    
    /**
     1. Combine internal arrays of `AccountCredential`s using square brackets `{}` -> array of strings -> N time
     2. Convert array of strings into Data suing Convertor -> N time
     3. Encrypt data using encryptor -> N time
     4. Store data in CoreData (convertor to Binary Data if needed?) -> Constant time
     5. Dencrypt data using encryptor
     6. Convert Data into array of strings
     7. Deconstruct each string into an `AccountCredential`
     Create tests to ensure it works as intended
     */
    
    func fetchCredentials() -> [AccountCredential] {
        guard let fetchedData = try? context.fetch(AccountCredential.fetchRequest()),
              let encryptedData = fetchedData.last?.credentials,
              let decryptedData = Encryptor.standard.decrypt(data: encryptedData) else {
            return []
        }
        return self.converter.dataToCredential(data: decryptedData)
    }
    
    func storeCredentials(_ credentials: [AccountCredential]) -> Bool {
        self.deleteStore()
        let sortedCredentials = self.sortCredentials(credentials)
        guard let data = self.converter.credentialsToData(credentials: sortedCredentials),
              let encryptedData = Encryptor.standard.encrypt(data: data)  else {
            return false
        }
        guard let encryptedCredentials = NSEntityDescription.insertNewObject(forEntityName: "EncryptedCredentials", into: context) as? EncryptedCredentials else {
            return false
        }
        encryptedCredentials.credentials = encryptedData
        encryptedCredentials.lastUpdated = Date()
        do {
            try context.save()
            print("Credentials were saved")
            return true
        } catch {
            print("Credentials could not save")
            return false
        }
    }
    
    func deleteAllData() {
        self.deleteStore()
        try? context.save()
    }
    
    private func deleteStore() {
        guard let data = try? context.fetch(AccountCredential.fetchRequest()) else {
            return
        }
        for object in data {
            context.delete(object)
        }
    }
    
    private func sortCredentials(_ credentials: [AccountCredential]) -> [AccountCredential] {
        return credentials.sorted(by: { $0.title.lowercased() < $1.title.lowercased() })
    }
}

