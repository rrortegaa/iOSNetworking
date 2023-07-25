//
//  ViewController.swift
//  UserDefaults_StarterProject
//
//  Created by Talia Gonzalez on 21/07/23.
//

import UIKit

class ViewController: UIViewController {
    
    
    @IBOutlet weak var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        displaySecret()
    }

    let userDefaults = UserDefaults.standard
    
    @IBAction func saveSecret(_ sender: Any) {
        saveSecretWithUserDefaults()
    }
    
    
    @IBAction func printSecret(_ sender: Any) {
        getSavedSecret()
    }
    
    
    @IBAction func deleteSecret(_ sender: Any) {
        removeSecretWithUSerDefaults()
    }
    
    /* Save Secret*/
    private func saveSecretWithUserDefaults() {
        guard let text = textField?.text else { return }
        let date = Date()
        userDefaults.set(text, forKey: "secret")
        userDefaults.set(date, forKey: "date")
        print("My saved secret is \(text)")
        print("with date \(date)")
        
    }
    
    private func getSavedSecret() {
        guard let secret = userDefaults.string(forKey: "secret") else { return }
        print(secret)
    }
    
    private func removeSecretWithUSerDefaults() {
        guard let text = userDefaults.string(forKey: "secret") else { return }
        userDefaults.removeObject(forKey: "secret")
        userDefaults.removeObject(forKey: "date")
        print("Mi secreto borrado \(text)")
    }
    
    private func displaySecret() {
        guard let text = userDefaults.string(forKey: "secret"),
              let date = userDefaults.object(forKey: "date") as? Data else { return }
        print("Secreto que he dejado guardado \(text)")
        print("Fecha \(date)")
    
    }
    
}

