//
//  Settings.swift
//  LogskillsApp
//
//  Created by Arthur Dambrine on 11/04/2021.
//

import Foundation

class Settings: ObservableObject {
    @Published var apiBaseUrl: String = UserDefaults.standard.string(forKey: "apiUrl") ?? "http://art-dambrine.ovh:8003/api"    
}
