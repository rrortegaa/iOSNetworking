//
//  ProductsViewController.swift
//  FakeLogin
//
//  Created by L Daniel De San Pedro on 14/07/23.
//

import UIKit

class ProductsViewController: UIViewController {
    private enum ErrorTypes {
        case genericError
        case connectionError
        case unauthorizedError
    }
    // Outlets
    @IBOutlet private var contentTableView: UITableView?
    
    // Attributes
    private var authorizationToken: String?
    private var products: [Product]?
    private lazy var urlSession = URLSession(configuration: .default)

    override func viewDidLoad() {
        super.viewDidLoad()
        self.contentTableView?.delegate = self
        self.contentTableView?.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchProducts()
    }
    
    func setToken(_ token: String) {
        self.authorizationToken = token
    }
    
    private func fetchProducts() {
        // Create URL
        guard let authorizationToken = authorizationToken else { return }
        var productsURLComponents = URLComponents()
        productsURLComponents.scheme = "https"
        productsURLComponents.host = "dummyjson.com"
        productsURLComponents.path = "/auth/products"
        guard let productsURL = productsURLComponents.url else {
            handleError(.genericError)
            return
        }
        var productsRequest = URLRequest(url: productsURL)
        productsRequest.httpMethod = "GET"
        productsRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        productsRequest.setValue("Bearer \(authorizationToken)", forHTTPHeaderField: "Authorization")
        urlSession.dataTask(with: productsRequest) { [weak self] data, response, error in
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
                  let productsResponse = try? jsonDecoder.decode(ProductsResponse.self, from: data) else {
                self.handleError(.genericError)
                return
            }
            DispatchQueue.main.async {
                self.products = productsResponse.products
                self.contentTableView?.reloadData()
            }
        }.resume()
        
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
    
}

extension ProductsViewController: UITableViewDelegate {
    
}

extension ProductsViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ProductTableViewCell") as? ProductTableViewCell else { return UITableViewCell() }
        if let product = products?[indexPath.row] {
            cell.set(product: product)
        }
        return cell
    }
    
}
