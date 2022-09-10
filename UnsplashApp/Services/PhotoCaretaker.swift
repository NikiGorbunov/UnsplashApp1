//
//  PhotoCaretaker.swift
//  UnsplashApp
//
//  Created by Никита Горбунов on 06.09.2022.
//

import Foundation

class PhotoCaretaker {
    
    private let emptyModels: [PhotoCell] = []
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    private let key = "PhotoCellModels"
    
    func save(models: [PhotoCell]) {
        do {
            let data = try self.encoder.encode(models)
            UserDefaults.standard.set(data, forKey: key)
        } catch {
            debugPrint(String(describing: error))
        }
    }
    
    func load() -> [PhotoCell] {
        guard let data = UserDefaults.standard.data(forKey: key)
        else { return emptyModels }
        
        do {
            let models = try self.decoder.decode([PhotoCell].self, from: data)
            return models
        } catch {
            debugPrint(String(describing: error))
            return emptyModels
        }
    }
    
    func delete(model: PhotoCell) {
        do {
            let models = load()
            let newModels = models.filter { $0.id != model.id }
            let data = try self.encoder.encode(newModels)
            UserDefaults.standard.set(data, forKey: key)
        } catch {
            debugPrint(String(describing: error))
        }
    }
}
