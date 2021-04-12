//
//  Settings.swift
//  LogskillsApp
//
//  Created by Arthur Dambrine on 11/04/2021.
//

import Foundation

class Settings: ObservableObject {
    @Published var apiBaseUrl: String = UserDefaults.standard.string(forKey: "apiUrl") ?? "https://api.art-dambrine.ovh"
    @Published var prefSound: String = UserDefaults.standard.string(forKey: "sound") ?? "tone"
}
