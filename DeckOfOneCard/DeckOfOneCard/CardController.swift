//
//  CardController.swift
//  DeckOfOneCard
//
//  Created by James Pacheco on 4/18/16.
//  Copyright © 2016 James Pacheco. All rights reserved.
//

import UIKit

class CardController {
	
	static let baseURL = URL(string: "http://deckofcardsapi.com/api/deck/new/draw/")
	
	static func draw(numberOfCards: Int, completion: @escaping ((_ card: [Card]) -> Void)) {
		guard let url = self.baseURL else { fatalError("URL optional is nil") }
        
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        
        let cardCountQueryItem = URLQueryItem(name: "count", value: "\(numberOfCards)")
        
        components?.queryItems = [cardCountQueryItem]
        
        guard let requestURL = components?.url else { return }
        
        var request = URLRequest(url: requestURL)
        
        request.httpMethod = "GET"
        
        let dataTask = URLSession.shared.dataTask(with: request) { (data, _, error) in
			
			guard let data = data,
				let responseDataString = String(data: data, encoding: .utf8) else {
					NSLog("No data returned from network request")
					completion([])
					return
			}
            
			guard let responseDictionary = (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)) as? [String: Any],
				let cardDictionaries = responseDictionary["cards"] as? [[String: Any]] else {
					NSLog("Unable to serialize JSON. \nResponse: \(responseDataString)")
					completion([])
					return
			}
			
			let cards = cardDictionaries.flatMap { Card(dictionary: $0) }
			completion(cards)
		}
        
		dataTask.resume()
	}
    
    static func image(forURL url: String, completion: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: url) else { fatalError("Image URL optional is nil") }
        
        let dataTask = URLSession.shared.dataTask(with: url) { (data, _, error) in
            
            guard let data = data,
                let image = UIImage(data: data) else {
                    DispatchQueue.main.async { completion(nil) }
                    return
            }
            
            DispatchQueue.main.async { completion(image) }
        }
        
        dataTask.resume()
    }
    
    
}
