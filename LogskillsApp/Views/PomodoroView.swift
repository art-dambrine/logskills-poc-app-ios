//
//  PomodoroView.swift
//  LogskillsApp
//
//  Created by Arthur Dambrine on 11/04/2021.
//

import SwiftUI

struct PomodoroView: View {
    
    @EnvironmentObject var settings: Settings
    
    @ObservedObject var timerManager = TimerManager()
    
    @State var selectedPickerIndex: Int = 0
    @State var activities: [Activity] = []
    @State var activitySelected: Activity?
    
    let defaultTimer = 25 // mins
    let defaultPause = 5 // mins
    let defaultNbRounds = 3 // 3 rounds        
    let multiplicateurSecondes = 1 // changer pendant le dev
    
    var body: some View {
        
        VStack {
            
            Text("\(self.timerManager.minutes):\(self.timerManager.seconds)")
                .font(.system(size: 60))
                .padding(.top,10)
            
            if (self.timerManager.timerMode == .paused || self.timerManager.timerMode == .initial) {
                VStack {
                    Button(action:{
                        
                        if self.timerManager.timerMode == .initial {
                            print(self.selectedPickerIndex)
                            self.timerManager.setTimerlength(secondes: (self.activitySelected?.temps_focus ?? 1) * multiplicateurSecondes)
                        }
                        
                        self.timerManager.startTimer(
                            nbRoundMax: self.activitySelected?.nb_round ?? defaultNbRounds,
                            nbPauseMax: (self.activitySelected?.nb_round ?? defaultNbRounds) - 1,
                            pauseLength: (self.activitySelected?.temps_pause ?? defaultPause) * multiplicateurSecondes
                        )
                        
                        print("START")
                        
                    }){
                        Image(systemName: "play.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: /*@START_MENU_TOKEN@*/.fill/*@END_MENU_TOKEN@*/)
                            .frame(width: 90, height: 90)
                            .foregroundColor( self.timerManager.timerMode == .breaktime ? .blue : .pink)
                        
                    }
                    .padding(.all)
                             
                }
            } else {
                Button(action:{
                    print("STOP")
                    self.timerManager.stopTimer()
                }){
                    Image(systemName: "pause.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: /*@START_MENU_TOKEN@*/.fill/*@END_MENU_TOKEN@*/)
                        .frame(width: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, height: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/)
                        .foregroundColor( self.timerManager.timerMode == .breaktime ? .blue : .pink)
                }
                .padding(.all)
            }
            
            // Infos sur l'activité selectionnée
            if self.selectedPickerIndex != 0 {
                Text("Temps focus: \(self.activitySelected?.temps_focus ?? defaultTimer)")
                Text("Temps pause: \(self.activitySelected?.temps_pause ?? defaultPause)")
                Text("Nombre de rounds: \(self.activitySelected?.nb_round ?? defaultNbRounds)")
            }
            
            if self.timerManager.timerMode == .initial {
                
                Picker(selection: $selectedPickerIndex, label: Text("")){
                    ForEach(activities, id: \.self.id) { activity in
                        Text("N°\(activity.id). " + activity.nom + "")
                    }
                }
                .onReceive([self.selectedPickerIndex].publisher.first()) { (value) in
                    // print(value)
                    if value != 0 {
                        self.activitySelected = activities.filter{ $0.id == value }[0]
                    }
                }
                .labelsHidden()
                
            } else {
                Button(action:{
                    self.timerManager.stopTimer()
                    self.timerManager.restartTimer()
                    print("RESTART")
                }){
                    Image(systemName: "backward.end.alt")
                        .resizable()
                        .aspectRatio(contentMode: /*@START_MENU_TOKEN@*/.fill/*@END_MENU_TOKEN@*/)
                        .frame(width: 20, height: 20)
                        .foregroundColor(.red)
                }
                .padding(.all)
                
                Text(self.activitySelected?.nom ?? "")
                    .font(.title2)
                
                Spacer()
                
                if(self.timerManager.timerMode == .breaktime) {
                    Text("Pause n°" + String(self.timerManager.pauseCurrent))
                        .bold()
                        .font(.title2)
                    
                    Text("Take a break :)")
                        .bold()
                        .font(.title3)
                } else {
                    Text("Round n°" + String(self.timerManager.roundCurrent))
                        .bold()
                        .font(.title2)
                    
                    Text("Just do it !")
                        .bold()
                        .font(.title3)
                }
                
            }
            
            
            Spacer()
            
        }
        .padding(20)
        .onAppear() {
            // availableActivities
            activityApi().getAllActivities(apiBaseUrl: settings.apiBaseUrl) { (activities) in
                self.activities = activities
                if activities.count > 0 {
                    self.selectedPickerIndex = activities[0].id
                }
                // print(activities.map{$0.nom}) // -> ["Bureau dev", "Muscu light", "Le projeeetttt", "VTT en forêt"]
            }
        }
        
        
        
        
    }
}

struct PomodoroView_Previews: PreviewProvider {
    static var previews: some View {
        PomodoroView()
    }
}
