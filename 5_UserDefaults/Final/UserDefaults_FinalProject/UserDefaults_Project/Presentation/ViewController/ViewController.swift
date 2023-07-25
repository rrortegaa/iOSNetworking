//
//  ViewController.swift
//  UserDefaults_Project
//
//  Created by Talia Gonzalez on 19/07/23.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var textField: UITextField?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        displaySecret()
    }
    
    // MARK: Properties
    let userDefaults = UserDefaults.standard
    
    @IBAction func saveSecret(_ sender: Any) {
       saveSecretWithUserDefaults()
    }
    
    @IBAction func printSecret(_ sender: Any) {
        getSavedSecret()
    }
    
    @IBAction func deleteSecret(_ sender: Any) {
        removeSavedSecret()
    }
    
    func displaySecret() {
        guard let text = userDefaults.string(forKey: "secret"),
              let date = userDefaults.object(forKey: "date") as? Date else { return }
        print("Mi secreto es: \(text))")
        print("Fecha: \(date)")
    }
    
    private func  saveSecretWithUserDefaults() {
        guard let text = textField?.text else { return }
        let date = Date()
        userDefaults.set(text, forKey: "secret")
        userDefaults.set(date, forKey: "date")
        userDefaults.set(textField?.text, forKey: "secret")
        print("Mi secreto guardado es: \(text)")
        print("La fecha es \(date)")
    }
    
    private func getSavedSecret() {
        guard let secret = userDefaults.string(forKey: "secret") else { return }
        print(secret)
        return
    }
    
    private func removeSavedSecret() {
        let text = userDefaults.string(forKey: "secret")
        userDefaults.removeObject(forKey: "secret")
        userDefaults.removeObject(forKey: "date")
        print("Mi secreto se ha borrado \(String(describing: text))")
    }
}

