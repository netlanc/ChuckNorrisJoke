//
//  DatabaseService.swift
//  ChuckNorrisJoke
//
//  Created by netlanc on 17.02.2024.
//
import Foundation
import RealmSwift

class DatabaseService {
    static let shared = DatabaseService()
    private var realm: Realm // Создание экземпляра Realm
    
    private init() {
        // Установка конфигурации Realm
        let config = Realm.Configuration(
            schemaVersion: 1
        )
        // Применяем новую конфигурацию
        Realm.Configuration.defaultConfiguration = config
        // Инициализация Realm с новой конфигурацией
        self.realm = try! Realm()
    }
    
    // Добавление шутки в базу данных
    func addJoke(jokeResponse: JokeResponse) {
        guard let jokeId = jokeResponse.id else {
            print("Не найден ID шутки")
            return
        }
        
        if jokeExistsWithIdApi(jokeId) {
            print("Шутка с idApi \(jokeId) уже существует в базе данных")
            return
        }
        
        DispatchQueue.main.async {
            try! self.realm.write {
                var categoriesToAdd: [Category] = []
                
                if let categoryNames = jokeResponse.categories, !categoryNames.isEmpty {
                    // Получаем объекты категорий из их названий, добавляем их в массив
                    categoriesToAdd = self.getCategoriesFromNames(categoryNames)
                } else {
                    // Проверяем, существует ли уже категория "Без категории"
                    if let existingCategory = self.realm.objects(Category.self).filter("name = %@", "Без категории").first {
                        // Если существует, добавляем ее в массив
                        categoriesToAdd.append(existingCategory)
                    } else {
                        // Иначе создаем новую категорию и добавляем ее в массив
                        let defaultCategory = Category()
                        defaultCategory.name = "Без категории"
                        categoriesToAdd.append(defaultCategory)
                    }
                }
                
                // Создаем новую шутку
                let newJoke = Joke()
                newJoke.idApi = jokeId
                
                newJoke.createdAt = self.dateFromString(jokeResponse.createdAt)
                newJoke.value = jokeResponse.value ?? ""
                
                // Привязываем категории к шутке и добавляем шутку в категорию
                for category in categoriesToAdd {
                    if let existingCategory = self.realm.objects(Category.self).filter("name = %@", category.name).first {
                        existingCategory.jokes.append(newJoke)
                        self.realm.add(existingCategory, update: .modified)
                    } else {
                        category.jokes.append(newJoke)
                        self.realm.add(category)
                    }
                    newJoke.categories.append(category)
                }
                
                // Добавляем шутку в базу данных
                self.realm.add(newJoke)
            }
        }
    }
    
    // Поиск шутки в БД
    private func jokeExistsWithIdApi(_ idApi: String) -> Bool {
        // Ищем шутку в базе данных по полю idApi
        let existingJoke = realm.objects(Joke.self).filter("idApi = %@", idApi).first
        
        // Если объект Joke с таким idApi существует, вернем true, иначе false
        return existingJoke != nil
    }
    
    private func dateFromString(_ dateString: String?) -> Date {
        guard let dateString = dateString else { return Date() }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSSSS" // Формат даты из jokeResponse.createdAt
        
        return dateFormatter.date(from: dateString) ?? Date()
    }
    
    // Получение объектов категорий из их названий
    private func getCategoriesFromNames(_ categoryNames: [String]) -> [Category] {
        var categories: [Category] = []
        for categoryName in categoryNames {
            if let existingCategory = realm.objects(Category.self).filter("name = %@", categoryName).first {
                categories.append(existingCategory)
            } else {
                let newCategory = Category()
                newCategory.name = categoryName
                realm.add(newCategory)
                categories.append(newCategory)
            }
        }
        return categories
    }
    
    // Получение всех шуток из базы данных
    func getAllJokes() -> [Joke] {
        let jokes = realm.objects(Joke.self).sorted(byKeyPath: "createdAt", ascending: false)
        
        return Array(jokes)
    }
    
    // Получение шуток для определенной категории
    func getJokesForCategory(_ categoryName: String) -> [Joke] {
        if let category = realm.objects(Category.self).filter("name = %@", categoryName).first {
            return Array(category.jokes)
        } else {
            print("Category '\(categoryName)' not found")
            return []
        }
    }
    
    // Получение всех категорий из базы данных
    func getAllCategories() -> [Category] {
        let categories = realm.objects(Category.self)
        return Array(categories)
    }
}
