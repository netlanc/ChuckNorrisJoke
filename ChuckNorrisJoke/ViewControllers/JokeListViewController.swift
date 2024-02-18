//
//  JokeListViewController.swift
//  ChuckNorrisJoke
//
//  Created by netlanc on 16.02.2024.
//
import UIKit

class JokeListViewController: UIViewController {
    
    private let tableView = UITableView()
    private let category: Category?
    private var jokes: [Joke] = []
    
    init(category: Category?) {
        self.category = category
        super.init(nibName: nil, bundle: nil)
        title = category?.name ?? "Шутки юмора )"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        loadJokes()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Убираем полосы между ячейками
        if !jokes.isEmpty {
            tableView.separatorStyle = .none
        }
        loadJokes()
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(JokeTableViewCell.self, forCellReuseIdentifier: JokeTableViewCell.reuseIdentifier)
        tableView.register(JokeTableViewCell.self, forCellReuseIdentifier: "NoJokeCell")
    }
    
    private func loadJokes() {
        
        if let categoryName = category?.name {
            jokes = DatabaseService.shared.getJokesForCategory(categoryName)
        } else {
            jokes = DatabaseService.shared.getAllJokes()
        }
        tableView.reloadData()
    }
}

extension JokeListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        jokes.isEmpty ? 1 : jokes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if jokes.isEmpty {
            
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "NoJokeCell")
            cell.textLabel?.text = "А шуток пока нет..."
            
            return cell
            
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: JokeTableViewCell.reuseIdentifier, for: indexPath) as! JokeTableViewCell
            let joke = jokes[indexPath.row]
            cell.configure(with: joke, hideCatecory: category != nil)
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if jokes.isEmpty {
            
            let jokeVC = JokeViewController()
            
            jokeVC.jokeAddedHandler = { [weak self] in
                
                // Обновляем экран категорий
                self?.tableView.separatorStyle = .none
                self?.loadJokes()
                
            }
            
            let navController = UINavigationController(rootViewController: jokeVC)
            present(navController, animated: true, completion: nil)
        }
    }
}

