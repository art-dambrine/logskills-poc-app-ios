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
    @State var stats: Stats = Stats(focus_moyen_jour_periode: 0, focus_jours: Focus_jour(date_jour: "", focus_total_jour: 0), focus_activites: [Focus_activite(id_activite: 0, focus_total_activite: 0)])
    @State var focus_activites: [Focus_activite] = []
    
    @State private var selectedPeriode = "Day"
    let possibilitiesPeriode = ["Day","Week","Logs"]
    
    
    
    var body: some View {
        
        Form {
            
            Section(){
                Picker("Select", selection: $selectedPeriode){
                    ForEach(possibilitiesPeriode, id: \.self){
                        Text($0)
                            .font(.subheadline)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            
            
            if(selectedPeriode == "Day") {
                                                         
                Section(header: Text("Aujourd'hui")){
                    Text("Au total \(self.stats.focus_moyen_jour_periode) mins focus")
                }
                
                Section(header: Text("Répartition")){
                    List{
                        ForEach(self.focus_activites, id: \.id_activite ){ activite in
                            
                            HStack{
                                Text("\( (activitiesObs.activities.filter{ $0.id == activite.id_activite }.count > 0) ? activitiesObs.activities.filter{ $0.id == activite.id_activite }[0].nom : "" ).")
                                    .frame(width: 100, alignment: .leading)
                                
                                if((self.focus_activites[0].focus_total_activite > 0)){
                                    ProgressView("\(activite.focus_total_activite) mins",value: round((Double(activite.focus_total_activite)/Double(self.focus_activites[0].focus_total_activite))*10)/10, total: 1)
                                }
                                
                                                                
                            }
                            
                        }
                    }
                }
            }
            
            if(selectedPeriode == "Week") {
                Section(header: Text("Cette semaine")){
                    Text("Moyenne de \(self.stats.focus_moyen_jour_periode) mins focus")
                }
                
                Section(header: Text("Répartition")){
                    List{
                        ForEach(self.focus_activites, id: \.id_activite ){ activite in
                            
                            HStack{
                                Text("\( (activitiesObs.activities.filter{ $0.id == activite.id_activite }.count > 0) ? activitiesObs.activities.filter{ $0.id == activite.id_activite }[0].nom : "" ).")
                                    .frame(width: 100, alignment: .leading)
                                
                                if((self.focus_activites[0].focus_total_activite > 0)){
                                    ProgressView("\(activite.focus_total_activite) mins",value: round((Double(activite.focus_total_activite)/Double(self.focus_activites[0].focus_total_activite))*10)/10, total: 1)
                                }
                                
                                                                
                            }
                            
                        }
                    }
                }
            }
                        
            if(selectedPeriode == "Logs"){
                Section(header: Text("Mes 10 derniers logs")) {
                    
                    List{
                        ForEach(self.logs.indices, id: \.self){ index in
                            HStack{
                                Text("\( (activitiesObs.activities.filter{ $0.id == self.logs[index].id_activite }.count > 0) ? activitiesObs.activities.filter{ $0.id == self.logs[index].id_activite }[0].nom : "" ).")
                                Spacer()
                                Text("\(self.logs[index].temps_actif) mins, \(self.logs[index].date.components(separatedBy: "T")[0])")
                                    .font(.subheadline)
                                    .frame(width:120, alignment: .trailing)
                            }
                            .padding(4)
                            .opacity(index % 2 == 0 ? 0.7 : 1 )
                                
                                                        
                        }
                        
                    }
                    
                }
            }
            
            
        }.onAppear(){
            logsApi().getRecentLogs(apiBaseUrl: settings.apiBaseUrl, token: user.token) { (logs) in
                self.logs = logs
            }
            
            logsApi().getStatsToday(apiBaseUrl: settings.apiBaseUrl, token: user.token) { (stats) in
                self.stats = stats
                self.focus_activites = stats.focus_activites
            }

        }
        
            
        
    }
            
}

struct StatsView_Previews: PreviewProvider {
    static var previews: some View {
        StatsView()
    }
}
