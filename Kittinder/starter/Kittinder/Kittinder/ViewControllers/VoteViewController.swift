//
//  VoteViewController.swift
//  Kittinder
//
//  Created by L Daniel De San Pedro on 24/07/23.
//

import UIKit

class VoteViewController: UIViewController {
    
    enum VoteType: Int {
        case cute  = 1
        case notCute = -1
    }
    
    enum VoteState {
        case notSelected
        case cuteSelected
        case notCuteSelected
    }
    
    enum LoadingState {
        case loading
        case noLoading
    }
    
    @IBOutlet weak var catImageView: UIImageView?
    @IBOutlet weak var breedNameLabel: UILabel?
    @IBOutlet weak var originLabel: UILabel?
    @IBOutlet weak var temperamentLabel: UILabel?
    @IBOutlet weak var wikipediaLinkLabel: UILabel?
    @IBOutlet weak var descriptionLabel: UILabel?
    @IBOutlet weak var cuteButton: UIButton?
    @IBOutlet weak var notCuteButton: UIButton?
    
    var loaderView: UIView?
    
    var apiKey: String?
    var currentCatID: String?
    var currentVoteState: VoteState = .notSelected
    var loadingState: LoadingState = .noLoading
    
    let apiBaseURL: String = "api.thecatapi.com"
    let urlSession = URLSession.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        retrieveKey()
        displayLoader()
        obtainCatInfo()
    }
    
    func setUpUI() {
        cuteButton?.backgroundColor = .systemGreen
        notCuteButton?.backgroundColor = .systemRed
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
        self.apiKey = key
    }
    
    func obtainCatInfo() {
        guard let key = self.apiKey else { return }
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = apiBaseURL
        urlComponents.path = "/v1/images/search"
        let queryItems: [URLQueryItem] = [
            URLQueryItem(name: "has_breeds", value: "1"),
            URLQueryItem(name: "api_key", value: key)
        ]
        urlComponents.queryItems = queryItems
        guard let url = urlComponents.url else { return }
        var urlRequest = URLRequest(url: url)
        urlRequest.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        urlSession.dataTask(with: urlRequest) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let _ = error {
                self.displayErrorView()
                return
            }
            
            guard let response = response as? HTTPURLResponse else {
                self.displayErrorView()
                return
            }
            
            guard response.statusCode == 200 || response.statusCode == 201 else {
                self.displayErrorView()
                return
            }
            
            let jsonDecoder = JSONDecoder()
            
            guard let data = data,
                  let catInfo = try? jsonDecoder.decode([CatInfoModel].self, from: data) else {
                self.displayErrorView()
                return
            }
            
            DispatchQueue.main.async {
                self.updateCatInfo(with: catInfo.first!)
            }
            
            self.obtainCatImage(from: catInfo.first!.url)
            
        }.resume()
    }
    
    func obtainCatImage(from url: String) {
        guard let url = URL(string: url) else {
            return
        }
        
        urlSession.dataTask(with: url) { [weak self] data, _, _ in
            guard let self = self,
                  let data = data,
                  let image = UIImage(data: data) else {
                self?.displayErrorView()
                return
            }
            DispatchQueue.main.async {
                self.hideLoader()
                self.catImageView?.image = image
            }
        }.resume()
    }
    
    func updateCatInfo(with catInfo: CatInfoModel) {
        if let breedName = catInfo.breeds?.first?.name {
            breedNameLabel?.text = breedName
        }
        if let origin = catInfo.breeds?.first?.origin {
            originLabel?.text = origin
        }
        if let temperament = catInfo.breeds?.first?.temperament {
            temperamentLabel?.text = temperament
        }
        if let wikipediaLink = catInfo.breeds?.first?.wikipediaURL {
            wikipediaLinkLabel?.text = wikipediaLink
        }
        if let description = catInfo.breeds?.first?.description {
            descriptionLabel?.text = description
        }
        currentCatID = catInfo.id
    }
    
    func emitVote(_ vote: VoteType) {
        guard let key = self.apiKey else { return }
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = apiBaseURL
        urlComponents.path = "/v1/votes"
        let queryItems: [URLQueryItem] = [
            URLQueryItem(name: "api_key", value: key)
        ]
        urlComponents.queryItems = queryItems
        guard let url = urlComponents.url,
              let currentCatID = currentCatID else {
            print("Aqui")
            return
        }
        let voteModel = VoteModel(imageID: currentCatID, subID: "rose10", value: vote.rawValue)
        let jsonEndocer = JSONEncoder()
        do {
            let encodedVote = try jsonEndocer.encode(voteModel)
            var urlRequest = URLRequest(url: url)
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.httpMethod = "POST"
            urlRequest.httpBody = encodedVote
            urlSession.dataTask(with: urlRequest) { [weak self] data, response, error in
                guard let self = self else { return }
                if let _ = error {
                    self.displayEmitVoteError()
                    return
                }
                
                guard let response = response as? HTTPURLResponse else {
                    self.displayEmitVoteError()
                    return
                }
                
                guard response.statusCode == 200 || response.statusCode == 201 else {
                    self.displayEmitVoteError()
                    return
                }
                
                self.obtainCatInfo()
                
            }.resume()
            
        } catch {
            displayEmitVoteError()
        }
    }
    
    func displayLoader() {
        guard loadingState != .loading else { return }
        DispatchQueue.main.async {
            guard let catImageView = self.catImageView else { return }
            let loaderView = UIView(frame: catImageView.frame)
            loaderView.backgroundColor = UIColor(white: 1, alpha: 0.8)
            self.loaderView = loaderView
            loaderView.translatesAutoresizingMaskIntoConstraints = false
            catImageView.addSubview(loaderView)
            loaderView.centerXAnchor.constraint(equalTo: catImageView.centerXAnchor).isActive = true
            loaderView.centerYAnchor.constraint(equalTo: catImageView.centerYAnchor).isActive = true
            loaderView.heightAnchor.constraint(equalTo: catImageView.heightAnchor).isActive = true
            loaderView.bottomAnchor.constraint(equalTo: catImageView.bottomAnchor).isActive = true
            loaderView.leadingAnchor.constraint(equalTo: catImageView.leadingAnchor).isActive = true
            loaderView.trailingAnchor.constraint(equalTo: catImageView.trailingAnchor).isActive = true
            switch self.currentVoteState {
            case .notSelected:
                loaderView.backgroundColor = .gray.withAlphaComponent(0.5)
            case .cuteSelected:
                loaderView.backgroundColor = .systemGreen.withAlphaComponent(0.5)
            case .notCuteSelected:
                loaderView.backgroundColor = .systemRed.withAlphaComponent(0.5)
            }
            
            let activityIndicatorView = UIActivityIndicatorView(style: .medium)
            activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
            loaderView.addSubview(activityIndicatorView)
            activityIndicatorView.centerXAnchor.constraint(equalTo: loaderView.centerXAnchor).isActive = true
            activityIndicatorView.centerYAnchor.constraint(equalTo: loaderView.centerYAnchor).isActive = true
            activityIndicatorView.transform = CGAffineTransform(scaleX: 2, y: 2)
            activityIndicatorView.startAnimating()
            activityIndicatorView.color = .white
            self.loadingState = .loading
        }
    }
    
    func hideLoader() {
        DispatchQueue.main.async {
            self.loaderView?.removeFromSuperview()
            self.loaderView = nil
            self.loadingState = .noLoading
        }
    }
    
    
    func displayErrorView() {
        DispatchQueue.main.async {
            let alertView = UIAlertController(
                title: "Error while trying to bring the next cat 😿",
                message: nil,
                preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "Try again? 🐱", style: .default) { [weak self] _ in
                self?.obtainCatInfo()
                alertView.dismiss(animated: true)
            }
            alertView.addAction(alertAction)
            self.present(alertView, animated: true)
        }
    }
    
    func displayEmitVoteError() {
        DispatchQueue.main.async {
            let alertView = UIAlertController(
                title: "Error while trying to emit your vote 😾",
                message: "For some reason your vote could not be emited, so try again pls",
                preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "Ok 🐱", style: .default) { _ in
                alertView.dismiss(animated: true)
            }
            alertView.addAction(alertAction)
            self.present(alertView, animated: true)
        }
    }
    
    @IBAction func didPressCuteButton(_ sender: UIButton) {
        currentVoteState = .cuteSelected
        displayLoader()
        emitVote(.cute)
    }
    
    @IBAction func didPressNotCuteButton(_ sender: UIButton) {
        currentVoteState = .notCuteSelected
        displayLoader()
        emitVote(.notCute)
    }
    
}
