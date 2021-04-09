//
//  ContentView.swift
//  LogskillsApp
//
//  Created by Arthur Dambrine on 09/04/2021.
//

import SwiftUI

class User: ObservableObject {
    @Published var score = 0
}


struct ContentView: View {
    @State private var isShowingDetailView = false
    @ObservedObject var user = User()

    
    var body: some View {
        
        NavigationView{
            TabView {
                
                ListCategoryView()
                    .tabItem {
                        Image(systemName: "list.star")
                        Text("Activites")
                    }
                
                Text("Display infos from the selected activity")
                    .tabItem {
                        Image(systemName: "stopwatch.fill")
                        Text("Pomodoro")
                    }
                
                Text("The content of Stats is coming soon..")
                    .tabItem {
                        Image(systemName: "circle.fill")
                        Text("Stats")
                    }
            }
            .navigationBarItems(
                trailing: HStack {
                    NavigationLink(destination: SettingsView(), isActive: $isShowingDetailView){
                        EmptyView()
                    }
                            
                    
                    Button(action: {
                        isShowingDetailView.toggle()
                    }) {
                        HStack(spacing: 10) {
                            Image(systemName: "slider.horizontal.3")
                        }
                    }
                }
                
                
            )
            .navigationBarTitle("Logskills App")
            .navigationBarTitleDisplayMode(.inline)
        }
        
        // Important à ajouter
        .environmentObject(user)
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

