//
//  ListCategoryView.swift
//  LogskillsApp
//
//  Created by Arthur Dambrine on 09/04/2021.
//

import SwiftUI

struct Category: Codable {
    let id_categorie: Int
    let nom: String
}

class apiCallCategories {
    func getCategories(completion:@escaping ([Category]) -> ()) {
        guard let url = URL(string: "https://api.art-dambrine.ovh/categories") else { return }
        URLSession.shared.dataTask(with: url) { (data, _, _) in
            
            let categories = try! JSONDecoder().decode([Category].self, from: data!)
            // print(categories)
            
            DispatchQueue.main.async {
                completion(categories)
            }
        }
        .resume()
    }
}


struct ListCategoryView: View {
    @State var categories: [Category] = []
    
    var body: some View {
        NavigationView{
            VStack {
                
                List{
                    ForEach(categories, id: \.id_categorie){ categorie in
                        HStack{
                            Text(String(categorie.id_categorie))
                                .font(.headline)
                            Text(categorie.nom)
                                .font(.subheadline)
                        }
                    }
                    
                }
                
            }.onAppear {
                print("ContentView appeared!")
                apiCallCategories().getCategories { (categories) in
                    self.categories = categories
                }
            }
            .navigationTitle("Categories")
        }
        
    }
}

struct ListCategoryView_Previews: PreviewProvider {
    static var previews: some View {
        ListCategoryView()
    }
}

