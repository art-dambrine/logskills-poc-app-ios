//
//  SettingsView.swift
//  LogskillsApp
//
//  Created by Arthur Dambrine on 09/04/2021.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var user: User
    
    var body: some View {
        
        VStack{
            Text("Ici on peut modifier les reglages")
            
            Text("Score : \(user.score)")
            Button("Increase"){
                self.user.score += 1
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
