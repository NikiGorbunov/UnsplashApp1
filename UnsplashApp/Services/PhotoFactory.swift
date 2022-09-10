//
//  PhotoFactory.swift
//  UnsplashApp
//
//  Created by Никита Горбунов on 06.09.2022.
//

import Foundation

class PhotoFactory {
    
    private func generatePhotoCellModel(from response: Photo) -> PhotoCell {
        let id = response.id ?? ""
        let width = response.width
        let height = response.height
        let downloadsCount = response.downloads ?? 0
        let likesCount = response.likes ?? 0
        let location = response.user?.location ?? ""
        let authorName = response.user?.name ?? ""
        
        var createdDate = ""
        let date = response.createdDate ?? ""
        if let index = date.range(of: "T")?.lowerBound {
            let temp = date[..<index]
            createdDate = String(temp)
        }
        
        guard let smallUrl = response.urls?["small"],
              let thumbUrl = response.urls?["thumb"]
        else {
            return PhotoCell(id: id, width: width, height: height, downloadsCount: downloadsCount,
                             likesCount: likesCount, authorName: authorName,
                             location: location, smallImage: nil, thumbImage: nil, createdDate: createdDate)
        }
        
        let smallImageUrl = URL(string: smallUrl)
        let thumbImageUrl = URL(string: thumbUrl)
        return PhotoCell(id: id, width: width, height: height, downloadsCount: downloadsCount, likesCount: likesCount,
                         authorName: authorName, location: location, smallImage: smallImageUrl,
                         thumbImage: thumbImageUrl, createdDate: createdDate)
    }
    
    func buildCellsModels(from response: [Photo], completion: (([PhotoCell]) -> Void)) {
        let models = response.compactMap(generatePhotoCellModel)
        completion(models)
    }
}
