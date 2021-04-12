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
    
    
    var body: some View {
        
        ScrollView(.vertical){
            VStack {
                
                Text("Start Pomodoro")
                    .bold()
                    .font(.title2)
                
                Text("\(timerManager.minutes):\(timerManager.seconds)")
                    .font(.system(size: 60))
                    .padding(.top,10)
                
                if (timerManager.timerMode == .paused || timerManager.timerMode == .initial) {
                    VStack {
                        Button(action:{
                            
                            if timerManager.timerMode == .initial {
                                print(self.selectedPickerIndex)
                                self.timerManager.setTimerlength(secondes: (self.activitySelected?.temps_focus ?? 1) * 60)
                            }
                            
                            timerManager.startTimer()
                            print("START")
                            
                        }){
                            Image(systemName: "play.circle.fill")
                                .resizable()
                                .aspectRatio(contentMode: /*@START_MENU_TOKEN@*/.fill/*@END_MENU_TOKEN@*/)
                                .frame(width: 90, height: 90)
                                .foregroundColor(.pink)
                            
                        }
                        .padding(.all)
                                                
//                        Button(action:{
//                            timerManager.restartTimer()
//                            print("RESTART")
//                        }){
//                            Image(systemName: "backward.end.alt")
//                                .resizable()
//                                .aspectRatio(contentMode: /*@START_MENU_TOKEN@*/.fill/*@END_MENU_TOKEN@*/)
//                                .frame(width: 20, height: 20)
//                                .foregroundColor(.red)
//                        }
//                        .padding(.all)
                    }
                } else {
                    Button(action:{
                        print("STOP")
                        timerManager.stopTimer()
                    }){
                        Image(systemName: "pause.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: /*@START_MENU_TOKEN@*/.fill/*@END_MENU_TOKEN@*/)
                            .frame(width: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, height: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/)
                            .foregroundColor(.pink)
                    }
                    .padding(.all)
                }
                
                // Infos sur l'activité selectionnée
                if selectedPickerIndex != 0 {
                    Text("Temps focus: \(self.activitySelected?.temps_focus ?? defaultTimer)")
                    Text("Temps pause: \(self.activitySelected?.temps_pause ?? defaultPause)")
                    Text("Nombre de rounds: \(self.activitySelected?.nb_round ?? defaultNbRounds)")
                }
                
                if timerManager.timerMode == .initial {
                    
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
                        timerManager.stopTimer()
                        timerManager.restartTimer()
                        print("RESTART")
                    }){
                        Image(systemName: "backward.end.alt")
                            .resizable()
                            .aspectRatio(contentMode: /*@START_MENU_TOKEN@*/.fill/*@END_MENU_TOKEN@*/)
                            .frame(width: 20, height: 20)
                            .foregroundColor(.red)
                    }
                    .padding(.all)
                }
                                
                
                Spacer()
                
            }
            .padding(.top,20)
        } . onAppear() {
            // availableActivities
            activityApi().getAllActivities(apiBaseUrl: settings.apiBaseUrl) { (activities) in
                self.activities = activities
                if activities.count > 0 {
                    selectedPickerIndex = activities[0].id
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
