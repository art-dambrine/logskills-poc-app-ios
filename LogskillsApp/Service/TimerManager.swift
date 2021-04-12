//
//  TimerManager.swift
//  LogskillsApp
//
//  Created by Arthur Dambrine on 12/04/2021.
//

import Foundation


enum TimerMode {
    case running
    case paused
    case initial
    case breaktime
}

class TimerManager: ObservableObject {
    
    @Published var timerMode: TimerMode = .initial
    
    @Published var secondsLeft = UserDefaults.standard.integer(forKey: "timerlength") + 1
    
    @Published var seconds: String = "00"
    @Published var minutes: String = "00"
    
    @Published var pomodoroCompleted: Bool = false
    
    @Published var roundCurrent = 1
    @Published var pauseCurrent = 0
    
    var timer: Timer? = nil
     
    
    func startTimer(nbRoundMax: Int, nbPauseMax: Int, pauseLength: Int){
        timerMode = .running
        
        self.roundCurrent = 1
        self.pauseCurrent = 0
        
        // 1. Make a new timer
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true){ tempTimer in
            // 2. Check time to change values
            self.secondsLeft -= 1
            
            self.displayHumanReadableTimer()
            
            
            if self.secondsLeft == 0 {
                
                if(self.roundCurrent == nbRoundMax && self.pauseCurrent == nbPauseMax){
                    
                    self.endTimer()
                    
                    // Launch call to API to save completion
                    // ...
                    
                } else {
                    
                    if (self.roundCurrent > self.pauseCurrent){
                        self.pauseCurrent += 1
                        self.secondsLeft = pauseLength
                        self.timerMode = .breaktime                        
                    } else {
                        self.roundCurrent += 1
                        self.secondsLeft = UserDefaults.standard.integer(forKey: "timerlength") + 1
                        self.timerMode = .running
                    }
                    
                }                                
                
                
            }
            
        }
    }
    
    func displayHumanReadableTimer(){
        if (self.secondsLeft > 60) {
            
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
    
    func stopTimer(){
        timerMode = .paused
        self.timer?.invalidate()
        self.timer = nil
    }
    
    func restartTimer(){
        timerMode = .initial
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
        self.secondsLeft = secondes
    }
    
}
