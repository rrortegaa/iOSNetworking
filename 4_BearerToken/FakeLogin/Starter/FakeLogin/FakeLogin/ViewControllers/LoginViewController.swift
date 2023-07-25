//
//  ViewController.swift
//  FakeLogin
//
//  Created by L Daniel De San Pedro on 14/07/23.
//


/* -----
 Abrir búsqueda de archivos, clases, enums:
        CMD + SHIFT + o
----- */


import UIKit

class LoginViewController: UIViewController {
    
    
    // Outlets
    @IBOutlet private var userTextField: UITextField?
    @IBOutlet private var passwordTextField: UITextField?
    @IBOutlet private var eyeButton: UIButton?
    // Other Attributes
    private lazy var urlSession = URLSession(configuration: .default)

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    
    // Actions
    @IBAction func didPressSignInButton(sender: UIButton?) {
        // proceedToNextView()
        guard let username = userTextField? .text, let password = passwordTextField?.text else {
            // TODO: Handle error
            return
        }
        signIn(username: username, password: password)
    }
    
    @IBAction func didPressShowPassword(sender: UIButton?) {
    }
    
    func signIn(username: String, password: String) {
        var signInURLComponents = URLComponents()
        signInURLComponents.scheme = "https"
        signInURLComponents.host = "dummyjson.com"
        signInURLComponents.path = "/auth/login"
        guard let signInURL = signInURLComponents.url else {
            return
        }
        var signInRequest = URLRequest(url: signInURL)
        // Stablish HTTP method
        signInRequest.httpMethod = "POST"
        // Stablish headers
        signInRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        //
        let signInBody = SignInOutput(username: username, password: password)
        // Codificar la petición
        let jsonEncoder = JSONEncoder()
        guard let encodedData = try? jsonEncoder.encode(signInBody) else {
            return
        }
        // Establish body
        signInRequest.httpBody = encodedData
        // Completion handler is an asynchronous closure
        // data, response, error are its inputs
        urlSession.dataTask(with: signInRequest) { data, response, error in
            // _ para decirle a Xcode que no vamos a usar esta constante (al menos por ahora)
            if let _ = error {
                return
            }
            // Casting response as HTTP response
            guard let httpResponse = response as? HTTPURLResponse else {
                return
            }
            guard httpResponse.statusCode == 200 else {
                return
            }
            let jsonDecoder = JSONDecoder()
            guard let data = data, let signInResponse = try? jsonDecoder.decode(SignInResponse.self, from: data) else { return
            }
            // Switch back to main thread
            DispatchQueue.main.async {
                self.proceedToNextView(bearerToken: signInResponse.token)
            }
            
        }.resume()
    }
    
    private func proceedToNextView(bearerToken: String) {
        guard let productViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ProductsViewController") as? ProductsViewController else { return }
        // Esta asignación solo se hace con fines educativos
        // Es altamente insegura y no se recomienda su uso bajo ningún otro caso
        productViewController.token = bearerToken
        self.navigationController?.pushViewController(productViewController, animated: true)
    }

}

