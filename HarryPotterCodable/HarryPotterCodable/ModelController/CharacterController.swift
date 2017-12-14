//
//  CharacterController.swift
//  HarryPotterCodable
//
//  Created by Aaron Martinez on 12/5/17.
//  Copyright © 2017 Aaron Martinez. All rights reserved.
//

import UIKit

class CharacterController {
    
    static let shared = CharacterController()
    
    var characters: [Character] = []
    
    let charactersURL = URL(string: "http://hp-api.herokuapp.com/api/characters")!
    
    func fetchAllCharacters(completion: @escaping() -> Void) {
        
        URLSession.shared.dataTask(with: charactersURL) { (data, _, error) in
            
            if let error = error {
                print("There was an error fetching characters: \(error.localizedDescription)")
                completion()
                return
            }
            
            guard let data = data else { completion(); return }
            
            do {
                let decoder = JSONDecoder()
                let charactersWithoutImages = try decoder.decode([Character].self, from: data)
                self.characters = charactersWithoutImages
                completion()
            } catch let error {
                print("There was an error decoding the data into characters: \(error.localizedDescription)")
            }
            }.resume()
    }
    
    func fetchImage(at url: URL, completion: @escaping(UIImage?) -> Void) {
        
        URLSession.shared.dataTask(with: url) { (data, _, error) in
            if let error = error {
                print("There was an error fetching image: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let data = data,
                let image = UIImage(data: data)
                else { completion(nil); return }
            completion(image)
            }.resume()
    }
}

