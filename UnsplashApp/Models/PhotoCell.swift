//
//  PhotoCell.swift
//  UnsplashApp
//
//  Created by Никита Горбунов on 06.09.2022.
//

import Foundation

struct PhotoCell: Codable {
    let id: String
    let width: Int?
    let height: Int?
    let downloadsCount: Int
    var likesCount: Int
    let authorName: String
    let location: String
    let smallImage: URL?
    let thumbImage: URL?
    let createdDate: String
    var isFavourite: Bool = false
}
