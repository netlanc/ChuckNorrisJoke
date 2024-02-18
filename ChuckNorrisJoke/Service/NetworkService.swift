//
//  JokeService.swift
//  ChuckNorrisJoke
//
//  Created by netlanc on 17.02.2024.
//

import UIKit
import RealmSwift


class JokeService {
    static let shared = JokeService() // Singleton
    
    private init() {}
    
    // Загрузка случайной шутки с API Chuck Norris
    func loadRandomJoke(completion: @escaping (Joke?, Error?) -> Void) {
        guard let url = URL(string: "https://api.chucknorris.io/jokes/random") else {
            completion(nil, NSError(domain: "Invalid URL", code: -1, userInfo: nil))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                completion(nil, error)
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(JokeResponse.self, from: data)
                
                let joke = Joke()
                joke.id_api = response.id // Сохраняем id из API
                joke.createdAt = response.createdAt
                joke.iconURL = response.iconURL
                joke.jokeURL = response.jokeURL
                joke.value = response.value
                
                // Создаем объекты Category и добавляем их в список категорий
                if let categories = response.categories {
                    let realm = try Realm()
                    try realm.write {
                        for categoryName in categories {
                            let category = Category()
                            category.name = categoryName
                            realm.add(category, update: .modified)
                            joke.categories.append(category)
                        }
                    }
                }
                
                completion(joke, nil)
            } catch {
                completion(nil, error)
            }
        }.resume()
    }
}
