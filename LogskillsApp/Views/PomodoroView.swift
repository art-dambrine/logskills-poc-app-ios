//
//  PomodoroView.swift
//  LogskillsApp
//
//  Created by Arthur Dambrine on 11/04/2021.
//

import SwiftUI

struct PomodoroView: View {
    
    @EnvironmentObject var activitiesObs: ActivitiesObs
    @EnvironmentObject var settings: Settings
    @EnvironmentObject var appState: AppState
    
    @ObservedObject var timerManager = TimerManager()
    
    var notificationManager = NotificationManager()
    
    @State var selectedPickerIndex: Int = 0
    @State var activitySelected: Activity?
    
    @State var timeIntervalMovingToBackground = 0
    @State var timeIntervalMovingBackToForeground = 0
    
    let defaultTimer = 25 // mins
    let defaultPause = 5 // mins
    let defaultNbRounds = 3 // 3 rounds        
    let multiplicateurSecondes = 60 // changer : pendant le dev à 1sec et à 60sec en prod
    
    
    var body: some View {        
        
        VStack {
            
            Text("\(self.timerManager.minutes):\(self.timerManager.seconds)")
                .font(.system(size: 60))
                .padding(.top,10)
            
            if (self.timerManager.timerMode == .paused || self.timerManager.timerMode == .initial || self.timerManager.timerMode == .pausedbreaktime) {
                VStack {
                    Button(action:{
                        
                        if self.timerManager.timerMode == .initial {
                            print(self.selectedPickerIndex)
                            self.timerManager.setTimerlength(secondes: (self.activitySelected?.temps_focus ?? 1) * multiplicateurSecondes)
                        }                        
                        
                        self.timerManager.startTimerBackPreceeding(
                            nbRoundMaxParam: self.activitySelected?.nb_round ?? defaultNbRounds,
                            nbPauseMaxParam: (self.activitySelected?.nb_round ?? defaultNbRounds) - 1,
                            pauseLengthParam: (self.activitySelected?.temps_pause ?? defaultPause) * multiplicateurSecondes,
                            soundParam: settings.prefSound
                        )
                        
                        print("START")
                        
                    }){
                        Image(systemName: "play.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: /*@START_MENU_TOKEN@*/.fill/*@END_MENU_TOKEN@*/)
                            .frame(width: 90, height: 90)
                            .foregroundColor( (self.timerManager.timerMode == .breaktime || self.timerManager.timerMode == .pausedbreaktime) ? .blue : .pink)
                        
                    }
                    .padding(.all)
                    .alert(isPresented: $timerManager.pomodoroIsFinished) {
                        Alert(
                            title: Text("Activité complétée, félicitation !"),
                            message: Text("Souhaitez vous sauvegarder votre progression ?"),
                            primaryButton: .default(Text("Sauvegarder")){
                                print("Sauvegarder appel à l'API...")
                                // Sauvegarde du log sur l'API
                                logsApi().createLog(
                                    apiBaseUrl: settings.apiBaseUrl,
                                    log: Logs(id: 0,
                                              temps_total: timerManager.clcTempsTotalSeconds(
                                                nbRoundRestant: self.activitySelected?.nb_round ?? defaultNbRounds,
                                                nbPauseRestant: (self.activitySelected?.nb_round ?? defaultNbRounds) - 1
                                              ) / multiplicateurSecondes,
                                              temps_actif: timerManager.clcTempsActifSeconds(nbRoundRestant: self.activitySelected?.nb_round ?? defaultNbRounds) / multiplicateurSecondes,
                                              id_activite: self.activitySelected?.id ?? 0
                                    )
                                )
                            },
                            secondaryButton: .cancel()
                        )
                    }
                    
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
                        .foregroundColor( (self.timerManager.timerMode == .breaktime || self.timerManager.timerMode == .pausedbreaktime) ? .blue : .pink)
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
                    ForEach(activitiesObs.activities, id: \.self.id) { activity in
                        Text("N°\(activity.id). " + activity.nom + "")
                    }
                }
                .onReceive([self.selectedPickerIndex].publisher.first()) { (value) in
                    // print(value)
                    if (value != 0) {
                        if (activitiesObs.activities.filter{ $0.id == value }.count > 0){
                            self.activitySelected = activitiesObs.activities.filter{ $0.id == value }[0]
                        }                            
                    }
                }
                .labelsHidden()
                
            } else {
                Button(action:{
                    self.timerManager.stopTimer()
                    self.timerManager.resetTimer()
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
                
                if(self.timerManager.timerMode == .breaktime || self.timerManager.timerMode == .pausedbreaktime) {
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
            
            if (self.timerManager.timerMode == .initial){
                
                Button("Retour aux activites"){
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        appState.timerIsRunning = false
                        appState.selectedTab = 0
                    }
                    
                }
            }
            
            
        }
        .offset(y: (appState.timerIsRunning && appState.selectedTab == 1)  ? -60 : 0 ) // offset à l'apparition de la vue
        .offset(y: (self.timerManager.timerMode != .initial)  ? -30 : 0 ) // offset au lancement du timer
        .padding(20)
        .onDisappear {
            self.timerManager.stopTimer()
            self.timerManager.resetTimer()
            print("QUIT VIEW POMODORO")        
        }
        .onAppear() {
            // Si jamais effectué proposer la possibilité de recevoir des notifications
            appState.timerIsRunning = true
            
            notificationManager.registerLocal()
            
            // Mise à jour de la ActivityList
            activitiesObs.refreshActivityList()
            if activitiesObs.activities.count > 0 {
                self.selectedPickerIndex = activitiesObs.activities[0].id
            }                        
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            print("Moving to the background!")
            // print(timerManager.secondsLeft)
            let timeIntervalSince1970 = Date().timeIntervalSince1970
            self.timeIntervalMovingToBackground = Int(round(timeIntervalSince1970))
            
            
            
            // Enregistrement d'une notif
            // Préparer les notifs si on était pas en pause ni en initial au moment de quitter
            if(timerManager.timerMode != .paused && timerManager.timerMode != .pausedbreaktime
                && timerManager.timerMode != .initial){

                // Enregistre les notifs pour alerter l'utilisateur que le round / pause / session est terminé
                
                print("Total remaining time : \(self.timerManager.clcTotalRemainingTimeSeconds())")
                                
                print("==== ================ ====")
                print("== Vérifier les valeurs ==")
                print("==== ================ ====")
                print("")
                
                let notifParamsTab: [NotifParams] = prepareAllNotifsToSend()
                
                print("Préparation des notifications suivantes :")
                print(notifParamsTab)
                
                for notifParams in notifParamsTab {
                    notificationManager.scheduleLocal(
                        triggerTimeInterval: notifParams.triggerTimeInterval,
                        currentIsRound: notifParams.isRoundNotif,
                        nbOfCurrentRoundOrPause: notifParams.notifRoundOrPauseCurrent,
                        nbOfMaxRoundOrPause: notifParams.notifRoundOrPauseMax,
                        isEndOfPomodoro: notifParams.isEndOfPomodoro
                    )
                }
                
                
            } // -> end of if(timerManager.timerMode != .pau...
            
            
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            print("Moving back to the foreground!")
            notificationManager.removeAllPendingNotification()
            
            // print(timerManager.secondsLeft)
            let timeIntervalSince1970 = Date().timeIntervalSince1970
            self.timeIntervalMovingBackToForeground = Int(round(timeIntervalSince1970))
            let timeElapsed = timeIntervalMovingBackToForeground - timeIntervalMovingToBackground
            print("Tps timeElapsed : " + String(timeElapsed))
            
            // Mettre à jour le temps du timerManager si on était pas en pause ni en initial au moment de quitter
            if(timerManager.timerMode != .paused && timerManager.timerMode != .pausedbreaktime
                && timerManager.timerMode != .initial){
                timerManager.clcTimeRemainingAfterComingBackFromBackground(timeElapsed: timeElapsed)
            }
        }
        
    }
    
    
    func clcNbNotifToSend() -> Int {
        return (self.timerManager.nbRoundMax - self.timerManager.roundCurrent) + (self.timerManager.nbPauseMax - self.timerManager.pauseCurrent) + 1
    }
    
    func prepareAllNotifsToSend() -> [NotifParams] {
        let nbNotifToSend = clcNbNotifToSend()
        var notifParamsTab: [NotifParams] = []
        var count = 0
        var virtualRoundCurrent = self.timerManager.roundCurrent
        var virtualPauseCurrent = self.timerManager.pauseCurrent
        var isVirtualRound = (self.timerManager.roundCurrent > self.timerManager.pauseCurrent) // true si on est en cours de round
        var notif: NotifParams
        
        print("NbNotifTosend = \(clcNbNotifToSend())")
        
        if(nbNotifToSend > 1) {
            if (count == 0) {
                
                if(isVirtualRound){
                    // On est en round
                    // Notif du round en cours
                    notif = NotifParams(id: count,
                                        triggerTimeInterval: self.timerManager.secondsLeft,
                                        isRoundNotif: isVirtualRound, // true
                                        notifRoundOrPauseCurrent: virtualRoundCurrent,
                                        notifRoundOrPauseMax: self.timerManager.nbRoundMax,
                                        isEndOfPomodoro: false)
                } else {
                    // On est en pause
                    // Notif de pause en cours
                    notif = NotifParams(id: count,
                                        triggerTimeInterval: self.timerManager.secondsLeft,
                                        isRoundNotif: isVirtualRound, // false
                                        notifRoundOrPauseCurrent: virtualPauseCurrent,
                                        notifRoundOrPauseMax: self.timerManager.nbPauseMax,
                                        isEndOfPomodoro: false)
                }
                
                notifParamsTab.append(notif)
                count += 1
                isVirtualRound.toggle() // isVirtualRound sera à false
            }
            
            // On sera en pause puis en round puis en pause faire la boucle
            while (count != (nbNotifToSend - 1)) {
                // code here
                if(!isVirtualRound){
                    // code temps avec position en pause
                    virtualPauseCurrent += 1
                    notif = NotifParams(id: count,
                                        triggerTimeInterval: notifParamsTab[count-1].triggerTimeInterval + self.timerManager.pauseLength,
                                        isRoundNotif: isVirtualRound, // false
                                        notifRoundOrPauseCurrent: virtualPauseCurrent,
                                        notifRoundOrPauseMax: self.timerManager.nbPauseMax,
                                        isEndOfPomodoro: false)
                } else {
                    // code temps avec round
                    virtualRoundCurrent += 1
                    
                    notif = NotifParams(id: count,
                                        triggerTimeInterval: notifParamsTab[count-1].triggerTimeInterval + self.timerManager.roundLength,
                                        isRoundNotif: isVirtualRound, // true
                                        notifRoundOrPauseCurrent: virtualRoundCurrent,
                                        notifRoundOrPauseMax: self.timerManager.nbRoundMax,
                                        isEndOfPomodoro: false)
                }
                // don't forget
                notifParamsTab.append(notif)
                count += 1
                isVirtualRound.toggle()
            }
            
            // Dernière notif à setup count == nbNotifToSend
            // Last notif :
            notif = NotifParams(id: count,
                                triggerTimeInterval: notifParamsTab[count-1].triggerTimeInterval + self.timerManager.roundLength,
                                isRoundNotif: true, // true
                                notifRoundOrPauseCurrent: self.timerManager.nbRoundMax,
                                notifRoundOrPauseMax: self.timerManager.nbRoundMax,
                                isEndOfPomodoro: true)
            
            notifParamsTab.append(notif)
            
        } else {
            
            // Dernière et unique notif à setup
            notif = NotifParams(id: count,
                                triggerTimeInterval: self.timerManager.secondsLeft,
                                isRoundNotif: true, // true
                                notifRoundOrPauseCurrent: self.timerManager.nbRoundMax,
                                notifRoundOrPauseMax: self.timerManager.nbRoundMax,
                                isEndOfPomodoro: true)
            
            notifParamsTab.append(notif)
            
        }
        
        return notifParamsTab
    }
    
}

struct PomodoroView_Previews: PreviewProvider {
    static var previews: some View {
        PomodoroView()
    }
}
