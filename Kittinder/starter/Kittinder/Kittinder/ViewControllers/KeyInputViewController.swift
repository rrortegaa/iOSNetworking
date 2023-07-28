//
//  ViewController.swift
//  Kittinder
//
//  Created by L Daniel De San Pedro on 24/07/23.
//

import UIKit
import Security

class KeyInputViewController: UIViewController {
    
    enum InputError: Error {
        case storeKeyError
    }
    
    @IBOutlet weak var apiKeyTextField: UITextField?
    @IBOutlet weak var titleLabel: UILabel?
    var currentAPIKey: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        retrieveKey()
        setUpTapGestureRecognizer()
    }
    
    func setUpTapGestureRecognizer() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.removeKey(_:)))
        tapGestureRecognizer.numberOfTapsRequired = 3
        titleLabel?.addGestureRecognizer(tapGestureRecognizer)
        titleLabel?.isUserInteractionEnabled = true
    }
    
    @IBAction func didTapOnContinue(_ sender: UIButton) {
        guard let apiKey = apiKeyTextField?.text,
              apiKey != "" else { return }
        if apiKey == currentAPIKey {
            goToNextView()
            return
        }
        do {
            try storeKey(apiKey)
            goToNextView()
        } catch {
            // TODO: Display error message
            print("Error saving the key")
        }
        
    }
    
    func storeKey(_ apiKey: String) throws {
        let key = apiKey.data(using: .utf8)!
        let tag = "com.kodemia.kittinder".data(using: .utf8)!
        let attributes: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: tag,
            kSecValueData as String: key
        ]
        
        let status = SecItemAdd(attributes as CFDictionary, nil)
        guard status == errSecSuccess else { throw InputError.storeKeyError }
        currentAPIKey = apiKey
        print("Key saved")
    }
    
    func retrieveKey() {
        let tag = "com.kodemia.kittinder".data(using: .utf8)!
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: tag,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked
        ]
        var item: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess,
              let data = item as? Data,
              let key = String(data: data, encoding: .utf8) else {
            print("Failed to obtain the key")
            return
        }
        self.currentAPIKey = key
        self.apiKeyTextField?.text = key
    }
    
    func goToNextView() {
        let nextViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "MainNavigationController")
        nextViewController.modalPresentationStyle = .fullScreen
        present(nextViewController, animated: true)
    }
    
    @objc func removeKey(_ sender: Any) {
        let tag = "com.kodemia.kittinder".data(using: .utf8)!
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: tag
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            print("Item not found")
            return
        }
        print("Key deleted")
    }

}

