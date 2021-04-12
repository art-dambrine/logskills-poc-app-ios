//
//  TimerManager.swift
//  LogskillsApp
//
//  Created by Arthur Dambrine on 12/04/2021.
//

import Foundation
import SwiftUI

enum TimerMode {
    case running
    case paused
    case initial
    case breaktime
    case pausedbreaktime
}

class TimerManager: ObservableObject {
    
    @Published var timerMode: TimerMode = .initial
    
    @Published var secondsLeft = UserDefaults.standard.integer(forKey: "timerlength")
    
    @Published var seconds: String = "00"
    @Published var minutes: String = "00"
    
    @Published var roundCurrent = 1
    @Published var pauseCurrent = 0
    
    var nbRoundMax = 3
    var nbPauseMax = 2
    var pauseLength = 5
    var roundLength = 25
    
    let soundManager = SoundManager()
    var sound = "tone"
    
    var timer: Timer? = nil
    
    let multiplicateurSecondes = 1 // changer pendant le dev
    
    
    func startTimerBackPreceeding(nbRoundMaxParam: Int, nbPauseMaxParam: Int, pauseLengthParam: Int, soundParam: String){
        // Fonction pivot pour lancer le timer appel en premier par la vue
        
        // Initialisation des valeurs max passées par la vue
        self.nbRoundMax = nbRoundMaxParam
        self.nbPauseMax = nbPauseMaxParam
        self.pauseLength = pauseLengthParam
        self.sound = soundParam
        
        if(timerMode == .initial) {
            // Initialisation du pomodoro roundCurrent et pauseCurrent
            self.roundCurrent = 1
            self.pauseCurrent = 0
        }
        
        // Si on était en pausedbreaktime et que l'on redémarre on remet en mode breaktime
        if (timerMode != .pausedbreaktime){
            timerMode = .running
        } else {
            timerMode = .breaktime
        }
        
        // Petit son joué au lancement du timer et affichage du timer displayHumanReadableTimer
        self.soundManager.playSound(sound: self.sound, type: "mp3")
        self.displayHumanReadableTimer()
        
        // Démarrage d'un timer qui exectura timerCodeExecute()
        startTimerBack()
    }
    
    @IBAction func startTimerBack() {
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self,
                                          selector: #selector(timerCodeExecute), userInfo: nil, repeats: true)
    }
    
    @objc func timerCodeExecute() {
        
        // 2. Check time to change values
        self.secondsLeft -= 1
        
        self.displayHumanReadableTimer()
                
        if self.secondsLeft == 0 {
            
            if(self.roundCurrent == nbRoundMax && self.pauseCurrent == nbPauseMax){
                pomodoroCompleted()
            } else {
                // Changement d'état round vers pause ou pause vers round
                changementRoundOrPauseTimer()
            }
        }
        
    }
    
    
    func displayHumanReadableTimer(){
        // Permet d'afficher le timer sous une forme toujours lisible à l'écran
        
        if (self.secondsLeft >= 60) {
            
            if (self.secondsLeft % 60) < 10 {
                self.seconds = "0" + String(self.secondsLeft % 60)
            } else {
                self.seconds = String(self.secondsLeft % 60)
            }
            
            
            if (self.secondsLeft / 60) < 10 {
                self.minutes = "0" + String(self.secondsLeft / 60)
            } else {
                self.minutes = String(self.secondsLeft / 60)
            }
            
        } else {
            
            if self.secondsLeft < 10 {
                self.seconds = "0" + String(self.secondsLeft)
            } else {
                self.seconds = String(self.secondsLeft)
            }
            self.minutes = String("00")
        }
    }
    
    func pomodoroCompleted(){
        // On peut ici terminer le timer
        self.endTimer()
        self.soundManager.playSound(sound: self.sound, type: "mp3")
        
        // TODO : Popup de notif à l'utilisateur, prise en compte de son pomodoro
        // Launch call to API to save stats of pomodoro
        // ...
        
    }
    
