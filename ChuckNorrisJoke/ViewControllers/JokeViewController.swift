//
//  JokeViewController.swift
//  ChuckNorrisJoke
//
//  Created by netlanc on 16.02.2024.
//
import UIKit

class JokeViewController: UIViewController {
    
    // Добавьте замыкание
    var jokeAddedHandler: (() -> Void)?
    
    // Определите метод добавления шутки
    
    let networkService = NetworkService.shared
    let databaseService = DatabaseService.shared
    
    let jokeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .black
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let categoryLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .gray
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let dateLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .gray
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let loadJokeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Загрузить шутку", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        button.tintColor = .white
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(loadJokeButtonTapped), for: .touchUpInside)
        return button
    }()
    
    let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        navigationItem.title = "Шутка"
        navigationItem.rightBarButtonItem?.tintColor = #colorLiteral(red: 0, green: 0, blue: 0.8297687173, alpha: 1)
        
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        let safeArea = view.safeAreaLayoutGuide
        
        view.addSubview(jokeLabel)
        view.addSubview(categoryLabel)
        view.addSubview(dateLabel)
        view.addSubview(loadJokeButton)
        
        NSLayoutConstraint.activate([
            jokeLabel.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            jokeLabel.centerYAnchor.constraint(equalTo: safeArea.centerYAnchor, constant: -100),
            jokeLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
            jokeLabel.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20),
            
            categoryLabel.topAnchor.constraint(equalTo: jokeLabel.bottomAnchor, constant: 20),
            categoryLabel.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            
            dateLabel.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: 5),
            dateLabel.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            
            loadJokeButton.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 20),
            loadJokeButton.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            loadJokeButton.widthAnchor.constraint(equalToConstant: 200),
            loadJokeButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc private func loadJokeButtonTapped() {
        activityIndicator.startAnimating()
        loadJokeButton.isEnabled = false
        
        networkService.loadRandomJoke { [weak self] jokeResponse, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.loadJokeButton.isEnabled = true
            }
            
            if let error = error {
                print("Error loading joke: \(error.localizedDescription)")
                return
            }
            
            guard let jokeResponse = jokeResponse else {
                print("No joke response received")
                return
            }
            
            self.databaseService.addJoke(jokeResponse: jokeResponse)
            
            DispatchQueue.main.async {
                self.jokeLabel.text = jokeResponse.value
                self.categoryLabel.text = "Категория: \(jokeResponse.categories?.joined(separator: ", ") ?? "Без категории")"
                self.dateLabel.text = "Дата: \(jokeResponse.createdAt ?? "Не определена")"
                
                self.jokeAddedHandler?()
            }
        }
    }
    
    
}
