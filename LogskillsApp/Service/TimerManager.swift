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
}

class TimerManager: ObservableObject {
    
    @Published var timerMode: TimerMode = .initial
    
    @Published var secondsLeft = UserDefaults.standard.integer(forKey: "timerlength") + 1
    
    @Published var seconds: String = "00"
    @Published var minutes: String = "00"
    
    var timer: Timer? = nil
    
    func startTimer(){
        timerMode = .running
        // 1. Make a new timer
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true){ tempTimer in
            // 2. Check time to change values
            self.secondsLeft -= 1
            
            self.displayHumanReadableTimer()
            
            if self.secondsLeft == 0 {
                self.endTimer()
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
