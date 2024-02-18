//
//  Joke.swift
//  ChuckNorrisJoke
//
//  Created by netlanc on 17.02.2024.
//

import UIKit
import RealmSwift

class Joke: Object {
    @Persisted(primaryKey: false) var id = UUID().uuidString // Первичный ключ
    @Persisted var idApi: String = ""
    @Persisted var createdAt: Date
    @Persisted var value: String = ""
    @Persisted var categories = List<Category>()
}

class Category: Object {
    @Persisted(primaryKey: true) var name: String = ""
    @Persisted var jokes = List<Joke>()
}

// Структура для декодирования данных из API
struct JokeResponse: Decodable {
    let categories: [String]?
    let created_at: String? // Необходимо сконвертировать в формат для createdAt
    let id: String?
    let value: String?
    
    // Вычисляемые свойства для приведения в нужный формат
    var createdAt: String? {
        // Здесь можно выполнить преобразование created_at в нужный формат для createdAt
        return created_at
    }
}

