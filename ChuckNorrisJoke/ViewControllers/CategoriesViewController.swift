//
//  CategoriesViewController.swift
//  ChuckNorrisJoke
//
//  Created by netlanc on 16.02.2024.
//
import UIKit

class CategoriesViewController: UIViewController {
    
    private let tableView = UITableView()
    private var categories: [Category] = []
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadCategories()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Категории"
        setupTableView()
    }
    
    private func setupTableView() {
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "NoCategoriesCell")
        tableView.register(CategoryTableViewCell.self, forCellReuseIdentifier: CategoryTableViewCell.reuseIdentifier)
        
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = .systemGray
        tableView.tableFooterView = UIView() // Убираем лишние разделители
    }
    
    private func loadCategories() {
        categories = DatabaseService.shared.getAllCategories()
        tableView.reloadData()
    }
}

extension CategoriesViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        categories.isEmpty ? 1 : categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if categories.isEmpty {
            
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "NoCategoriesCell")
            cell.textLabel?.text = "А категорий пока нет..."
            return cell
            
        } else {
            
            // только из за .subtitle используем CategoryTableViewCell для создания ячейки
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as! CategoryTableViewCell
            let category = categories[indexPath.row]
            let count = category.jokes.count
            
            cell.textLabel?.text = category.name
            cell.accessoryType = .disclosureIndicator // Стрелочку
            cell.detailTextLabel?.text = "\(count) Шуток"
            cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 12, weight: .regular)
            cell.detailTextLabel?.textColor = .gray
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if categories.isEmpty {
            
            let jokeVC = JokeViewController()
            
            jokeVC.jokeAddedHandler = { [weak self] in
                // Обновляем экран категорий
                self?.loadCategories()
            }
            
            let navController = UINavigationController(rootViewController: jokeVC)
            present(navController, animated: true, completion: nil)
            
        } else {
            
            let selectedCategory = categories[indexPath.row]
            let jokeListVC = JokeListViewController(category: selectedCategory)
            navigationController?.pushViewController(jokeListVC, animated: true)
            
        }
    }
}
