//
//  Keychain.swift
//  Keychain_Project
//
//  Created by Talia Gonzalez on 14/07/23.
//

import UIKit
import Security

class ViewController: UIViewController {
    
    @IBOutlet weak var usernameField: UITextField?
    @IBOutlet weak var passwordField: UITextField?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func saveUser(_ sender: Any) {
        saveItemWithKeychain()
    }
    
    @IBAction func recoveryUser(_ sender: Any) {
        recoveryItemWithKeychain()
    }
    
    @IBAction func updateUser(_ sender: Any) {
        updateItemWithKeychain()
    }
    
    @IBAction func deleteUser(_ sender: Any) {
        deleteItemWithKeychain()
    }
    
    // MARK: - Methods
    /// Save items in the Keychain`
    private func saveItemWithKeychain() {
        guard let username = usernameField?.text,
              let password = (passwordField?.text)?.data(using: .utf8) else { return }
        let attributes: [String: Any] = [
            /// kSecClass Save a generic password
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: username,
            ///  kSecValueData keep safe data
            kSecValueData as String: password,
        ]
        print(attributes)
        
        if SecItemAdd(attributes as CFDictionary, nil) == noErr {
            print("The username and password have been saved successfully")
        } else {
            print("Something went wrong trying to save ther user in the keychain")
        }
    }
    
    /// Find the user and recovery the item
    private func recoveryItemWithKeychain() {
        /// Set username of the user you want to find
        let username = usernameField?.text
        /// Set query
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: username!,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnAttributes as String: true,
            kSecReturnData as String: true,
        ]
        print(query)
        var item: CFTypeRef?
        /// Check if user exists in the keychain
        if SecItemCopyMatching(query as CFDictionary, &item) == noErr {
            /// Extract result
            if let existingItem = item as? [String: Any],
               let username = existingItem[kSecAttrAccount as String] as? String,
               let passwordData = existingItem[kSecValueData as String] as? Data,
               let password = String(data: passwordData, encoding: .utf8)
            {
                print(username)
                print(password)
            }
        } else {
            print("Something went wrong. Maybe the user is misspelled or doesn't exist.")
        }
    }
    
    /// Update the item, in this case, the password
    private func updateItemWithKeychain() {
        /// Set username and new password
        guard let username = usernameField?.text,
              let newPassword = passwordField?.text?.data(using: .utf8) else {
            print("data not found")
            return
        }
        /// Set query
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: username,
        ]
        /// Set attributes for the new password
        let attributes: [String: Any] = [kSecValueData as String: newPassword]
        /// Find user and update
        if SecItemUpdate(query as CFDictionary, attributes as CFDictionary) == noErr {
            print("The password has been changed successfully")
        } else {
            print("Something went wrong trying to update the password")
        }
    }
    
    /// Delete a item
    private func deleteItemWithKeychain() {
        /// Set username
        guard let username = usernameField?.text else { return }
        /// Set query
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: username,
        ]
        /// Find user and delete
        if SecItemDelete(query as CFDictionary) == noErr {
            print("The username and password were permanently deleted.")
        } else {
            print("Something went wrong. The user was not deleted")
        }
    }
}
