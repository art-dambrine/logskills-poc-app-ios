//
//  SettingsView.swift
//  LogskillsApp
//
//  Created by Arthur Dambrine on 09/04/2021.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var user: User
    @EnvironmentObject var settings: Settings
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State private var enableShowInClear = false
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var apiUrl: String = ""
    
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
                
                Section {
                    Button("Save changes") {
                        user.username = username
                        user.password = password
                        settings.apiBaseUrl = apiUrl
                        
                        UserDefaults.standard.set(username, forKey: "username")
                        UserDefaults.standard.set(password, forKey: "password")
                        UserDefaults.standard.set(apiUrl, forKey: "apiUrl")
                        
                        // return back to home view after 0.2 sec
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            action: do {self.presentationMode.wrappedValue.dismiss()}
                        }
                        
                        
                    }
                }
                
            }
            .navigationBarTitle("Settings")
            .onAppear(){
                username = user.username
                password = user.password
                apiUrl = settings.apiBaseUrl
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
