//
//  Keychain.swift
//  Keychain_Project
//
//  Created by Talia Gonzalez on 14/07/23.
//

import UIKit
import Security

class ViewController: UIViewController {
    
    // IBOutlets
    
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
    
    /* Vamos a guardar una contraseña genérica en un diccionario */
    private func saveItemWithKeychain() {
        guard let username = usernameField?.text,
              let password = passwordField?.text?.data(using: .utf8) else { return }
        let attributes: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: username,
            kSecValueData as String: password
        ]
        print(attributes)
        
        if SecItemAdd(attributes as CFDictionary, nil) == noErr {
            print("Username and password have been saved successfully")
        } else {
            print("Something went wrong trying to store data")
        }
    }
    
    /* Encontrar usuario y contraseña */
    private func recoveryItemWithKeychain() {
        let username = usernameField?.text
        let getquery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: username!,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnAttributes as String: true,
            kSecReturnData as String: true
        ]
        print(getquery)
        
        /* generic type of CoreFoundation */
        var item: CFTypeRef?
        if SecItemCopyMatching(getquery as CFDictionary, &item) == noErr {
            // get Item
            if let existingItem = item as? [String: Any],
               let username = existingItem[kSecAttrAccount as String] as? String,
               let passwordData = existingItem[kSecValueData as String] as? Data,
               let password = String(data: passwordData, encoding: .utf8) {
                print(username)
                print(password)
            } else {
                print("Something went wrong, maybe the user is misspelled or doesn't exist")
            }
        }
    }
    
    /* Update item, in this case, password item */
    private func updateItemWithKeychain() {
        guard let username = usernameField?.text,
              let newPassword = passwordField?.text?.data(using: .utf8) else {
            print("Username not found")
            return
        }
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: username
        ]
        let attribute: [String: Any] = [kSecValueData as String: newPassword]
        // Password update
        if SecItemUpdate(query as CFDictionary, attribute as CFDictionary) == noErr {
            print("Password has been changed")
        } else {
            print("Something went wrong trying to update the password")
        }
    }
    
    /* Delete item */
    private func deleteItemWithKeychain() {
        /*
         1. ¿Qué item quiero borrar? en este caso, identificamos el usuario
         2. Hacer la consulta, declarar una CONST tipo diccionario donde se incluye el kSecClassGenericPassword, kSecAttrAccount
         3. Borrar item implementando el método "SecItemDelete"
        */
        
        guard let username = usernameField?.text else { return }
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: username,
        ]
        if SecItemDelete(query as CFDictionary) == noErr {
            print("Username and password were permanently deleted")
        } else {
            print("Something went wrong, user was not deleted")
        }
     }
}
