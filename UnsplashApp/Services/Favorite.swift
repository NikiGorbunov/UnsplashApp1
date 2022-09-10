//
//  Favorite.swift
//  UnsplashApp
//
//  Created by Никита Горбунов on 06.09.2022.
//

import Foundation

class Favourite {
    
    static let shared = Favourite()
    private let caretaker = PhotoCaretaker()
    var favourites: [PhotoCell] {
        didSet {
            caretaker.save(models: favourites)
        }
    }
    
    private init() {
        favourites = caretaker.load()
    }
    
    func add(model: PhotoCell) {
        favourites.append(model)
    }
    
    func delete(model: PhotoCell) {
        caretaker.delete(model: model)
        favourites = caretaker.load()
    }
}
