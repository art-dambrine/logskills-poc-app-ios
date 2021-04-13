//
//  LogskillsAppApp.swift
//  LogskillsApp
//
//  Created by Arthur Dambrine on 09/04/2021.
//

import SwiftUI

final class AppState: ObservableObject {
    
    @Published var timerIsRunning: Bool = false
    
    // private setter because no other object should be able to modify this
    private (set) var previousSelectedTab = -1
    @Published var selectedTab: Int = 0 {
        didSet {
            previousSelectedTab = oldValue
        }
    }
    
}

@main
struct LogskillsAppApp: App {
    
    @ObservedObject var appState = AppState()
    @ObservedObject var user = User()
    @ObservedObject var settings = Settings()    
    @ObservedObject var activitiesObs = ActivitiesObs()
    @ObservedObject var categoriesObs = CategoriesObs()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .environmentObject(user)
                .environmentObject(settings)
                .environmentObject(activitiesObs)
                .environmentObject(categoriesObs)
        }
    }
}
