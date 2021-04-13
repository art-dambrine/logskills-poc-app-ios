//
//  ContentView.swift
//  LogskillsApp
//
//  Created by Arthur Dambrine on 09/04/2021.
//

import SwiftUI

struct ContentView: View {
    @State private var isShowingDetailView = false
    
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var user: User
    @EnvironmentObject var settings: Settings
    @EnvironmentObject var activitiesObs: ActivitiesObs
    @EnvironmentObject var CategoriesObs: CategoriesObs
    
    
    var body: some View {
        
        NavigationView{
            TabView(selection: $appState.selectedTab) {
                
                ListActivityView()
                    .tabItem {
                        Image(systemName: "list.star")
                        Text("Activites")
                    }
                    .tag(0)
                
                PomodoroView()
                    .tabItem {
                        Image(systemName: "stopwatch.fill")
                        Text("Chrono")
                    }
                    .tag(1)
                
                Text("The content of Stats is coming soon..")
                    .tabItem {
                        Image(systemName: "filemenu.and.selection")
                        Text("Stats")
                    }
                    .tag(2)
            }
            .padding(.bottom,2)
//            .onChange(of: appState.selectedTab, perform: { index in
//                /// Example of event when we switch between tabs
//                print("HELLO \(index)")
//            })
            
            
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
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

