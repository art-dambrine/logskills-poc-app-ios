//
//  SettingsView.swift
//  LogskillsApp
//
//  Created by Arthur Dambrine on 09/04/2021.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @EnvironmentObject var user: User
    @EnvironmentObject var settings: Settings
    
    @State private var enableShowInClear = false
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var apiUrl: String = ""
    @State private var sound: String = ""
    
    @State private var isAlreadyInitialized = false
    
    private let soundManager = SoundManager()
    
    func saveChanges () {
        user.username = username
        user.password = password
        settings.apiBaseUrl = apiUrl
        settings.prefSound = sound
        
        UserDefaults.standard.set(username, forKey: "username")
        UserDefaults.standard.set(password, forKey: "password")
        UserDefaults.standard.set(apiUrl, forKey: "apiUrl")
        UserDefaults.standard.set(sound, forKey: "sound")  
    }
    
    var body: some View {
        
        NavigationView {
            Form {
                Section(header: Text("Profile")){
                    TextField("Username", text: $username)
                        .autocapitalization(.none)
                    
                    SecureField("Password", text: $password)
                    
                    if enableShowInClear { TextField("", text: $password) }
                    Toggle("Show password in clear.", isOn: $enableShowInClear.animation())
                }
                
                
                Section(header: Text("API settings")){
                    TextField("BaseUrl", text: $apiUrl)
                }
                
                Section(header: Text("Prefered end of round sound")){
                    let possibilities = soundManager.getSoundPossibilities()
                    
                    Picker("Select sound", selection: $sound){
                        ForEach(possibilities, id: \.self){
                            Text($0)
                                .font(.subheadline)
                        }
                    }
                }
                
                
                Section {
                    Button("Save changes & authenticate") {
                        
                        saveChanges()
                        
                        // Faire l'appel à l'api pour récuperer le token d'auth
                        apiUser().authenticate(apiBaseUrl: settings.apiBaseUrl, login: username, password: password, completion: { (token) in
                            // print(token.accessToken)
                            UserDefaults.standard.set(token.accessToken, forKey: "accessToken")
                            
                            // return back to home view after 0.2 sec
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                action: do {self.presentationMode.wrappedValue.dismiss()}
                            }
                        }
)
                                                
                        
                    }
                }
                
            }
            .navigationBarTitle("Settings")
            .onAppear(){
                
                if(!isAlreadyInitialized) {
                    username = user.username
                    password = user.password
                    apiUrl = settings.apiBaseUrl
                    sound = settings.prefSound
                    isAlreadyInitialized = true
                }
                
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