    func changementRoundOrPauseTimer() {
        
        if self.secondsLeft == 0 {
            if (self.roundCurrent > self.pauseCurrent){
                self.pauseCurrent += 1
                self.secondsLeft = pauseLength
                self.timerMode = .breaktime
                self.soundManager.playSound(sound: self.sound, type: "mp3")
                self.displayHumanReadableTimer()
            } else {
                self.roundCurrent += 1
                self.secondsLeft = UserDefaults.standard.integer(forKey: "timerlength")
                self.timerMode = .running
                self.soundManager.playSound(sound: self.sound, type: "mp3")
                self.displayHumanReadableTimer()
            }
        } else {
            print("ERROR : call de changementRoundOrPauseTimer lorsque secondsLeft != 0")
        }
                
    }
    
    
    func clcTotalRemainingTime() -> Int{
        // Appelé par clcTimeRemainingAfterComingBackFromBackground
        let nbRoundRestant = (self.nbRoundMax - self.roundCurrent)
        let nbPauseRestant = (self.nbPauseMax - self.pauseCurrent)
        let result = nbRoundRestant * self.roundLength + nbPauseRestant * (self.pauseLength * self.multiplicateurSecondes) + self.secondsLeft
        // print("Result = \(nbRoundRestant) * \(self.roundLength) + \(nbPauseRestant) * \(self.pauseLength * self.multiplicateurSecondes) + \(self.secondsLeft) = \(result)")
        return result
    }
    
    func clcTimeRemainingAfterComingBackFromBackground(timeElapsed: Int){
        // Appelé par la vue lors d'un retour depuis le background si on était pas en pause ou initial au moment de quitter
        // Besoin de :
        // temps écoulé = timeElapsed
        // temps total restant avant background = clcTotalRemainingTime()
        // print("Temps total restant avant soustraction : \(self.clcTotalRemainingTime())")
        var timeElapsedToDrain = timeElapsed
        
        let totalRemainingBeforeBack = clcTotalRemainingTime()
        if(timeElapsed >= totalRemainingBeforeBack) {
            print("Fin du pomodoro, complété ou oublié")
            pomodoroCompleted()
        } else {
            print("Pomororo toujours en cours")
            // Calculer les round / pauses et temps restant
            let secondsRemaining = totalRemainingBeforeBack - timeElapsed
            print("Il reste au total \(secondsRemaining) secondes, calcul des rounds et pauses ...")
            
            // Logique de calcul des rounds et pauses à décompter via timeElapsedToDrain auquel on retranche secondsLeft jusqu'à ce qu'il soit 'vidé'
            while (timeElapsedToDrain > 0) {
                // print("timeElapsedToDrain avant calcul  : \(timeElapsedToDrain) , roundCurrent: \(roundCurrent), pauseCurrent: \(pauseCurrent), self.secondsLeft : \(self.secondsLeft)")
                if (timeElapsedToDrain < self.secondsLeft){
                    // timeElapsedToDrain inférieur on reste dans le même round ou pause
                    let temp = self.secondsLeft
                    self.secondsLeft -= timeElapsedToDrain
                    timeElapsedToDrain -= temp
                } else {
                    // timeElapsedToDrain supérieur on saute un round ou pause
                    timeElapsedToDrain -= self.secondsLeft
                    self.secondsLeft = 0
                    changementRoundOrPauseTimer()
                }
            }
            
        }
    }
    
    
    
    func stopTimer(){
        // si en .breaktime on indique pausedbreaktime
        if(timerMode == .breaktime){
            timerMode = .pausedbreaktime
        } else {
            timerMode = .paused
        }
        
        self.timer?.invalidate()
        self.timer = nil
    }
    
    func restartTimer(){
        // Si on est hors du breaktime on reinitialise sinon on laisse breaktime
        if(timerMode != .breaktime){
            timerMode = .initial
        }
        self.secondsLeft = UserDefaults.standard.integer(forKey: "timerlength")
        self.minutes = "00"
        self.seconds = "00"
    }
    
    func endTimer(){
        timerMode = .initial
        self.timer?.invalidate()
        self.timer = nil
        self.minutes = "00"
        self.seconds = "00"
    }
    
    func setTimerlength(secondes: Int){
        UserDefaults.standard.set(secondes, forKey: "timerlength")
        self.roundLength = secondes
        self.secondsLeft = secondes
    }
    
    
}
