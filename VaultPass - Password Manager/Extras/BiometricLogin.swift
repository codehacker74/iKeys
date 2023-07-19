//
//  BiometricLogin.swift
//  VaultPass - Password Manager
//
//  Created by Andrew Masters on 7/18/23.
//

import LocalAuthentication

public final class BiometricLogin {
    public static func loginWithAppleAuth(completion: @escaping (Bool,Error?) -> (Void)) {
        let context = LAContext()
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else {
            print(error?.localizedDescription ?? "Can't evaluate policy")
            return
        }
        Task {
            do {
                try await context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "Log in to manager your passwords")
                print("Succcessful authentication")
                DispatchQueue.main.async {
                    completion(true, nil)
                }
            } catch let error {
                completion(false, error)
                print(error.localizedDescription)
            }
        }
    }
}
