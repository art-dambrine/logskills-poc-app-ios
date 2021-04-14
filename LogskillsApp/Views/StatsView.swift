//
//  StatsView.swift
//  LogskillsApp
//
//  Created by Arthur Dambrine on 14/04/2021.
//

import SwiftUI



struct StatsView: View {
    @EnvironmentObject var activitiesObs: ActivitiesObs
    @EnvironmentObject var settings: Settings
    @EnvironmentObject var user: User
    @State var logs: [Logs] = []
    
    
    
    var body: some View {
        
        Form {
            
            
            
            Section(header: Text("Derniers logs")) {
                
                List{
                    ForEach(self.logs, id: \.id){ log in
                                                              
                        HStack{
                            Text("\( (activitiesObs.activities.filter{ $0.id == log.id_activite }.count > 0) ? activitiesObs.activities.filter{ $0.id == log.id_activite }[0].nom : "" ).")
                                                            
                            Text("Focus : \(log.temps_actif) mins, \(log.date.components(separatedBy: "T")[0])")
                                .font(.subheadline)
                        }
                            
                                                    
                    }
                    
                }
                
            }
            
        }.onAppear(){
            logsApi().getRecentLogs(apiBaseUrl: settings.apiBaseUrl, token: user.token) { (logs) in
                self.logs = logs
            }

        }
        
            
        
    }
}

struct StatsView_Previews: PreviewProvider {
    static var previews: some View {
        StatsView()
    }
}
