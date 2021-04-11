//
//  ListCategoryView.swift
//  LogskillsApp
//
//  Created by Arthur Dambrine on 09/04/2021.
//

import Foundation

struct Category: Codable {
    let id_categorie: Int
    let nom: String        
}

class categoryApi {
    func getAllCategories(apiBaseUrl:String, completion:@escaping ([Category]) -> ()) {
        
        guard let url = URL(string: apiBaseUrl+"/categories") else { return }
        
        URLSession.shared.dataTask(with: url) { (data, _, _) in
            if (data != nil) {
                let categories = try! JSONDecoder().decode([Category].self, from: data!)
                
                DispatchQueue.main.async {
                    completion(categories)
                }
            }
                        
        }
        .resume()
    }
}

