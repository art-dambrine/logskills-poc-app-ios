//
//  ListCategoryView.swift
//  LogskillsApp
//
//  Created by Arthur Dambrine on 09/04/2021.
//

import Foundation

struct Category: Codable {
    let id: Int
    let nom: String        
}

class categoryApi {
    func getAllCategories(apiBaseUrl:String, completion:@escaping ([Category]) -> ()) {
        
        guard let url = URL(string: apiBaseUrl+"/categories.json") else { return }
        
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
    
    func getCategoriesById(apiBaseUrl:String, categoryId: Int, completion:@escaping (Category) -> ()){
        let semaphore = DispatchSemaphore (value: 0)
        let urlRequst = apiBaseUrl + "/categories/" + String(categoryId)        
        var request = URLRequest(url: URL(string: urlRequst)!,timeoutInterval: Double.infinity)
        request.httpMethod = "GET"

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
          guard let data = data else {
            print(String(describing: error))
            semaphore.signal()
            return
          }
          print(String(data: data, encoding: .utf8)!)
            
            
            let category = try! JSONDecoder().decode(Category.self, from: data)          
            
            DispatchQueue.main.async {
                completion(category)
            }
            
            
          semaphore.signal()
        }

        task.resume()
        semaphore.wait()
    }
}

