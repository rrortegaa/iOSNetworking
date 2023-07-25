//
//  ViewController.swift
//  FakeLogin
//
//  Created by L Daniel De San Pedro on 14/07/23.
//

import UIKit

class LoginViewController: UIViewController {
    
    // Error Types
    private enum ErrorTypes {
        case genericError
        case connectionError
        case unauthorizedError
    }
    
    // Outlets
    @IBOutlet private var userTextField: UITextField?
    {
        didSet {
            userTextField?.text = "kminchelle"
        }
    }
    @IBOutlet private var passwordTextField: UITextField?
    {
        didSet {
            passwordTextField?.text = "0lelplR"
        }
    }
    @IBOutlet private var eyeButton: UIButton?
    
    // Other Attributes
    private lazy var urlSession = URLSession(configuration: .default)
    private var hidePassword = true

    override func viewDidLoad() {
        super.viewDidLoad()
        self.passwordTextField?.isSecureTextEntry = hidePassword
    }

    
    // Actions
    @IBAction func didPressSignInButton(sender: UIButton?) {
        guard let userName = userTextField?.text,
              let password = passwordTextField?.text else {
            self.handleError(.genericError)
            return
        }
        signIn(user: userName, password: password)
    }
    
    @IBAction func didPressShowPassword(sender: UIButton?) {
        if hidePassword {
            passwordTextField?.isSecureTextEntry = false
            eyeButton?.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        } else {
            passwordTextField?.isSecureTextEntry = true
            eyeButton?.setImage(UIImage(systemName: "eye"), for: .normal)
        }
        hidePassword.toggle()
    }
    
    private func signIn(user: String, password: String) {
        // Create URL
        var signInURLComponents = URLComponents()
        signInURLComponents.scheme = "https"
        signInURLComponents.host = "dummyjson.com"
        signInURLComponents.path = "/auth/login"
        guard let signInURL = signInURLComponents.url else {
            handleError(.genericError)
            return
        }
        var signInRequest = URLRequest(url: signInURL)
        signInRequest.httpMethod = "POST"
        signInRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let signInBody = SignInOutput(userName: user, password: password)
        let jsonEncoder = JSONEncoder()
        do {
            let encodedData = try jsonEncoder.encode(signInBody)
            signInRequest.httpBody = encodedData
            urlSession.dataTask(with: signInRequest) { [weak self] data, response, error in
                guard let self else { return }
                if let _ = error {
                    self.handleError(.genericError)
                    return
                }
                guard let httpResponse = response as? HTTPURLResponse else {
                    self.handleError(.genericError)
                    return
                }
                guard httpResponse.statusCode == 200 else {
                    if httpResponse.statusCode == 400 {
                        self.handleError(.unauthorizedError)
                    } else {
                        self.handleError(.connectionError)
                    }
                    return
                }
                let jsonDecoder = JSONDecoder()
                guard let data = data,
                      let signInResponse = try? jsonDecoder.decode(SignInResponse.self, from: data) else {
                    self.handleError(.genericError)
                    return
                }
                DispatchQueue.main.async {
                    self.proceedToNextView(with: signInResponse)
                }
            }.resume()
        } catch {
            handleError(.genericError)
        }
    }
    
    private func handleError(_ error: ErrorTypes) {
        switch error {
        case.connectionError:
            print("connection error")
        case .genericError:
            print("generic error")
        case .unauthorizedError:
            print("unauthorized error")
        }
    }
    
    private func proceedToNextView(with signInData: SignInResponse) {
        let authorizationToken = signInData.token
        guard let productViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ProductsViewController") as? ProductsViewController else { return }
        productViewController.setToken(authorizationToken)
        self.navigationController?.pushViewController(productViewController, animated: true)
    }

}

