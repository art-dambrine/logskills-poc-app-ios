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
    @State var dayStats: Stats = Stats(focus_moyen_jour_periode: 0, focus_jours: Focus_jour(date_jour: "", focus_total_jour: 0), focus_activites: [Focus_activite(id_activite: 0, focus_total_activite: 0)])
    @State var focus_activites: [Focus_activite] = []
    
    @State var weekStats: Stats = Stats(focus_moyen_jour_periode: 0, focus_jours: Focus_jour(date_jour: "", focus_total_jour: 0), focus_activites: [Focus_activite(id_activite: 0, focus_total_activite: 0)])
    @State var week_focus_activites: [Focus_activite] = []
    
    @State var offsetDay: Int = 0
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
                
                Section(){
                    HStack{
                        Image(systemName: "chevron.backward.circle.fill")
                            .onTapGesture {
                                self.offsetDay -= 1
                                logsApi().getStatsFromTodayWithOffset(apiBaseUrl: settings.apiBaseUrl, token: user.token, offsetDay: self.offsetDay) { (stats) in
                                    self.dayStats = stats
                                    self.focus_activites = stats.focus_activites
                                }
                            }
                        
                        Spacer()
                        
                        Text("\(DateHelper().getTodayWithOffset(offsetDay: self.offsetDay))")
                        
                        Spacer()
                        
                        Image(systemName: "chevron.forward.circle.fill")
                            .onTapGesture {
                                self.offsetDay += 1
                                logsApi().getStatsFromTodayWithOffset(apiBaseUrl: settings.apiBaseUrl, token: user.token, offsetDay: self.offsetDay) { (stats) in
                                    self.dayStats = stats
                                    self.focus_activites = stats.focus_activites
                                }
                            }
                        
                    }
                }
                                                         
                Section{
                    Text("Au total \(self.dayStats.focus_moyen_jour_periode ?? 0) mins focus")
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
                    Text("Moyenne de \(self.weekStats.focus_moyen_jour_periode ?? 0) mins focus")
                }
                
                Section(header: Text("Répartition")){
                    List{
                        ForEach(self.week_focus_activites, id: \.id_activite ){ activite in
                            
                            HStack{
                                Text("\( (activitiesObs.activities.filter{ $0.id == activite.id_activite }.count > 0) ? activitiesObs.activities.filter{ $0.id == activite.id_activite }[0].nom : "" ).")
                                    .frame(width: 100, alignment: .leading)
                                
                                if((self.week_focus_activites[0].focus_total_activite > 0)){
                                    ProgressView("\(activite.focus_total_activite) mins",value: round((Double(activite.focus_total_activite)/Double(self.week_focus_activites[0].focus_total_activite))*10)/10, total: 1)
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
            
            logsApi().getStatsFromTodayWithOffset(apiBaseUrl: settings.apiBaseUrl, token: user.token, offsetDay: 0) { (stats) in
                self.dayStats = stats
                self.focus_activites = stats.focus_activites
            }
            
            logsApi().getStatsFromTodayWithOffset(apiBaseUrl: settings.apiBaseUrl, token: user.token, offsetDay: 0, isAskingCurrentWeek: true) { (stats) in
                self.weekStats = stats
                self.week_focus_activites = stats.focus_activites
            }

        }
        
            
        
    }
            
}

struct StatsView_Previews: PreviewProvider {
    static var previews: some View {
        StatsView()
    }
}
