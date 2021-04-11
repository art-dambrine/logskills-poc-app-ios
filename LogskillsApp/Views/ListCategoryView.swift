//
//  ListCategoryView.swift
//  LogskillsApp
//
//  Created by Arthur Dambrine on 11/04/2021.
//

import SwiftUI

struct ListCategoryView: View {
    @EnvironmentObject var settings: Settings
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
                categoryApi().getAllCategories(apiBaseUrl: settings.apiBaseUrl) { (categories) in
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
