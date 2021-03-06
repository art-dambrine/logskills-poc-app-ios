//
//  ListCategoryView.swift
//  LogskillsApp
//
//  Created by Arthur Dambrine on 09/04/2021.
//

import Foundation
import SwiftUI

struct Category: Codable {
    let id: Int
    let nom: String        
}

class CategoriesObs: ObservableObject {
    @ObservedObject var settings = Settings()
    @Published var categories: [Category] = []
    
    init(){
        print("Init activities")
        self.refreshCategoryList()
    }
    
    func refreshCategoryList(){
        categoryApi().getAllCategories(apiBaseUrl: settings.apiBaseUrl) { (categories) in
            self.categories = categories
            print("INIT CATEGOERIES : ")
            print(categories)
        }
    }
    
}


class categoryApi {
    func getAllCategories(apiBaseUrl:String, completion:@escaping ([Category]) -> ()) {
        let semaphore = DispatchSemaphore (value: 0)
        
        guard let url = URL(string: apiBaseUrl+"/categories") else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            guard let data = data else {
              print(String(describing: error))
              semaphore.signal()
              return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("statusCode \(httpResponse.statusCode)")
                
                if (httpResponse.statusCode == 200) {
                    let categories = try! JSONDecoder().decode([Category].self, from: data)
                    // print(categories)
                    DispatchQueue.main.async {
                        completion(categories)
                    }
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

