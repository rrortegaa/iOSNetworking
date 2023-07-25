//
//  ProductsViewController.swift
//  FakeLogin
//
//  Created by L Daniel De San Pedro on 14/07/23.
//

import UIKit

class ProductsViewController: UIViewController {
    // Outlets
    @IBOutlet private var contentTableView: UITableView?
    
    var token: String?
    var products: [Product] = []
    
    // Attributes
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

    
    private func fetchProducts() {
        // Es muy importante desempaquetar el token para usarlo en el setValue más abajo
        guard let token = token else { return }
        // URL Components
        var productURLComponents = URLComponents()
        productURLComponents.scheme = "https"
        productURLComponents.host = "dummyjson.com"
        productURLComponents.path = "/auth/products"
        guard let productsURL = productURLComponents.url else { return }
        
        var productsRequest = URLRequest(url: productsURL)
        productsRequest.httpMethod = "GET"
        productsRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        productsRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        urlSession.dataTask(with: productsRequest) {data, response, error in
            if let _ = error {
                return
            }
            
            guard let response = response as? HTTPURLResponse else { return }
            guard response.statusCode == 200 else  { return }
            let jsonDecoder = JSONDecoder()
            guard let data = data,
                  let productsResponse = try? jsonDecoder.decode(ProductsResponse.self, from: data) else { return }
            DispatchQueue.main.async {
                self.products = productsResponse.products
                // Reload para que actualice y cargue el arreglo products ya lleno
                self.contentTableView?.reloadData()
            }
            
        }.resume()
    }

}

extension ProductsViewController: UITableViewDelegate {
    
}

extension ProductsViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ProductTableViewCell") as? ProductTableViewCell else { return UITableViewCell() }
        let product = products[indexPath.row]
        cell.set(product: product)
        return cell
    }
    
}
