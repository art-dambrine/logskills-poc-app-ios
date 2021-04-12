//
//  ContentView.swift
//  LogskillsApp
//
//  Created by Arthur Dambrine on 09/04/2021.
//

import SwiftUI


struct ContentView: View {
    @State private var isShowingDetailView = false
    @ObservedObject var user = User()
    @ObservedObject var settings = Settings()

    
    var body: some View {
        
        NavigationView{
            TabView {
                
                ListActivityView()
                    .tabItem {
                        Image(systemName: "list.star")
                        Text("Activites")
                    }
                
                PomodoroView()
                    .tabItem {
                        Image(systemName: "stopwatch.fill")
                        Text("Chrono")
                    }
                
                Text("The content of Stats is coming soon..")
                    .tabItem {
                        Image(systemName: "filemenu.and.selection")
                        Text("Stats")
                    }
            }
            .padding(.bottom,2)
            
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
        .environmentObject(settings)
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

